test_that("custom trees are validated after zero-variance filtering", {
  mat <- matrix(
    c(1, 1, 1, 1, 2, 4, 6, 8, 3, 5, 9, 12),
    3,
    byrow = TRUE,
    dimnames = list(c("constant", "A", "B"), paste0("S", 1:4))
  )
  for (by in c("row", "col")) {
    values <- if (by == "row") mat else t(mat)
    x <- SummarizedExperiment::SummarizedExperiment(assays = list(values))
    tree <- stats::hclust(stats::dist(mat))
    args <- if (by == "row") {
      list(cluster_rows = tree)
    } else {
      list(cluster_cols = tree)
    }
    expect_snapshot(error = TRUE, do.call(plot_heatmap, c(list(x), args)))
    retained <- mat[-1, , drop = FALSE]
    tree <- stats::hclust(stats::dist(retained))
    args <- if (by == "row") {
      list(cluster_rows = tree)
    } else {
      list(cluster_cols = tree)
    }
    expect_s3_class(
      suppressWarnings(do.call(plot_heatmap, c(list(x), args))),
      "ggplot"
    )
  }
})

test_that("heatmap clustering overrides skip default dendrogram computation", {
  calls <- character()
  local_mocked_bindings(.robust_hclust = function(mat, by) {
    calls <<- c(calls, by)
    FALSE
  })
  x <- legacy_toy_experiment()
  rows <- stats::hclust(stats::dist(x$expr_mat))
  cols <- stats::hclust(stats::dist(t(x$expr_mat)))
  for (overrides in list(
    list(cluster_rows = FALSE, cluster_cols = FALSE),
    list(cluster_rows = rows, cluster_cols = cols)
  )) {
    calls <- character()
    p <- do.call(plot_heatmap, c(list(x), overrides))
    expect_s3_class(p, "ggplot")
    expect_length(calls, 0)
  }
  plot_heatmap(x, cluster_rows = FALSE)
  expect_equal(calls, "col")
  calls <- character()
  plot_heatmap(x, cluster_cols = FALSE)
  expect_equal(calls, "row")
})

test_that("heatmap defaults can be overridden", {
  p <- plot_heatmap(
    legacy_toy_experiment(),
    scale = "none",
    show_rownames = TRUE,
    cluster_rows = FALSE,
    cluster_cols = FALSE,
    na_col = "white"
  )
  expect_s3_class(p, "ggplot")
  expect_equal(
    p$data$value,
    as.vector(log2(legacy_toy_experiment()$expr_mat + 1))
  )
  expect_equal(
    levels(p$data$sample),
    colnames(legacy_toy_experiment()$expr_mat)
  )
  expect_equal(p$scales$get_scales("fill")$na.value, "white")
  expect_s3_class(p, "tidyplot")
})

skip_on_ci()
skip_on_cran()

test_that("plot_heatmap works with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_heatmap",
    plot_heatmap(test_gp_se)
  )
})
