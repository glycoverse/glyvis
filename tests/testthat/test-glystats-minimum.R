glystats_scale_input <- function(scale, legacy = FALSE) {
  x <- legacy_toy_experiment()
  x$expr_mat <- matrix(
    c(-2, 1, 0, 3, 2, -1, 4, 2, 1, 3, -1, 2,
      2, -2, 4, 1, 3, 0, -2, 4, 1, -1, 2, 0),
    nrow = 4,
    dimnames = dimnames(x$expr_mat)
  )
  x$meta_data$scale <- scale
  if (legacy) {
    return(x)
  }
  SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = x$expr_mat),
    colData = S4Vectors::DataFrame(
      x$sample_info, row.names = x$sample_info$sample
    ),
    metadata = x$meta_data
  )
}

test_that("the installed glystats meets the scale-aware minimum", {
  skip_if_not_installed("glystats")
  expect_true(utils::packageVersion("glystats") >= "0.14.0")
})

test_that("container PCA preserves logged coordinates with released glystats", {
  skip_if_not_installed("glystats")
  withr::local_options(lifecycle_verbosity = "quiet")
  for (scale in c("log", "log2", "log10", "logx")) {
    for (legacy in c(FALSE, TRUE)) {
      x <- glystats_scale_input(scale, legacy)
      before <- x
      mat <- if (legacy) x$expr_mat else SummarizedExperiment::assay(x)
      reference <- stats::prcomp(t(mat), scale. = FALSE)
      expect_no_warning(p <- plot_pca(x, stats_args = list(scale = FALSE)))
      expect_s3_class(p, "tidyplot")
      expect_equal(p$data$sample, rownames(reference$x))
      expect_equal(p$data$x, unname(reference$x[, 1]))
      expect_equal(p$data$y, unname(reference$x[, 2]))
      expect_true(all(is.finite(p$data$x) & is.finite(p$data$y)))

      expect_no_warning(disabled <- plot_pca(
        x, stats_args = list(scale = FALSE, log_transform = FALSE)
      ))
      expect_equal(disabled$data, p$data)
      expect_warning(enabled <- plot_pca(
        x, stats_args = list(scale = FALSE, log_transform = TRUE)
      ), class = "glystats_already_logged")
      expect_equal(enabled$data, p$data)
      expect_identical(x, before)
    }
  }
})

test_that("container PCA retains the raw and missing-scale defaults", {
  skip_if_not_installed("glystats")
  withr::local_options(lifecycle_verbosity = "quiet")
  for (legacy in c(FALSE, TRUE)) {
    for (missing_scale in c(FALSE, TRUE)) {
      x <- glystats_scale_input("raw", legacy)
      if (legacy) {
        x$expr_mat <- exp(x$expr_mat)
        if (missing_scale) x$meta_data$scale <- NULL
        mat <- x$expr_mat
      } else {
        SummarizedExperiment::assay(x) <- exp(SummarizedExperiment::assay(x))
        if (missing_scale) S4Vectors::metadata(x)$scale <- NULL
        mat <- SummarizedExperiment::assay(x)
      }
      before <- x
      reference <- stats::prcomp(t(log(mat + 1)), scale. = FALSE)
      p <- plot_pca(x, stats_args = list(scale = FALSE))
      expect_equal(p$data$x, unname(reference$x[, 1]))
      expect_equal(p$data$y, unname(reference$x[, 2]))
      unchanged <- stats::prcomp(t(mat), scale. = FALSE)
      p <- plot_pca(x, stats_args = list(scale = FALSE, log_transform = FALSE))
      expect_equal(p$data$x, unname(unchanged$x[, 1]))
      expect_equal(p$data$y, unname(unchanged$x[, 2]))
      expect_identical(x, before)
    }
  }
})
