test_that("fortify preserves one row per value with duplicate or absent identifiers", {
  for (variable_names in list(NULL, c("same", "same"), c("V1", "V2"))) {
    for (sample_names in list(NULL, c("sample", "sample"), c("S1", "S2"))) {
      mat <- matrix(c(1, 3, 2, 4), nrow = 2, dimnames = list(variable_names, sample_names))
      exp <- SummarizedExperiment::SummarizedExperiment(
        assays = list(abundance = mat),
        rowData = S4Vectors::DataFrame(feature_position = 1:2),
        colData = S4Vectors::DataFrame(sample_position = 1:2, group = c("A", "B"))
      )
      before <- SummarizedExperiment::assay(exp)
      result <- ggplot2::fortify(exp)
      expected_variables <- if (is.null(variable_names)) c("1", "2") else variable_names
      expected_samples <- if (is.null(sample_names)) c("1", "2") else sample_names

      expect_equal(nrow(result), length(mat))
      expect_identical(result$sample, rep(expected_samples, times = 2))
      expect_identical(result$variable, rep(expected_variables, each = 2))
      expect_identical(result$sample_position, rep(1:2, times = 2))
      expect_identical(result$feature_position, rep(1:2, each = 2))
      expect_identical(result$group, rep(c("A", "B"), times = 2))
      expect_equal(result$value, as.vector(t(mat)))
      expect_identical(SummarizedExperiment::assay(exp), before)
    }
  }
})

test_that("boxplots do not duplicate observations when feature names repeat", {
  mat <- matrix(c(1, 3, 2, 4), nrow = 2, dimnames = list(c("same", "same"), c("S1", "S2")))
  exp <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = mat),
    colData = S4Vectors::DataFrame(group = c("A", "B"))
  )
  result <- plot_boxplot(exp)
  expect_equal(nrow(result$data), length(mat))
  expect_equal(result$data$value, log2(as.vector(t(mat)) + 1e-6))
})
