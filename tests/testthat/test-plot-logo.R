skip_on_ci()
skip_on_cran()


test_that("plot_logo works with site_sequence column", {
  suppressMessages(
    exp <- test_gp_exp |>
      glyclean::add_site_seq("filtered_uniprotkb.fasta")
  )
  p <- plot_logo(exp)
  vdiffr::expect_doppelganger("plot_logo_with_site_sequence", p)
})

test_that("plot_logo works with fasta file", {
  exp <- test_gp_exp
  suppressMessages(p <- plot_logo(exp, fasta = "filtered_uniprotkb.fasta"))
  vdiffr::expect_doppelganger("plot_logo_with_fasta_file", p)
})

test_that("plot_logo works with custom n_aa", {
  exp <- test_gp_exp
  suppressMessages(p <- plot_logo(exp, n_aa = 3, fasta = "filtered_uniprotkb.fasta"))
  vdiffr::expect_doppelganger("plot_logo_with_custom_n_aa", p)
})

test_that("plot_logo works with UniProt.ws fallback", {
  skip_if_not_installed("UniProt.ws")
  skip_if_offline()
  exp <- test_gp_exp
  suppressMessages(p <- plot_logo(exp, tax_id = 9606))
  vdiffr::expect_doppelganger("plot_logo_with_uniprot", p)
})

test_that("plot_logo fails when protein metadata is missing", {
  exp <- test_gp_exp
  exp$var_info <- dplyr::select(exp$var_info, -protein)
  expect_error(plot_logo(exp), "protein")
})
