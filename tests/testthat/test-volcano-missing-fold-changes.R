volcano_missing_result <- function(log2fc, cls = "glystats_ttest_res") {
  n <- length(log2fc)
  structure(
    list(tidy_result = tibble::tibble(
      variable = paste0("V", seq_len(n)),
      log2fc = log2fc,
      estimate = seq_len(n),
      p_adj = rep(.01, n),
      p_val = rep(.001, n),
      ref_group = rep("A", n),
      test_group = rep("B", n)
    )),
    class = cls
  )
}

test_that("all-missing fold changes fail clearly at every result entry point", {
  for (cls in c(
    "glystats_ttest_res", "glystats_wilcox_res", "glystats_limma_res"
  )) {
    for (values in list(c(NA_real_, NA_real_), c(NA_real_, NaN))) {
      result <- volcano_missing_result(values, cls)
      before <- result
      for (p_col in c("p_adj", "p_val")) {
        for (plot in list(plot_volcano, ggplot2::autoplot)) {
          error <- expect_error(
            plot(result, p_col = p_col),
            "without any available log2 fold changes",
            class = "glyvis_missing_log2fc"
          )
          expect_match(conditionMessage(error), "logx")
          expect_match(conditionMessage(error), "raw-scale limma")
          expect_match(conditionMessage(error), "native estimates cannot replace")
        }
      }
      expect_identical(result, before)
    }
  }
})

test_that("partially missing fold changes retain available points unchanged", {
  values <- c(-2, NA_real_, 0, 2, NaN)
  for (cls in c(
    "glystats_ttest_res", "glystats_wilcox_res", "glystats_limma_res"
  )) {
    result <- volcano_missing_result(values, cls)
    before <- result
    for (p_col in c("p_adj", "p_val")) {
      for (plot in list(plot_volcano, ggplot2::autoplot)) {
        p <- plot(result, p_col = p_col, label = TRUE)
        expect_s3_class(p, "tidyplot")
        expect_identical(p$data$log2fc, values)
        expect_identical(p$data$estimate, result$tidy_result$estimate)
        expect_equal(
          as.character(p$data$status),
          c("Down", NA_character_, "Unchanged", "Up", NA_character_)
        )
        points <- ggplot2::ggplot_build(p)$data[[1]]
        expect_equal(points$x[!is.na(points$x)], c(-2, 0, 2))
        expect_equal(points$y, -log10(result$tidy_result[[p_col]]))
      }
    }
    expect_identical(result, before)
  }
})

test_that("fold-change availability is checked after selecting a contrast", {
  missing <- volcano_missing_result(c(NA_real_, NA_real_))$tidy_result
  valid <- volcano_missing_result(c(-2, 2))$tidy_result
  valid$test_group <- "C"
  result <- structure(
    list(tidy_result = dplyr::bind_rows(missing, valid)),
    class = "glystats_limma_res"
  )
  for (plot in list(plot_volcano, ggplot2::autoplot)) {
    expect_error(plot(result), "contrast.*required")
    expect_error(
      plot(result, contrast = "A_vs_B"),
      class = "glyvis_missing_log2fc"
    )
    p <- plot(result, contrast = "A_vs_C")
    expect_equal(p$data$log2fc, c(-2, 2))
    expect_equal(unique(p$data$test_group), "C")
  }
})

test_that("missing or empty fold-change columns fail without plotting errors", {
  result <- volcano_missing_result(numeric())
  expect_error(plot_volcano(result), class = "glyvis_missing_log2fc")
  result <- volcano_missing_result(c(1, 2))
  result$tidy_result$log2fc <- NULL
  expect_error(plot_volcano(result), class = "glyvis_missing_log2fc")
})

test_that("zero and infinite fold changes are not mistaken for missing values", {
  for (values in list(c(0, NA_real_), c(-Inf, Inf))) {
    p <- plot_volcano(volcano_missing_result(values))
    expect_s3_class(p, "tidyplot")
    expect_identical(p$data$log2fc, values)
  }
})

test_that("container plots propagate missing fold-change errors", {
  skip_if_not_installed("glystats")
  local_mocked_bindings(
    gly_ttest = function(...) {
      volcano_missing_result(c(NA_real_, NA_real_), "glystats_ttest_res")
    },
    gly_wilcox = function(...) {
      volcano_missing_result(c(NA_real_, NA_real_), "glystats_wilcox_res")
    },
    gly_limma = function(...) {
      volcano_missing_result(c(NA_real_, NA_real_), "glystats_limma_res")
    },
    .package = "glystats"
  )
  values <- rbind(
    V1 = c(-3, -1, -2, 0, 0, 3, 1, 4),
    V2 = c(5, 3, 4, 6, 2, 1, 3, 0),
    V3 = c(-2, 0, -1, 1, -1, -2, 0, 1)
  )
  colnames(values) <- paste0("S", seq_len(ncol(values)))
  groups <- factor(rep(c("A", "B"), each = 4))
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = values),
    colData = S4Vectors::DataFrame(group = groups),
    metadata = list(scale = "logx")
  )
  legacy <- structure(
    list(
      expr_mat = values,
      sample_info = tibble::tibble(sample = colnames(values), group = groups),
      var_info = tibble::tibble(variable = rownames(values)),
      meta_data = list(exp_type = "others", scale = "logx")
    ),
    class = "glyexp_experiment"
  )
  for (exp in list(se, legacy)) {
    for (test in c("ttest", "wilcox", "limma")) {
      expect_error(
        suppressMessages(plot_volcano(exp, test = test)),
        class = "glyvis_missing_log2fc"
      )
    }
  }
})
