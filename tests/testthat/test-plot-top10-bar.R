skip_if_not_installed("glydet", "0.14.0")
skip_if_not_installed("glydraw", "0.9.0")
skip_if_not_installed("glymotif", "1.0.1")
skip_if_not_installed("glyparse", "1.0.1")
skip_if_not_installed("glyrepr", "1.2.0")

top10_fixture <- function() {
  core <- "Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-"
  structures <- c(
    core,
    paste0("GlcNAc(b1-2)", core),
    paste0("Gal(b1-4)GlcNAc(b1-2)", core)
  )
  structures <- glyparse::auto_parse(structures[c(1, 1, 1, 1, 2, 2, 3)])
  glyexp::GlycoproteomicSE(
    matrix(c(1, 2, 3, 4, 10, 20, 100, 1, 2, 3, NA, 10, 20, 100), 7),
    rowData = S4Vectors::DataFrame(
      protein = c("P1", "P1", "P2", "P2", "P1", "P1", "P1"),
      protein_site = c(1L, 1L, 1L, 2L, 1L, 2L, 1L),
      glycan_structure = structures,
      glycan_composition = glyrepr::as_glycan_composition(structures)
    ),
    metadata = list(glycan_type = "N")
  )
}

test_that("top ten counts deduplicate glycoforms and rank both sides independently", {
  x <- top10_fixture()
  p <- plot_top10_bar(x)
  expect_s3_class(p, "tidyplot")
  expect_null(p$labels$title)
  expect_equal(p$data$value, c(3, 2, 1, 2, 1))
  expect_equal(p$data$rank, c(1L, 2L, 3L, 1L, 2L))
  expect_equal(p$data$signed_value, c(-3, -2, -1, 2, 1))
  expect_false(any(
    p$data$type[p$data$side == "Excluding oligomannose"] == "oligomannose"
  ))
  SummarizedExperiment::assay(x)[] <- NA_real_
  expect_equal(plot_top10_bar(x)$data, p$data)
})

test_that("abundance ranking sums duplicate measurements and all samples", {
  x <- top10_fixture()
  p <- plot_top10_bar(x, weight = "abundance")
  expect_equal(p$data$value, c(200, 60, 16, 200, 60))
  expect_equal(p$data$rank, c(1L, 2L, 3L, 1L, 2L))
  expect_equal(
    sum(p$data$value[1:3]),
    sum(SummarizedExperiment::assay(x), na.rm = TRUE)
  )
})

test_that("top ten selection is capped and ties do not depend on input order", {
  x <- top10_fixture()
  core <- as.character(SummarizedExperiment::rowData(x)$glycan_structure[5])
  structures <- glyparse::auto_parse(vapply(
    1:12,
    function(n) {
      paste0(strrep("Gal(b1-4)", n), core)
    },
    character(1)
  ))
  x <- glyexp::GlycoproteomicSE(
    matrix(1, 12, 2),
    rowData = S4Vectors::DataFrame(
      protein = rep("P1", 12),
      protein_site = rep(1L, 12),
      glycan_structure = structures,
      glycan_composition = glyrepr::as_glycan_composition(structures)
    ),
    metadata = list(glycan_type = "N")
  )
  p <- plot_top10_bar(x)
  expect_equal(nrow(p$data), 20L)
  expect_equal(p$data$rank, rep(1:10, 2))
  expect_equal(p$data$value, rep(1, 20))
  expect_equal(p$data, plot_top10_bar(x[12:1, ])$data)
})

test_that("cartoons render, bars descend, and colours follow the glyvis palette", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  p <- plot_top10_bar(top10_fixture(), title = "Top glycans")
  expect_equal(
    p$tidyplot[c("width", "height", "unit")],
    list(width = 50, height = 50, unit = "mm")
  )
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_equal(unique(built$fill), glyvis_colors[1:2])
  expect_equal(built$y, c(-1, -2, -3, -1, -2))
  expect_equal(built$xmin, c(-3, -2, -1, 0, 0))
  expect_equal(built$xmax, c(0, 0, 0, 2, 1))
  expect_equal(p$labels$title, "Top glycans")
  cartoons <- ggplot2::ggplot_build(p)$data[[2]]
  expect_equal(nrow(cartoons), nrow(p$data))
  expect_equal(cartoons$angle, c(0, 0, 0, 180, 180))
  expect_true(all(abs(cartoons$x) > p$data$value))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
  p <- plot_top10_bar(
    top10_fixture(),
    palette = c(
      "Excluding oligomannose" = "#111111",
      "Including oligomannose" = "#222222"
    )
  )
  expect_equal(
    unique(ggplot2::ggplot_build(p)$data[[1]]$fill),
    c("#222222", "#111111")
  )
  single <- plot_top10_bar(top10_fixture()[1, ])
  expect_equal(nrow(single$data), 1L)
  expect_s3_class(ggplot2::ggplotGrob(single), "gtable")
  expect_error(
    plot_top10_bar(top10_fixture(), unsupported = TRUE),
    "must be empty"
  )
})

test_that("only annotated N-glycoproteomic input and suitable abundances are accepted", {
  x <- top10_fixture()
  plain <- methods::as(x, "SummarizedExperiment")
  for (input in list(
    plain,
    glyexp::as_glycomic_se(plain),
    structure(list(), class = "glyexp_experiment")
  )) {
    expect_error(plot_top10_bar(input), "GlycoproteomicSE")
  }
  expect_error(plot_top10_bar(x, "invalid"), "weight")
  expect_error(plot_top10_bar(x[FALSE, ]), "No eligible")
  S4Vectors::metadata(x)$glycan_type <- "O"
  expect_error(plot_top10_bar(x), "glycan_type")
  S4Vectors::metadata(x)$glycan_type <- "N"
  S4Vectors::metadata(x)$scale <- "log2"
  expect_error(plot_top10_bar(x, "abundance"), "linear-scale")
  S4Vectors::metadata(x)$scale <- "raw"
  for (value in c(-1, Inf, NA_real_, 0)) {
    S4Vectors::metadata(x)$scale <- "log2"
    SummarizedExperiment::assay(x)[] <- value
    S4Vectors::metadata(x)$scale <- "raw"
    expect_error(plot_top10_bar(x, "abundance"), "non-negative|positive")
  }
  SummarizedExperiment::rowData(x)$protein[1] <- NA_character_
  expect_error(plot_top10_bar(x), "non-missing")
  SummarizedExperiment::rowData(x)$glycan_structure <- NULL
  expect_error(plot_top10_bar(x), "Missing row annotations")
})

test_that("excluded structures follow N-glycan summary rules", {
  x <- top10_fixture()[c(1, 5, 7), ]
  SummarizedExperiment::rowData(x)$glycan_structure[1] <- NA
  expect_warning(p <- plot_top10_bar(x), "Excluded 1 row")
  expect_equal(p$data$value, rep(1, 4))
  expect_warning(
    expect_error(plot_top10_bar(x[1, ]), "No eligible"),
    "Excluded 1 row"
  )
})

test_that("input preparation preserves original glycan identity after deduplication", {
  x <- top10_fixture()[1:2, ]
  s <- as.character(SummarizedExperiment::rowData(x)$glycan_structure)
  s[2] <- sub("GlcNAc\\(b1-$", "GlcNAc-ol(b1-", s[2])
  SummarizedExperiment::rowData(x)$glycan_structure <- glyparse::auto_parse(s)
  input <- .n_plot_input(x, "equal")
  expect_equal(length(unique(input$structures)), 2L)
  expect_equal(length(unique(input$glycans)), 1L)
  expect_equal(nrow(input$abundance), 2L)
})
