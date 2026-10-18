test_that("heatmap defaults can be overridden", {
  skip_if_not_installed("pheatmap")
  captured <- NULL
  local_mocked_bindings(
    pheatmap = function(...) {
      captured <<- list(...)
      grid::rectGrob()
    },
    .package = "pheatmap"
  )
  p <- plot_heatmap(
    legacy_toy_experiment(),
    scale = "none",
    show_rownames = TRUE,
    cluster_rows = FALSE,
    cluster_cols = FALSE,
    na_col = "white"
  )
  expect_s3_class(p, "ggplot")
  expect_equal(captured$scale, "none")
  expect_identical(captured$show_rownames, TRUE)
  expect_identical(captured$cluster_rows, FALSE)
  expect_identical(captured$cluster_cols, FALSE)
  expect_equal(captured$na_col, "white")
})

skip_on_ci()
skip_on_cran()

test_that("plot_heatmap works with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_heatmap",
    plot_heatmap(test_gp_se)
  )
})
