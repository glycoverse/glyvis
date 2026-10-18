skip_on_ci()
skip_on_cran()


test_that("plot_logo works with site_sequence column", {
  suppressMessages(
    exp <- test_gp_se |>
      glyclean::add_site_seq("filtered_uniprotkb.fasta")
  )
  p <- plot_logo(exp)
  vdiffr::expect_doppelganger("plot_logo_with_site_sequence", p)
})

test_that("plot_logo works with fasta file", {
  exp <- test_gp_se
  suppressMessages(p <- plot_logo(exp, fasta = "filtered_uniprotkb.fasta"))
  vdiffr::expect_doppelganger("plot_logo_with_fasta_file", p)
})

test_that("plot_logo works with custom n_aa", {
  exp <- test_gp_se
  suppressMessages(
    p <- plot_logo(exp, n_aa = 3, fasta = "filtered_uniprotkb.fasta")
  )
  vdiffr::expect_doppelganger("plot_logo_with_custom_n_aa", p)
})

test_that("plot_logo uses fetched sequences on the tidyplots canvas", {
  captured <- NULL
  local_mocked_bindings(.add_site_seq_uniprot = function(exp, n_aa, tax_id) {
    captured <<- list(n_aa = n_aa, tax_id = tax_id)
    SummarizedExperiment::rowData(exp)$site_sequence <- rep(
      c("AAAAANSTAAA", "GGGGGNSSGGG"),
      length.out = nrow(exp)
    )
    exp
  })
  p <- plot_logo(test_gp_se, tax_id = 9606L, logo_args = list(method = "prob"))
  expect_equal(captured, list(n_aa = 5L, tax_id = 9606L))
  expect_s3_class(p, "tidyplot")
  vdiffr::expect_doppelganger("plot_logo_with_uniprot", p)
})

test_that("plot_logo fails when protein metadata is missing", {
  exp <- test_gp_se
  SummarizedExperiment::rowData(exp)$protein <- NULL
  expect_error(plot_logo(exp), "protein")
})
