test_that("container volcano plots use the limma contrast-selection method", {
  skip_if_not_installed("glystats")
  skip_if_not_installed("limma")

  values <- rbind(
    V1 = c(1, 3, 2, 4, 4, 7, 5, 8, 9, 11, 12, 10),
    V2 = c(9, 7, 8, 10, 6, 5, 7, 4, 2, 3, 1, 4),
    V3 = c(2, 4, 3, 5, 3, 2, 4, 5, 4, 3, 6, 5)
  )
  colnames(values) <- paste0("S", seq_len(ncol(values)))
  groups <- factor(rep(c("A", "B", "C"), each = 4))
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = values),
    colData = S4Vectors::DataFrame(group = groups)
  )
  legacy <- structure(
    list(
      expr_mat = values,
      sample_info = tibble::tibble(sample = colnames(values), group = groups),
      var_info = tibble::tibble(variable = rownames(values)),
      meta_data = list(exp_type = "others")
    ),
    class = "glyexp_experiment"
  )

  result <- suppressMessages(glystats::gly_limma(se))
  expected <- plot_volcano(result, contrast = "A_vs_C", title = "Selected")
  for (exp in list(se, legacy)) {
    expect_error(
      suppressMessages(plot_volcano(exp, test = "limma")),
      "contrast.*required"
    )
    selected <- suppressMessages(plot_volcano(
      exp,
      test = "limma",
      contrast = "A_vs_C",
      title = "Selected"
    ))
    expect_equal(selected$data, expected$data)
    expect_equal(unique(selected$data$ref_group), "A")
    expect_equal(unique(selected$data$test_group), "C")
    expect_equal(nrow(selected$data), nrow(values))
    expect_equal(selected$labels$title, "Selected")
    expect_s3_class(selected, "tidyplot")
  }

  two_groups <- se[, groups != "C"]
  single_result <- suppressMessages(glystats::gly_limma(two_groups))
  implicit <- suppressMessages(plot_volcano(two_groups))
  expect_equal(implicit$data, plot_volcano(single_result)$data)
})
