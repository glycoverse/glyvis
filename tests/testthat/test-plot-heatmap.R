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
    as.vector(log2(legacy_toy_experiment()$expr_mat + 1e-6))
  )
  expect_equal(
    levels(p$data$sample),
    colnames(legacy_toy_experiment()$expr_mat)
  )
  expect_equal(p$scales$get_scales("fill")$na.value, "white")
  expect_s3_class(p, "tidyplot")
})

test_that("tree visibility is independent of clustering across container entry points", {
  legacy <- legacy_toy_experiment()
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(legacy$expr_mat)
  )
  for (x in list(legacy, se)) {
    for (draw in list(plot_heatmap, ggplot2::autoplot)) {
      default <- draw(x)
      expect_length(ggplot2::ggplot_build(default)$data, 3)
      for (row in c(FALSE, TRUE)) {
        for (col in c(FALSE, TRUE)) {
          p <- draw(x, row_cluster_tree = row, col_cluster_tree = col)
          expect_s3_class(p, "tidyplot")
          built <- ggplot2::ggplot_build(p)
          expect_length(built$data, 1 + row + col)
          expect_equal(p$data, default$data)
          expect_equal(
            built$data[[1]],
            ggplot2::ggplot_build(default)$data[[1]]
          )
        }
      }
      for (arg in c("row_cluster_tree", "col_cluster_tree")) {
        for (invalid in list(NA, NULL, 1, "TRUE", c(TRUE, FALSE))) {
          expect_error(
            do.call(draw, c(list(x), setNames(list(invalid), arg))),
            arg
          )
        }
      }
      expect_length(draw(x, cluster_rows = FALSE)$layers, 2)
      expect_length(draw(x, cluster_cols = FALSE)$layers, 2)
      expect_length(
        draw(x, cluster_rows = FALSE, cluster_cols = FALSE)$layers,
        1
      )
    }
  }
})

test_that("custom tree tips align with heatmap cell centers", {
  x <- legacy_toy_experiment()
  rows <- stats::hclust(stats::dist(x$expr_mat))
  cols <- stats::hclust(stats::dist(t(x$expr_mat)))
  p <- plot_heatmap(x, cluster_rows = rows, cluster_cols = cols)
  expect_equal(levels(p$data$variable), rev(rownames(x$expr_mat)[rows$order]))
  expect_equal(levels(p$data$sample), colnames(x$expr_mat)[cols$order])
  built <- ggplot2::ggplot_build(p)
  row_segments <- built$data[[2]]
  col_segments <- built$data[[3]]
  row_tips <- row_segments[row_segments$x == max(row_segments$x), ]
  col_tips <- col_segments[col_segments$y == min(col_segments$y), ]
  expect_equal(sort(row_tips$y), seq_len(nrow(x$expr_mat)))
  expect_equal(sort(col_tips$x), seq_len(ncol(x$expr_mat)))
  expect_true(all(row_segments$x < min(built$data[[1]]$xmin)))
  expect_true(all(col_segments$y > max(built$data[[1]]$ymax)))
  styled <- p |> tidyplots::adjust_size(width = 80, height = 60)
  expect_equal(ggplot2::ggplot_build(styled)$data, built$data)
  expect_s3_class(ggplot2::ggplotGrob(styled), "gtable")
})

test_that("unavailable and zero-height trees are handled", {
  x <- legacy_toy_experiment()
  tree <- stats::hclust(stats::dist(x$expr_mat))
  tree$height[] <- 0
  p <- plot_heatmap(x, cluster_rows = tree, cluster_cols = FALSE)
  segments <- ggplot2::ggplot_build(p)$data[[2]]
  expect_true(all(is.finite(as.matrix(segments[c("x", "y", "xend", "yend")]))))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
  local_mocked_bindings(.robust_hclust = function(mat, by) FALSE)
  expect_length(plot_heatmap(x)$layers, 1)
})

skip_on_ci()
skip_on_cran()

test_that("plot_heatmap works with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_heatmap",
    plot_heatmap(test_gp_se)
  )
})
