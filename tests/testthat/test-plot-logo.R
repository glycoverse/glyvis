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

test_that("plot_logo failed with no fasta and no site_sequence", {
  exp <- test_gp_exp
  expect_error(plot_logo(exp), "`fasta` is required to add site sequence information.")
})