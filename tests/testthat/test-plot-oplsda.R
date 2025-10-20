skip_on_ci()
skip_on_cran()

test_that("plot_oplsda works with glystats_oplsda_res", {
  set.seed(1234)
  suppressMessages(oplsda_res <- glystats::gly_oplsda(exp_for_oplsda(), ortho_i = 1))
  p <- plot_oplsda(oplsda_res)
  vdiffr::expect_doppelganger("plot_oplsda_glystats_oplsda_res", p)
})

test_that("plot_oplsda works with glyexp_experiment", {
  set.seed(1234)
  suppressMessages(p <- plot_oplsda(exp_for_oplsda(), stats_args = list(ortho_i = 1)))
  vdiffr::expect_doppelganger("plot_oplsda_glyexp_experiment", p)
})