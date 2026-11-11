skip_if_not_installed("glydet", "0.14.0")
skip_if_not_installed("glydraw", "0.9.0")
skip_if_not_installed("glymotif", "1.0.1")
skip_if_not_installed("glyparse", "1.0.1")
skip_if_not_installed("glyrepr", "1.2.0")

o_plot_fixture <- function(structures = .o_core_cartoons(), protein = NULL) {
  structures <- glyparse::auto_parse(structures)
  rows <- S4Vectors::DataFrame(
    glycan_structure = structures,
    glycan_composition = glyrepr::as_glycan_composition(structures)
  )
  constructor <- glyexp::GlycomicSE
  if (!is.null(protein)) {
    rows$protein <- protein
    rows$protein_site <- rep(10L, length(structures))
    constructor <- glyexp::GlycoproteomicSE
  }
  constructor(
    matrix(seq_along(structures), length(structures), 2),
    rowData = rows,
    metadata = list(glycan_type = "O")
  )
}

test_that("core sets classify mutually exclusively with matching cartoons", {
  x <- o_plot_fixture()
  expect_warning(p <- plot_o_type_pie(x), "Excluded 4")
  expect_equal(p$data$value, rep(1, 4))
  expect_equal(p$data$proportion, rep(0.25, 4))
  q <- plot_o_type_pie(x, core_set = "8cores")
  expect_equal(as.character(q$data$category), paste("Core", 1:8))
  expect_equal(q$data$value, rep(1, 8))
  expect_equal(
    unname(.o_core_index(glyparse::auto_parse(q$data$glycan_structure))),
    1:8
  )
  expect_equal(plot_o_type_pie(x, "abundance", "8cores")$data$value, 2 * (1:8))
})

test_that("extensions and reduction preserve classification and identity", {
  core <- .o_core_cartoons()[1]
  extended <- paste0("Neu5Ac(a2-3)", core)
  reduced <- sub("GalNAc\\(a1-$", "GalNAc-ol(a1-", core)
  x <- o_plot_fixture(c(core, core, extended, reduced))
  expect_equal(plot_o_type_pie(x)$data$value, c(3, 0, 0, 0))
  gp <- o_plot_fixture(c(core, core, core), c("P1", "P1", "P2"))
  expect_equal(plot_o_type_pie(gp)$data$value, c(2, 0, 0, 0))
})

test_that("excluded structures and invalid inputs are handled explicitly", {
  x <- o_plot_fixture(c(.o_core_cartoons()[1], NA, "GalNAc(a1-", "Man(a1-"))
  expect_warning(p <- plot_o_type_pie(x), "Excluded 3")
  expect_equal(p$data$proportion, c(1, 0, 0, 0))
  expect_warning(
    expect_error(plot_o_type_pie(x[-1, ]), "No eligible"),
    "Excluded"
  )
  expect_error(plot_o_type_pie(x, core_set = "other"), "core_set")
  expect_error(plot_o_type_pie(x, weight = "other"), "weight")
  S4Vectors::metadata(x)$glycan_type <- "N"
  expect_error(plot_o_type_pie(x), "glycan_type")
})

test_that("four and eight core pies render zero and highly uneven categories", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  for (set in c("4cores", "8cores")) {
    for (structures in list(.o_core_cartoons()[1], .o_core_cartoons()[1:4])) {
      p <- plot_o_type_pie(
        o_plot_fixture(structures),
        core_set = set,
        title = "O cores"
      )
      expect_s3_class(p, "tidyplot")
      expect_equal(p$labels$title, "O cores")
      expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
      labels <- p$layers[[3]]$data
      pairs <- utils::combn(nrow(labels), 2)
      expect_false(any(apply(pairs, 2, \(ids) {
        all(
          c(abs(diff(labels$label_x[ids])), abs(diff(labels$label_y[ids]))) <
            c(sum(labels$box_width[ids]), sum(labels$box_height[ids])) /
              2 -
              1e-9
        )
      })))
    }
  }
})
