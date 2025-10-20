test_that("plot_plsda works with glystats_plsda_res", {
  suppressMessages(plsda_res <- glystats::gly_plsda(exp_for_plsda()))
  p <- plot_plsda(plsda_res)
  vdiffr::expect_doppelganger("plot_plsda_glystats_plsda_res", p)
})

test_that("plot_plsda works with glyexp_experiment", {
  suppressMessages(p <- plot_plsda(exp_for_plsda()))
  vdiffr::expect_doppelganger("plot_plsda_glyexp_experiment", p)
})