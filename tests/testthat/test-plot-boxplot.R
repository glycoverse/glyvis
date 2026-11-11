test_that("boxplots show log2 abundance plus a small pseudocount", {
  x <- legacy_toy_experiment()
  x$expr_mat[1, 1] <- 0
  p <- plot_boxplot(x)
  expect_equal(p$data$value, log2(as.vector(t(x$expr_mat)) + 1e-6))
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = x$expr_mat),
    colData = S4Vectors::DataFrame(group = x$sample_info$group)
  )
  expect_equal(plot_boxplot(se)$data$value, p$data$value)
})

test_that("SE boxplots select variables by row name before checking the limit", {
  mat <- matrix(
    seq_len(120),
    nrow = 30,
    dimnames = list(paste0("feature", seq_len(30)), paste0("sample", 1:4))
  )
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = mat),
    colData = S4Vectors::DataFrame(group = c("A", "A", "B", "B"))
  )
  selected <- c("feature3", "feature1", "feature3")
  p <- plot_boxplot(se, variables = selected, log_transform = FALSE)
  expect_equal(unique(p$data$.variable), c("feature1", "feature3"))
  expect_equal(p$data$value, as.vector(t(mat[c(1, 3), , drop = FALSE])))
  expect_error(plot_boxplot(se), "less than or equal to 25")
  small <- se[1:2, ]
  expect_equal(
    plot_boxplot(small, variables = NULL)$data,
    plot_boxplot(small)$data
  )
  expect_error(plot_boxplot(se, variables = "unknown"), "unknown")
  expect_error(
    plot_boxplot(se, variables = c("feature1", "unknown")),
    "unknown"
  )
  expect_error(plot_boxplot(se, variables = 1), "character")
  expect_error(plot_boxplot(se, variables = NA_character_), "missing")
  expect_error(plot_boxplot(se, variables = character()), "length")
  rownames(small) <- NULL
  expect_error(plot_boxplot(small, variables = "feature1"), "feature1")
})

skip_on_ci()
skip_on_cran()

test_that("plot_boxplot works", {
  vdiffr::expect_doppelganger(
    "plot_boxplot",
    plot_boxplot(legacy_toy_experiment())
  )
})
