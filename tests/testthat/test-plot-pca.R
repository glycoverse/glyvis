test_that("PCA methods forward groups and appearance options", {
  skip_if_not_installed("factoextra")
  withr::local_seed(42)
  mat <- matrix(
    exp(rnorm(60)),
    6,
    dimnames = list(paste0("V", 1:6), paste0("S", 1:10))
  )
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = mat),
    colData = S4Vectors::DataFrame(
      group = rep(c("A", "B"), each = 5),
      batch = rep(c("X", "Y"), 5)
    )
  )
  result <- glystats::gly_pca(se)
  groups <- stats::setNames(rep(c("First", "Second"), each = 5), colnames(mat))
  legacy <- legacy_toy_experiment()
  legacy$expr_mat <- mat
  legacy$sample_info <- tibble::tibble(
    sample = colnames(mat),
    group = rep(c("A", "B"), each = 5),
    batch = rep(c("X", "Y"), 5)
  )
  for (x in list(result, se, legacy)) {
    p <- plot_pca(x, groups = groups, title = "Custom PCA", geom = "point")
    expect_equal(p$labels$title, "Custom PCA")
    expect_setequal(as.character(p$data$Groups), groups)
    p <- plot_pca(x, group_col = "batch", title = "Batch")
    expect_setequal(as.character(p$data$Groups), c("X", "Y"))
  }
})

skip_on_ci()
skip_on_cran()

test_that("plot_pca works for SummarizedExperiment with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_pca",
    plot_pca(test_gp_se)
  )
})

test_that("plot_pca works for glystats_pca_res with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_pca_pca_res",
    plot_pca(glystats::gly_pca(test_gp_se))
  )
})
