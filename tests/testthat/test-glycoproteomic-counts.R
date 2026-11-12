skip_if_not_installed("glyrepr")

gp_count_fixture <- function(
  protein,
  site,
  glycan = rep(1L, length(protein)),
  abundance = NULL
) {
  if (is.null(abundance)) {
    abundance <- cbind(rep(1, length(protein)), rep(3, length(protein)))
  }
  glyexp::GlycoproteomicSE(
    abundance,
    rowData = S4Vectors::DataFrame(
      protein = protein,
      protein_site = as.integer(site),
      glycan_composition = glyrepr::as_glycan_composition(paste0(
        "Hex(",
        glycan + 2L,
        ")HexNAc(2)"
      ))
    ),
    metadata = list(glycan_type = "N")
  )
}

gp_count_bins_fixture <- function() {
  gp_count_fixture(
    c(rep("P1", 11), rep("P2", 8), rep("P3", 9), rep("P4", 7)),
    c(1:9, 1, 1, rep(1, 17), 1:7),
    c(rep(1, 9), 2, 1, 1:8, 1:9, rep(1, 7))
  )
}

test_that("glycan and site distributions deduplicate entities and retain all bins", {
  x <- gp_count_bins_fixture()
  expect_message(p <- plot_glycans_per_site(x), "using.*glycan_composition")
  q <- plot_sites_per_protein(x)
  bins <- c(as.character(1:7), ">=8")
  expect_s3_class(p, "tidyplot")
  expect_s3_class(q, "tidyplot")
  expect_equal(as.character(p$data$category), bins)
  expect_equal(as.character(q$data$category), bins)
  expect_equal(p$data$value, c(15, 1, 0, 0, 0, 0, 0, 2))
  expect_equal(p$data$count, p$data$value)
  expect_equal(q$data$value, c(2, 0, 0, 0, 0, 0, 1, 1))
  expect_equal(q$data$count, q$data$value)
  SummarizedExperiment::assay(x)[] <- NA_real_
  expect_equal(suppressMessages(plot_glycans_per_site(x))$data, p$data)
  expect_equal(plot_sites_per_protein(x)$data, q$data)
})

test_that("abundance weighting pools all samples and duplicate measurements", {
  skip_if_not_installed("glydet", "0.14.0")
  x <- gp_count_bins_fixture()
  p <- suppressMessages(plot_glycans_per_site(x, weight = "abundance"))
  q <- plot_sites_per_protein(x, weight = "abundance")
  expect_equal(p$data$value, c(60, 12, 0, 0, 0, 0, 0, 68))
  expect_equal(q$data$value, c(68, 0, 0, 0, 0, 0, 28, 44))
  expect_equal(sum(p$data$value), sum(SummarizedExperiment::assay(x)))
  expect_equal(sum(q$data$value), sum(SummarizedExperiment::assay(x)))
  expect_equal(q$data$count, c(2L, 0L, 0L, 0L, 0L, 0L, 1L, 1L))
  SummarizedExperiment::assay(x)[1, 1] <- NA_real_
  expect_equal(
    sum(plot_sites_per_protein(x, weight = "abundance")$data$value),
    139
  )
  SummarizedExperiment::assay(x)[] <- NA_real_
  expect_equal(
    plot_sites_per_protein(x, weight = "abundance")$data$value,
    rep(0, 8)
  )
})

test_that("structure annotations take priority and incomplete structures trigger fallback", {
  skip_if_not_installed("glyparse")
  x <- gp_count_fixture(c("P1", "P1"), c(10, 10))
  structures <- glyparse::auto_parse(c(
    "Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    "Man(a1-2)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-"
  ))
  SummarizedExperiment::rowData(x)$glycan_structure <- structures
  expect_message(p <- plot_glycans_per_site(x), NA)
  expect_equal(p$data$value, c(0, 1, rep(0, 6)))
  expect_message(
    q <- plot_glycans_per_site(x, glycan_col = "glycan_composition"),
    NA
  )
  expect_equal(q$data$value, c(1, rep(0, 7)))
  SummarizedExperiment::rowData(x)$glycan_structure[1] <- NA
  expect_message(p <- plot_glycans_per_site(x), "absent or incomplete")
  expect_equal(p$data$value, q$data$value)
  expect_warning(
    p <- plot_glycans_per_site(x, glycan_col = "glycan_structure"),
    "Excluded 1 row"
  )
  expect_equal(p$data$value, q$data$value)
})

test_that("only GlycoproteomicSE inputs are accepted", {
  x <- gp_count_bins_fixture()
  plain <- methods::as(x, "SummarizedExperiment")
  comic <- glyexp::as_glycomic_se(plain)
  for (plot in list(plot_glycans_per_site, plot_sites_per_protein)) {
    for (input in list(
      plain,
      comic,
      structure(list(), class = "glyexp_experiment")
    )) {
      expect_error(plot(input), "GlycoproteomicSE")
    }
    expect_error(plot(x, weight = "invalid"), "weight")
    expect_error(plot(x[FALSE, ]), "No glycoproteomic rows")
  }
})

test_that("site counts do not need glycan identity or N-glycan metadata", {
  x <- gp_count_bins_fixture()
  SummarizedExperiment::rowData(x)$glycan_composition[] <- NA
  S4Vectors::metadata(x)$glycan_type <- "O"
  expect_equal(plot_sites_per_protein(x)$data$value, c(2, 0, 0, 0, 0, 0, 1, 1))
  expect_warning(
    expect_error(
      plot_glycans_per_site(x, glycan_col = "glycan_composition"),
      "No eligible"
    ),
    "Excluded 35 rows"
  )
})

test_that("invalid annotations and unsuitable abundance scales fail clearly", {
  x <- gp_count_bins_fixture()
  expect_error(
    plot_glycans_per_site(x, glycan_col = "absent"),
    "Missing row annotation"
  )
  SummarizedExperiment::rowData(x)$protein[1] <- NA_character_
  expect_error(plot_sites_per_protein(x), "must be complete")
  skip_if_not_installed("glydet", "0.14.0")
  x <- gp_count_bins_fixture()
  S4Vectors::metadata(x)$scale <- "log2"
  expect_error(plot_sites_per_protein(x, weight = "abundance"), "linear-scale")
  SummarizedExperiment::assay(x)[1, 1] <- -1
  S4Vectors::metadata(x)$scale <- "raw"
  expect_error(plot_sites_per_protein(x, weight = "abundance"), "non-negative")
  SummarizedExperiment::assay(x)[1, 1] <- Inf
  expect_error(plot_sites_per_protein(x, weight = "abundance"), "finite")
})

test_that("bars preserve numeric bin order and use one colour", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  x <- gp_count_bins_fixture()
  for (plot in list(plot_glycans_per_site, plot_sites_per_protein)) {
    p <- suppressMessages(plot(x, title = "Distribution", palette = "#123456"))
    expect_equal(p$labels$title, "Distribution")
    expect_equal(unique(ggplot2::ggplot_build(p)$data[[1]]$fill), "#123456")
    expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
    expect_error(suppressMessages(plot(x, unsupported = TRUE)), "must be empty")
  }
})
