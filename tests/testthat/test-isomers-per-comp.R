isomer_count_fixture <- function() {
  # Duplicate structures across sites and proteins count only once.
  x <- glyexp::real_experiment2[seq_len(21), ]
  SummarizedExperiment::rowData(x) <- S4Vectors::DataFrame(
    glycan_composition = glyrepr::as_glycan_composition(
      c(rep("Hex(3)", 3), "Hex(4)", rep("Hex(5)", 8), rep("Hex(6)", 9))
    ),
    glycan_structure = SummarizedExperiment::rowData(
      glyexp::real_experiment2
    )$glycan_structure[
      c(1, 2, 1, 3, 4:11, 12:20)
    ]
  )
  SummarizedExperiment::assay(x)[] <- 1
  x
}

test_that("isomer counts deduplicate globally and retain ordered bins", {
  x <- isomer_count_fixture()
  p <- plot_isomers_per_comp(x)
  expect_s3_class(p, "tidyplot")
  expect_equal(as.character(p$data$category), c(as.character(1:7), ">=8"))
  expect_equal(p$data$count, c(1, 1, rep(0, 5), 2))
  expect_equal(p$data$value, p$data$count)
  gp <- glyexp::real_experiment[seq_len(nrow(x)), ]
  SummarizedExperiment::rowData(
    gp
  )$glycan_composition <- SummarizedExperiment::rowData(x)$glycan_composition
  SummarizedExperiment::rowData(
    gp
  )$glycan_structure <- SummarizedExperiment::rowData(x)$glycan_structure
  SummarizedExperiment::rowData(gp)$protein <- paste0("P", seq_len(nrow(gp)))
  expect_equal(plot_isomers_per_comp(gp)$data, p$data)
  SummarizedExperiment::assay(x)[] <- NA_real_
  expect_equal(plot_isomers_per_comp(x)$data, p$data)
})

test_that("missing identities are excluded without composition fallback", {
  x <- isomer_count_fixture()
  SummarizedExperiment::rowData(x)$glycan_structure[2] <- NA_character_
  SummarizedExperiment::rowData(x)$glycan_composition[4] <- NA
  expect_warning(p <- plot_isomers_per_comp(x), "Excluded 2 rows")
  expect_equal(p$data$count, c(1, rep(0, 6), 2))
  SummarizedExperiment::rowData(x)$glycan_structure[] <- NA_character_
  expect_warning(
    expect_error(plot_isomers_per_comp(x), "No eligible"),
    "Excluded 21 rows"
  )
  SummarizedExperiment::rowData(x)$glycan_structure <- NULL
  expect_error(plot_isomers_per_comp(x), "Missing row annotations")
})

test_that("abundance weighting pools duplicates and omits missing values", {
  skip_if_not_installed("glydet", "0.14.0")
  x <- isomer_count_fixture()
  p <- plot_isomers_per_comp(x, weight = "abundance")
  expect_equal(p$data$value, c(1, 3, rep(0, 5), 17) * ncol(x))
  expect_equal(p$data$count, c(1, 1, rep(0, 5), 2))
  SummarizedExperiment::rowData(x)$glycan_structure[2] <- NA_character_
  SummarizedExperiment::assay(x)[1, 1] <- NA_real_
  expect_warning(
    p <- plot_isomers_per_comp(x, weight = "abundance"),
    "Excluded 1 row"
  )
  expect_equal(p$data$value, c(3 * ncol(x) - 1, rep(0, 6), 17 * ncol(x)))
  x <- isomer_count_fixture()
  S4Vectors::metadata(x)$scale <- "log2"
  expect_error(plot_isomers_per_comp(x, weight = "abundance"), "linear-scale")
})

test_that("isomer plots validate inputs and support common appearance options", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  x <- isomer_count_fixture()
  expect_error(
    plot_isomers_per_comp(methods::as(x, "SummarizedExperiment")),
    "GlycomicSE"
  )
  expect_error(plot_isomers_per_comp(x[FALSE, ]), "No glycan rows")
  expect_error(plot_isomers_per_comp(x, weight = "invalid"), "weight")
  p <- plot_isomers_per_comp(x, title = "Isomers", palette = "#123456")
  expect_equal(p$labels$title, "Isomers")
  expect_equal(unique(ggplot2::ggplot_build(p)$data[[1]]$fill), "#123456")
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
  expect_error(plot_isomers_per_comp(x, unsupported = TRUE), "must be empty")
})
