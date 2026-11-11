skip_if_not_installed("glydet", "0.14.0")
skip_if_not_installed("glydraw", "0.9.0")
skip_if_not_installed("glymotif", "1.0.1")
skip_if_not_installed("glyparse", "1.0.1")
skip_if_not_installed("glyrepr", "1.2.0")

n_plot_fixture <- function(
  structures,
  abundance = NULL,
  protein = NULL,
  site = NULL
) {
  structures <- glyparse::auto_parse(structures)
  if (is.null(abundance)) {
    abundance <- matrix(1, length(structures), 2)
  }
  rows <- S4Vectors::DataFrame(
    glycan_composition = glyrepr::as_glycan_composition(structures),
    glycan_structure = structures
  )
  constructor <- glyexp::GlycomicSE
  if (!is.null(protein)) {
    rows$protein <- protein
    rows$protein_site <- as.integer(site)
    constructor <- glyexp::GlycoproteomicSE
  }
  constructor(abundance, rowData = rows, metadata = list(glycan_type = "N"))
}

n_plot_structures <- function() {
  c(
    both = "Man(a1-3)[GlcNAc(b1-4)][Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-",
    fuc = "Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-",
    bisect = "Man(a1-3)[GlcNAc(b1-4)][Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    bare = "Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    hybrid = "Gal(b1-4)GlcNAc(b1-2)Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    complex = "Gal(b1-4)GlcNAc(b1-2)Man(a1-3)[Gal(b1-4)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    mixed = "Gal(b1-4)GlcNAc(b1-2)Man(a1-3)[GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    arm_fuc = "Gal(b1-4)[Fuc(a1-3)]GlcNAc(b1-2)Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-"
  )
}

test_that("core categories distinguish all combinations and antennal fucose", {
  s <- n_plot_structures()
  x <- n_plot_fixture(s[c("both", "fuc", "bisect", "bare", "arm_fuc")])
  p <- plot_n_core_pie(x)
  expect_s3_class(p, "tidyplot")
  expect_equal(p$data$value, c(1, 1, 1, 2))
  expect_equal(p$data$proportion, c(1, 1, 1, 2) / 5)
  expect_equal(glydet::n_core_fuc(p$data$glycan_structure), c(1L, 1L, 0L, 0L))
  expect_equal(
    glydet::has_bisecting(p$data$glycan_structure),
    c(TRUE, FALSE, TRUE, FALSE)
  )
})

test_that("equal weighting counts glycans or site-specific glycoforms once", {
  s <- n_plot_structures()
  structures <- s[c("bare", "bare", "bare", "fuc")]
  x <- n_plot_fixture(structures)
  expect_equal(plot_n_core_pie(x)$data$value, c(0, 1, 0, 1))
  gp <- n_plot_fixture(
    structures,
    protein = c("P1", "P1", "P1", "P2"),
    site = c("10", "10", "20", "10")
  )
  expect_equal(plot_n_core_pie(gp)$data$value, c(0, 1, 0, 2))
  SummarizedExperiment::assay(gp)[] <- NA_real_
  expect_equal(plot_n_core_pie(gp)$data$value, c(0, 1, 0, 2))
})

test_that("abundance weights pool samples and duplicate measurements", {
  s <- n_plot_structures()
  x <- n_plot_fixture(
    s[c("both", "fuc", "bisect", "bare", "bare")],
    matrix(c(1, 2, 3, 4, 5, 10, 20, NA, 40, 50), 5)
  )
  p <- plot_n_core_pie(x, weight = "abundance")
  expect_equal(p$data$value, c(11, 22, 3, 99))
  expect_equal(p$data$proportion, c(11, 22, 3, 99) / 135)
  expect_equal(sum(p$data$proportion), 1)
  gp <- n_plot_fixture(
    s[c("bare", "bare", "fuc")],
    matrix(c(1, 10, 100), 3),
    protein = c("P1", "P2", "P1"),
    site = c("10", "20", "10")
  )
  expect_equal(plot_n_core_pie(gp, "abundance")$data$value, c(0, 100, 0, 11))
})

test_that("types merge mannose classes and cartoons represent their categories", {
  s <- n_plot_structures()
  x <- n_plot_fixture(s[c("bare", "hybrid", "complex")], matrix(c(1, 2, 7), 3))
  p <- plot_n_type_pie(x, "abundance")
  expect_equal(
    as.character(p$data$category),
    c("oligomannose", "hybrid", "complex")
  )
  expect_equal(p$data$value, c(1, 2, 7))
  expect_equal(
    as.character(glydet::n_glycan_type(p$data$glycan_structure, TRUE)),
    c("oligo-mannose", "hybrid", "complex")
  )
})

test_that("branch bars count presence, exclude bisection, and allow overlaps", {
  s <- n_plot_structures()
  x <- n_plot_fixture(
    s[c("hybrid", "complex", "mixed", "bisect")],
    matrix(c(1, 2, 4, 8), 4)
  )
  p <- plot_n_branch_bar(x)
  # Gal-GlcNAc occurs twice on the complex glycan, but contributes only once.
  expect_equal(sort(p$data$value), c(1, 3))
  expect_equal(sort(p$data$proportion), c(0.25, 0.75))
  q <- plot_n_branch_bar(x, "abundance")
  expect_equal(sort(q$data$value), c(4, 7))
  expect_equal(sort(q$data$proportion), c(4, 7) / 15)
  expect_true(all(q$data$cartoon_y > q$data$value))
  expect_setequal(
    as.character(glyparse::auto_parse(q$data$glycan_structure)),
    as.character(glymotif::extract_branch_motif(
      SummarizedExperiment::rowData(x)$glycan_structure
    ))
  )
  expect_error(
    plot_n_branch_bar(n_plot_fixture(s["bare"])),
    "No N-glycan branch"
  )
})

test_that("reduction does not change categories but retains glycoform identity", {
  s <- n_plot_structures()["both"]
  # Replace the reducing end only; there is also an internal GlcNAc.
  reduced <- sub("GlcNAc\\(b1-$", "GlcNAc-ol(b1-", s)
  x <- n_plot_fixture(c(s, reduced))
  expect_equal(plot_n_core_pie(x)$data$value, c(2, 0, 0, 0))
})

test_that("missing and non-N structures are excluded with a clear denominator", {
  x <- n_plot_fixture(c(n_plot_structures()["bare"], NA, "Gal(b1-3)GalNAc(a1-"))
  expect_warning(p <- plot_n_core_pie(x), "Excluded 2 rows")
  expect_equal(p$data$value, c(0, 0, 0, 1))
  expect_equal(sum(p$data$proportion), 1)
  expect_warning(
    expect_error(plot_n_core_pie(x[2:3, ]), "No eligible"),
    "Excluded 2"
  )
})

test_that("invalid inputs and unquantifiable abundance fail explicitly", {
  x <- n_plot_fixture(n_plot_structures()["bare"])
  expect_error(plot_n_core_pie(x, "other"), "weight")
  expect_error(plot_n_type_pie(list()), "class")
  expect_error(plot_n_core_pie(x[FALSE, ]), "No eligible")
  S4Vectors::metadata(x)$glycan_type <- "O"
  expect_error(plot_n_core_pie(x), "glycan_type")
  S4Vectors::metadata(x)$glycan_type <- "N"
  S4Vectors::metadata(x)$scale <- "log2"
  expect_error(plot_n_type_pie(x, "abundance"), "linear-scale")
  S4Vectors::metadata(x)$scale <- "raw"
  for (value in c(0, NA_real_, Inf)) {
    SummarizedExperiment::assay(x)[] <- value
    expect_error(plot_n_core_pie(x, "abundance"), "positive|non-negative")
  }
  S4Vectors::metadata(x)$scale <- "log2"
  SummarizedExperiment::assay(x)[] <- -1
  S4Vectors::metadata(x)$scale <- "raw"
  expect_error(plot_n_core_pie(x, "abundance"), "non-negative")
  SummarizedExperiment::assay(x)[] <- 1
  SummarizedExperiment::rowData(x)$glycan_structure <- NULL
  expect_error(plot_n_core_pie(x), "Missing row annotations")
})

test_that("legacy containers retain the same weighting semantics", {
  x <- n_plot_fixture(n_plot_structures()[c("bare", "fuc")])
  legacy <- structure(
    list(
      expr_mat = SummarizedExperiment::assay(x),
      var_info = tibble::as_tibble(SummarizedExperiment::rowData(x)),
      sample_info = tibble::tibble(sample = colnames(x)),
      meta_data = list(exp_type = "glycomics", glycan_type = "N", scale = "raw")
    ),
    class = "glyexp_experiment"
  )
  expect_equal(
    suppressWarnings(plot_n_core_pie(legacy))$data$value,
    plot_n_core_pie(x)$data$value
  )
})

test_that("plots build with cartoons, zero categories, and common styling", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  x <- n_plot_fixture(n_plot_structures()[c("bare", "mixed")])
  for (plot in list(plot_n_core_pie, plot_n_type_pie, plot_n_branch_bar)) {
    p <- plot(x, title = "N glycans", fontsize = 10)
    expect_equal(p$labels$title, "N glycans")
    expect_true(any(vapply(
      p$layers,
      function(layer) inherits(layer$geom, "GeomGlycan"),
      logical(1)
    )))
    expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
    expect_error(plot(x, unsupported = TRUE), "must be empty")
  }
  single <- plot_n_core_pie(n_plot_fixture(n_plot_structures()["bare"]))
  expect_equal(
    unique(ggplot2::ggplot_build(single)$data[[1]]$fill),
    glyvis_colors[4]
  )
})

test_that("zero-abundance branches remain visible without a false positive bar", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  x <- n_plot_fixture(
    n_plot_structures()[c("bare", "mixed")],
    matrix(c(1, 0), 2)
  )
  p <- plot_n_branch_bar(x, "abundance")
  expect_equal(p$data$value, c(0, 0))
  expect_true(all(p$data$cartoon_y > 0))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
})
