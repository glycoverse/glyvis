plot_variable_results <- function(current = TRUE) {
  data <- tibble::tibble(
    variable = c("glycan B", "glycan A", "glycan C"),
    p_val = c(0.01, 0.08, 0.001),
    p_adj = c(0.015, 0.08, 0.003),
    log2fc = c(2, -1, -3),
    estimate = c(1.9, -0.9, -2.8)
  )
  identifiers <- NULL
  if (current) {
    data$.variable <- data$variable
    data$variable <- "annotation, not an identifier"
    identifiers <- list(columns = c(variable = ".variable"))
  }
  list(
    volcano = list(tidy_result = data, identifiers = identifiers),
    multigroup = list(
      tidy_result = list(main_test = data),
      identifiers = identifiers
    )
  )
}

test_that("volcano selection supports both result schemas without changing statistics", {
  ids <- c("glycan C", "glycan B", "glycan C")
  for (current in c(TRUE, FALSE)) {
    fixture <- plot_variable_results(current)
    for (cls in c("ttest", "wilcox")) {
      result <- structure(
        fixture$volcano,
        class = paste0("glystats_", cls, "_res")
      )
      full <- plot_volcano(result)
      expect_identical(plot_volcano(result, variables = NULL)$data, full$data)
      expect_equal(nrow(full$data), 3L)
      expect_identical(
        plot_volcano(result, variables = ids)$data,
        full$data[c(1, 3), ]
      )
      expect_identical(
        autoplot(result, variables = ids)$data,
        full$data[c(1, 3), ]
      )
      expect_error(
        plot_volcano(result, variables = c(ids, "unknown")),
        "unknown"
      )
      expect_error(plot_volcano(result, variables = character()), "variables")
      expect_error(plot_volcano(result, variables = NA_character_), "variables")
    }
  }
  expect_error(
    plot_volcano(
      structure(
        plot_variable_results()$volcano,
        class = "glystats_ttest_res"
      ),
      variables = "annotation, not an identifier"
    ),
    "selected result"
  )
})

test_that("limma selection applies within the requested contrast", {
  result <- structure(
    plot_variable_results()$volcano,
    class = "glystats_limma_res"
  )
  df <- result$tidy_result
  result$tidy_result <- dplyr::bind_rows(
    dplyr::mutate(df[c(1, 3), ], ref_group = "A", test_group = "B"),
    dplyr::mutate(df[c(2, 3), ], ref_group = "A", test_group = "C")
  )
  full <- plot_volcano(result, contrast = "A_vs_C")
  selected <- plot_volcano(result, contrast = "A_vs_C", variables = "glycan C")
  expect_identical(selected$data, full$data[2, ])
  expect_identical(
    autoplot(result, contrast = "A_vs_C", variables = "glycan C")$data,
    selected$data
  )
  expect_error(
    autoplot(result, contrast = "A_vs_C", variables = "glycan B"),
    "glycan B"
  )
})

test_that("p-value dotplots apply top_n after feature selection", {
  for (current in c(TRUE, FALSE)) {
    fixture <- plot_variable_results(current)
    for (cls in c("anova", "kruskal", "cox")) {
      source <- if (cls == "cox") fixture$volcano else fixture$multigroup
      result <- structure(source, class = paste0("glystats_", cls, "_res"))
      id_col <- if (current) ".variable" else "variable"
      full <- autoplot(result)$data
      expect_identical(autoplot(result, variables = NULL)$data, full)
      selected <- autoplot(
        result,
        top_n = 1,
        variables = c("glycan A", "glycan B", "glycan B")
      )$data
      expect_identical(as.character(selected[[id_col]]), "glycan B")
      expect_identical(selected$p_val, full$p_val[1])
      expect_identical(selected$p_adj, full$p_adj[1])
      expect_identical(selected$neglog10p, full$neglog10p[1])
      expect_error(autoplot(result, variables = "unknown"), "unknown")
    }
  }
})

test_that("ROC coordinate rows and AUCs are selected without recomputation", {
  for (current in c(TRUE, FALSE)) {
    ids <- paste0("glycan-", 1:11)
    id_col <- if (current) ".variable" else "variable"
    auc <- tibble::tibble(auc = seq(0.5, 1, length.out = 11))
    auc[[id_col]] <- ids
    coords <- tibble::tibble(
      sensitivity = rep(c(0, .75, 1), times = 11),
      specificity = rep(c(1, .5, 0), times = 11)
    )
    coords[[id_col]] <- rep(ids, each = 3)
    roc <- structure(
      list(
        tidy_result = list(auc = auc, coords = coords),
        identifiers = if (current) {
          list(columns = c(variable = id_col))
        } else {
          NULL
        }
      ),
      class = "glystats_roc_res"
    )
    chosen <- ids[c(10, 2, 10)]
    roc_selected <- plot_roc(roc, variables = chosen)
    expect_identical(roc_selected$data[[id_col]], rep(ids[c(2, 10)], each = 3))
    expect_identical(roc_selected$data$sensitivity, rep(c(0, .75, 1), 2))
    expect_identical(roc_selected$data$false_positive_rate, rep(c(0, .5, 1), 2))
    expect_identical(
      autoplot(roc, type = "roc", variables = chosen)$data,
      roc_selected$data
    )
    expect_error(plot_roc(roc), "less than or equal to 10")
    expect_error(plot_roc(roc, variables = ids), "less than or equal to 10")
    expect_error(plot_roc(roc, variables = "unknown"), "unknown")
    full <- plot_roc(roc, type = "dotplot")$data
    expect_identical(autoplot(roc, variables = NULL)$data, full)
    selected <- autoplot(roc, variables = chosen, top_n = 1)$data
    expect_identical(as.character(selected[[id_col]]), ids[10])
    expect_identical(selected$auc, auc$auc[10])
  }
})

test_that("experiment wrappers select only after fitting all features", {
  withr::local_options(lifecycle_verbosity = "quiet")
  skip_if_not_installed("glystats")
  skip_if_not_installed("limma")
  skip_if_not_installed("pROC")
  shape <- outer(seq_len(11), 1:12, function(i, j) {
    21 + (i * j) %% 23 + j * (i %% 3)
  })
  rownames(shape) <- paste0("V", seq_len(nrow(shape)))
  colnames(shape) <- paste0("S", seq_len(ncol(shape)))
  groups <- factor(rep(c("A", "B"), each = 6))
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = shape),
    colData = S4Vectors::DataFrame(group = groups)
  )
  legacy <- structure(
    list(
      expr_mat = shape,
      sample_info = tibble::tibble(sample = colnames(shape), group = groups),
      var_info = tibble::tibble(variable = rownames(shape)),
      meta_data = list(exp_type = "others")
    ),
    class = "glyexp_experiment"
  )
  ids <- c("V8", "V4")
  for (exp in list(se, legacy)) {
    result <- suppressMessages(glystats::gly_limma(exp))
    id_col <- .result_id_column(result, "variable")
    full <- plot_volcano(result)$data
    selected <- suppressMessages(plot_volcano(exp, variables = ids))$data
    expect_identical(selected, full[full[[id_col]] %in% ids, ])
    result <- suppressMessages(glystats::gly_roc(exp))
    expect_error(plot_roc(exp), "less than or equal to 10")
    expect_equal(
      suppressMessages(plot_roc(exp, variables = ids))$data,
      plot_roc(result, variables = ids)$data
    )
  }
})
