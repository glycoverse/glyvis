scale_plot_input <- function(mat, scale, legacy = FALSE) {
  meta <- if (missing(scale)) list() else list(scale = scale)
  if (legacy) {
    x <- legacy_toy_experiment()
    x$expr_mat <- mat
    x$meta_data <- c(x$meta_data, meta)
    return(x)
  }
  SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = mat),
    colData = S4Vectors::DataFrame(group = rep(c("A", "B"), each = 3)),
    metadata = meta
  )
}

scale_plot_values <- function(p, boxplot) {
  if (boxplot) as.vector(t(p)) else as.vector(p)
}

scale_plot <- function(x, boxplot, log_transform = NULL) {
  if (boxplot) {
    plot_boxplot(x, log_transform = log_transform)
  } else {
    plot_heatmap(
      x,
      scale = "none",
      cluster_rows = FALSE,
      cluster_cols = FALSE,
      log_transform = log_transform
    )
  }
}

test_that("raw plots use a small pseudocount and allow unchanged values", {
  withr::local_options(lifecycle_verbosity = "quiet")
  mat <- legacy_toy_experiment()$expr_mat
  mat[1, 1] <- 0
  mat[2, 1] <- NA_real_
  mat[3, 1] <- 1e-12
  mat[4, 1] <- 1e-6
  mat[1, 2] <- 1e-3
  mat[2, 2] <- 1e6
  for (legacy in c(FALSE, TRUE)) {
    for (missing_scale in c(FALSE, TRUE)) {
      x <- if (missing_scale) {
        scale_plot_input(mat, legacy = legacy)
      } else {
        scale_plot_input(mat, "raw", legacy)
      }
      before <- x
      for (boxplot in c(FALSE, TRUE)) {
        expected <- scale_plot_values(mat, boxplot)
        default <- scale_plot(x, boxplot)
        enabled <- scale_plot(x, boxplot, TRUE)
        disabled <- scale_plot(x, boxplot, FALSE)
        expect_equal(default$data$value, log2(expected + 1e-6))
        expect_equal(is.na(default$data$value), is.na(expected))
        expect_true(all(is.finite(default$data$value[!is.na(expected)])))
        expect_equal(default$data$value[which(expected == 0)], log2(1e-6))
        expect_equal(enabled$data$value, default$data$value)
        expect_equal(disabled$data$value, expected)
        if (boxplot) {
          expect_equal(default$labels$y, expression(log[2]("Expr." + 1e-6)))
          expect_identical(disabled$labels$y, "Expr.")
        } else {
          expect_identical(default$labels$fill, "log2(abundance + 1e-6)")
          expect_identical(default$labels$colour, default$labels$fill)
          expect_identical(disabled$labels$fill, "Abundance")
          expect_identical(disabled$labels$colour, "Abundance")
        }
      }
      expect_identical(x, before)
    }
  }
})

test_that("logged plots preserve signed coordinates and use recorded labels", {
  withr::local_options(lifecycle_verbosity = "quiet")
  mat <- legacy_toy_experiment()$expr_mat / 4 - 3
  mat[2, 1] <- NA_real_
  for (scale in c("log", "log2", "log10", "logx")) {
    label <- if (scale == "log") "natural-log" else scale
    for (legacy in c(FALSE, TRUE)) {
      x <- scale_plot_input(mat, scale, legacy)
      before <- x
      for (boxplot in c(FALSE, TRUE)) {
        expected <- scale_plot_values(mat, boxplot)
        default <- scale_plot(x, boxplot)
        disabled <- scale_plot(x, boxplot, FALSE)
        expect_warning(
          enabled <- scale_plot(x, boxplot, TRUE),
          "is ignored because the input already uses scale",
          class = "glyvis_already_logged"
        )
        expect_equal(default$data$value, expected)
        expect_equal(disabled$data$value, expected)
        expect_equal(enabled$data$value, expected)
        if (boxplot) {
          expect_identical(
            default$labels$y,
            paste0("Expr. (", label, " scale)")
          )
          expect_identical(enabled$labels$y, default$labels$y)
        } else {
          expect_identical(
            default$labels$fill,
            paste0("Abundance (", label, " scale)")
          )
          expect_identical(enabled$labels$fill, default$labels$fill)
          expect_identical(default$labels$colour, default$labels$fill)
        }
      }
      expect_identical(x, before)
    }
  }
})

test_that("container autoplot forwards transformations independently of scaling", {
  withr::local_options(lifecycle_verbosity = "quiet")
  mat <- legacy_toy_experiment()$expr_mat / 4 - 3
  for (legacy in c(FALSE, TRUE)) {
    for (scale in c("raw", "log", "log2", "log10", "logx")) {
      x <- scale_plot_input(mat, scale, legacy)
      for (boxplot in c(FALSE, TRUE)) {
        args <- if (boxplot) {
          list(type = "boxplot")
        } else {
          list(
            type = "heatmap",
            scale = "none",
            cluster_rows = FALSE,
            cluster_cols = FALSE
          )
        }
        p <- do.call(ggplot2::autoplot, c(list(x, log_transform = FALSE), args))
        expect_equal(p$data$value, scale_plot_values(mat, boxplot))
        if (scale != "raw") {
          default <- do.call(ggplot2::autoplot, c(list(x), args))
          expect_equal(default$data$value, p$data$value)
          expect_warning(
            enabled <- do.call(
              ggplot2::autoplot,
              c(list(x, log_transform = TRUE), args)
            ),
            class = "glyvis_already_logged"
          )
          expect_equal(enabled$data$value, p$data$value)
        }
      }
    }
  }
})

test_that("heatmap clustering sees chosen values before standardization", {
  withr::local_options(lifecycle_verbosity = "quiet")
  mat <- legacy_toy_experiment()$expr_mat
  for (scale in c("raw", "log2", "logx")) {
    x <- scale_plot_input(mat, scale)
    for (transform in list(NULL, FALSE, TRUE)) {
      expected <- if (scale == "raw" && !identical(transform, FALSE)) {
        log2(mat + 1e-6)
      } else {
        mat
      }
      seen <- list()
      local_mocked_bindings(.robust_hclust = function(mat, by) {
        seen[[by]] <<- mat
        FALSE
      })
      p <- suppressWarnings(plot_heatmap(x, log_transform = transform))
      expect_equal(seen$row, expected)
      expect_equal(seen$col, expected)
      expect_equal(p$data$value, as.vector(t(scale(t(expected)))))
      expect_identical(p$labels$fill, "Z score")
      p <- suppressWarnings(plot_heatmap(
        x,
        scale = "column",
        log_transform = transform
      ))
      expect_equal(p$data$value, as.vector(scale(expected)))
      expect_identical(p$labels$colour, "Z score")
    }
  }
})

test_that("invalid flags and explicit invalid scales are rejected", {
  withr::local_options(lifecycle_verbosity = "quiet")
  mat <- legacy_toy_experiment()$expr_mat
  for (legacy in c(FALSE, TRUE)) {
    x <- scale_plot_input(mat, "raw", legacy)
    for (flag in list(NA, c(TRUE, FALSE), logical(), "TRUE", 1)) {
      expect_error(plot_boxplot(x, log_transform = flag), "log_transform")
      expect_error(plot_heatmap(x, log_transform = flag), "log_transform")
      expect_error(ggplot2::autoplot(x, log_transform = flag), "log_transform")
    }
    for (scale in list(
      NULL,
      NA_character_,
      character(),
      c("raw", "log2"),
      "clr",
      "log3",
      2
    )) {
      x <- scale_plot_input(mat, scale, legacy)
      for (flag in list(NULL, FALSE, TRUE)) {
        expect_error(plot_boxplot(x, log_transform = flag), "Metadata `scale`")
        expect_error(plot_heatmap(x, log_transform = flag), "Metadata `scale`")
      }
    }
  }
})

test_that("native GlycoSE containers use the same metadata contract", {
  withr::local_options(lifecycle_verbosity = "quiet")
  mat <- legacy_toy_experiment()$expr_mat
  row_info <- SummarizedExperiment::rowData(test_gp_se)[
    seq_len(nrow(mat)),
    ,
    drop = FALSE
  ]
  rownames(row_info) <- rownames(mat)
  for (constructor in list(glyexp::GlycomicSE, glyexp::GlycoproteomicSE)) {
    for (scale in c("raw", "log", "log2", "log10", "logx")) {
      x <- constructor(
        mat,
        colData = S4Vectors::DataFrame(group = rep(c("A", "B"), each = 3)),
        rowData = row_info,
        metadata = list(glycan_type = "N")
      )
      S4Vectors::metadata(x)$scale <- scale
      before <- x
      expected <- if (scale == "raw") log2(mat + 1e-6) else mat
      expect_equal(plot_boxplot(x)$data$value, as.vector(t(expected)))
      expect_equal(
        plot_heatmap(x, scale = "none")$data$value,
        as.vector(expected)
      )
      expect_identical(x, before)
    }
  }
})

test_that("container autoplot applies the small pseudocount to raw values", {
  withr::local_options(lifecycle_verbosity = "quiet")
  mat <- legacy_toy_experiment()$expr_mat / 1e6
  mat[1, 1] <- 0
  mat[2, 1] <- NA_real_
  for (legacy in c(FALSE, TRUE)) {
    x <- scale_plot_input(mat, "raw", legacy)
    for (boxplot in c(FALSE, TRUE)) {
      args <- if (boxplot) {
        list(type = "boxplot")
      } else {
        list(
          type = "heatmap",
          scale = "none",
          cluster_rows = FALSE,
          cluster_cols = FALSE
        )
      }
      for (transform in list(NULL, TRUE, FALSE)) {
        p <- do.call(
          ggplot2::autoplot,
          c(list(x, log_transform = transform), args)
        )
        expected <- if (identical(transform, FALSE)) mat else log2(mat + 1e-6)
        expect_equal(p$data$value, scale_plot_values(expected, boxplot))
      }
    }
  }
})

test_that("named plotting arguments control facets and transformation", {
  mat <- legacy_toy_experiment()$expr_mat
  x <- scale_plot_input(mat, "raw")
  p <- plot_boxplot(x, group_col = "group", ncol = 2, log_transform = FALSE)
  expect_equal(p$data$value, as.vector(t(mat)))
  expect_equal(p$facet$params$ncol, 2)
  p <- plot_heatmap(
    x,
    scale = "none",
    cluster_rows = FALSE,
    cluster_cols = FALSE,
    log_transform = FALSE
  )
  expect_equal(p$data$value, as.vector(mat))
  p <- ggplot2::autoplot(
    x,
    type = "heatmap",
    group_col = "group",
    scale = "none",
    cluster_rows = FALSE,
    cluster_cols = FALSE,
    log_transform = FALSE
  )
  expect_equal(p$data$value, as.vector(mat))
})

test_that("validated scalar names do not change transformation decisions", {
  mat <- legacy_toy_experiment()$expr_mat
  x <- scale_plot_input(mat, c(abundance = "raw"))
  expect_equal(plot_boxplot(x)$data$value, as.vector(t(log2(mat + 1e-6))))
  expect_equal(
    plot_boxplot(x, log_transform = c(enabled = FALSE))$data$value,
    as.vector(t(mat))
  )
  expect_equal(
    plot_heatmap(
      x,
      scale = "none",
      log_transform = c(enabled = TRUE)
    )$data$value,
    as.vector(log2(mat + 1e-6))
  )
  S4Vectors::metadata(x)$scale <- c(abundance = "log2")
  expect_warning(
    p <- plot_heatmap(x, scale = "none", log_transform = c(enabled = TRUE)),
    class = "glyvis_already_logged"
  )
  expect_equal(p$data$value, as.vector(mat))
  expect_identical(p$labels$fill, "Abundance (log2 scale)")
})
