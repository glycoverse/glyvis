test_that("generic experiment plot methods support SummarizedExperiment", {
  generic_methods <- c(
    "autoplot",
    "fortify",
    "plot_boxplot",
    "plot_corrplot",
    "plot_heatmap",
    "plot_oplsda",
    "plot_pca",
    "plot_plsda",
    "plot_roc",
    "plot_tsne",
    "plot_umap",
    "plot_volcano"
  )

  purrr::walk(generic_methods, function(generic) {
    expect_true(
      is.function(getS3method(
        generic,
        "SummarizedExperiment",
        optional = TRUE
      )),
      info = generic
    )
  })
})

test_that("glycoproteomics-specific plot methods support GlycoproteomicSE", {
  expect_true(
    is.function(getS3method("plot_logo", "GlycoproteomicSE", optional = TRUE))
  )
  expect_null(getS3method("plot_logo", "GlycomicSE", optional = TRUE))
  expect_null(getS3method("plot_logo", "SummarizedExperiment", optional = TRUE))
})

test_that("fortify reads SummarizedExperiment components natively", {
  se <- glyexp::as_glycomic_se(glyexp::real_experiment2)[1:4, 1:6]

  fortified <- ggplot2::fortify(se)

  expect_s3_class(fortified, "tbl_df")
  expect_named(
    fortified,
    c(
      "sample",
      "group",
      "variable",
      "glycan_composition",
      "glycan_structure",
      "value"
    )
  )
  expect_equal(nrow(fortified), prod(dim(se)))
  expect_equal(fortified$value, as.vector(t(SummarizedExperiment::assay(se))))
})

test_that("fortify uses dimnames when metadata contains conflicting identifiers", {
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(
      abundance = matrix(
        seq_len(6),
        nrow = 2,
        dimnames = list(c("V1", "V2"), c("S1", "S2", "S3"))
      )
    ),
    colData = S4Vectors::DataFrame(
      sample = c("duplicate", "duplicate", "stale"),
      group = c("A", "A", "B"),
      row.names = c("S1", "S2", "S3")
    ),
    rowData = S4Vectors::DataFrame(
      variable = c("stale", "stale"),
      annotation = c("first", "second"),
      row.names = c("V1", "V2")
    )
  )

  fortified <- ggplot2::fortify(se)

  expect_equal(nrow(fortified), prod(dim(se)))
  expect_equal(fortified$sample, rep(colnames(se), times = nrow(se)))
  expect_equal(fortified$variable, rep(rownames(se), each = ncol(se)))
  expect_equal(
    fortified$sample_metadata,
    rep(c("duplicate", "duplicate", "stale"), times = nrow(se))
  )
  expect_equal(
    fortified$variable_metadata,
    rep(c("stale", "stale"), each = ncol(se))
  )
})

test_that("direct plots read plain SummarizedExperiment natively", {
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(
      abundance = matrix(
        seq_len(24),
        nrow = 4,
        dimnames = list(paste0("V", 1:4), paste0("S", 1:6))
      )
    ),
    colData = S4Vectors::DataFrame(
      group = rep(c("A", "B"), each = 3),
      row.names = paste0("S", 1:6)
    )
  )

  expect_s3_class(plot_boxplot(se), "ggplot")
  expect_s3_class(plot_heatmap(se), "ggplot")
  expect_s3_class(autoplot(se, type = "boxplot"), "ggplot")
  expect_s3_class(autoplot(se, type = "heatmap"), "ggplot")
})
