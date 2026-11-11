skip_if_not_installed("glyrepr", "1.2.0")
skip_if_not_installed("glydraw", "0.9.0")

fuc_sia_fixture <- function(
  composition = c("H5N4F1S1", "H5N4F1", "H5N4G1", "H5N4"),
  protein = NULL
) {
  rows <- S4Vectors::DataFrame(
    glycan_composition = glyrepr::as_glycan_composition(composition)
  )
  constructor <- glyexp::GlycomicSE
  if (!is.null(protein)) {
    rows$protein <- protein
    rows$protein_site <- rep(10L, length(composition))
    constructor <- glyexp::GlycoproteomicSE
  }
  constructor(
    matrix(seq_along(composition), ncol = 1),
    rowData = rows,
    metadata = list(glycan_type = "O")
  )
}

test_that("composition alone classifies all four categories including NeuGc", {
  x <- fuc_sia_fixture()
  p <- plot_fuc_sia_pie(x)
  expect_s3_class(p, "tidyplot")
  expect_equal(
    as.character(p$data$category),
    c("Fuc+, Sia+", "Fuc+, Sia-", "Fuc-, Sia+", "Fuc-, Sia-")
  )
  expect_equal(p$data$value, rep(1, 4))
  expect_equal(p$data$proportion, rep(0.25, 4))
  expect_equal(
    plot_fuc_sia_pie(fuc_sia_fixture(c(
      "H3N2S1",
      "H3N2G1",
      "H3N2S1G1"
    )))$data$value,
    c(0, 0, 3, 0)
  )
})

test_that("weighting deduplicates compositions or pools all measurements", {
  x <- fuc_sia_fixture(rep("H3N2", 3))
  expect_equal(plot_fuc_sia_pie(x)$data$value, c(0, 0, 0, 1))
  gp <- fuc_sia_fixture(rep("H3N2", 3), c("P1", "P1", "P2"))
  expect_equal(plot_fuc_sia_pie(gp)$data$value, c(0, 0, 0, 2))
  expect_equal(plot_fuc_sia_pie(gp, "abundance")$data$value, c(0, 0, 0, 6))
  x <- fuc_sia_fixture()
  expect_equal(plot_fuc_sia_pie(x, "abundance")$data$proportion, (1:4) / 10)
  SummarizedExperiment::assay(x)[1, ] <- NA_real_
  expect_equal(plot_fuc_sia_pie(x, "abundance")$data$value, c(0, 2, 3, 4))
})

test_that("missing input and invalid abundances are handled explicitly", {
  x <- fuc_sia_fixture(c("H3N2", NA))
  expect_warning(p <- plot_fuc_sia_pie(x), "Excluded 1 row")
  expect_equal(p$data$value, c(0, 0, 0, 1))
  expect_warning(
    expect_error(plot_fuc_sia_pie(x[2, ]), "No eligible"),
    "Excluded"
  )
  expect_error(plot_fuc_sia_pie(x[FALSE, ]), "No eligible")
  x <- fuc_sia_fixture()
  expect_error(plot_fuc_sia_pie(x, "invalid"), "weight")
  for (value in c(-1, Inf, 0, NA_real_)) {
    S4Vectors::metadata(x)$scale <- "log2"
    SummarizedExperiment::assay(x)[] <- value
    S4Vectors::metadata(x)$scale <- "raw"
    expect_error(plot_fuc_sia_pie(x, "abundance"), "non-negative|positive")
  }
  S4Vectors::metadata(x)$scale <- "log2"
  expect_error(plot_fuc_sia_pie(x, "abundance"), "linear-scale")
})

test_that("pies build with zero categories and common appearance options", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  for (x in list(fuc_sia_fixture(), fuc_sia_fixture("H3N2"))) {
    p <- plot_fuc_sia_pie(x, title = "Fuc/Sia", fontsize = 10)
    expect_equal(p$labels$title, "Fuc/Sia")
    expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
    expect_equal(nrow(p$data), 4L)
    cartoons <- glyrepr::as_glycan_composition(glyrepr::as_glycan_structure(
      p$data$glycan_structure
    ))
    expect_equal(glyrepr::count_mono(cartoons, "dHex"), c(1L, 1L, 0L, 0L))
    expect_equal(glyrepr::count_mono(cartoons, "NeuAc"), c(1L, 0L, 1L, 0L))
    expect_true(any(vapply(
      p$layers,
      \(layer) inherits(layer$geom, "GeomGlycan"),
      logical(1)
    )))
    expect_error(plot_fuc_sia_pie(x, unsupported = TRUE), "must be empty")
  }
})
