skip("Enrichment functions are too slow.")

test_that("plot_enrich works with glystats_go_ora_res", {
  suppressMessages(enrich_res <- glystats::gly_enrich_go(test_gp_exp))
  p <- plot_enrich(enrich_res)
  vdiffr::expect_doppelganger("plot_enrich_glystats_go_ora_res", p)
})

test_that("plot_enrich works with glystats_kegg_ora_res", {
  suppressMessages(enrich_res <- glystats::gly_enrich_kegg(test_gp_exp))
  p <- plot_enrich(enrich_res)
  vdiffr::expect_doppelganger("plot_enrich_glystats_kegg_ora_res", p)
})

test_that("plot_enrich works with glystats_reactome_ora_res", {
  suppressMessages(enrich_res <- glystats::gly_enrich_reactome(test_gp_exp))
  p <- plot_enrich(enrich_res)
  vdiffr::expect_doppelganger("plot_enrich_glystats_reactome_ora_res", p)
})

test_that("plot_enrich works with glyexp_experiment and enrich_type = 'go'", {
  p <- plot_enrich(test_gp_exp, enrich_type = "go")
  vdiffr::expect_doppelganger("plot_enrich_glyexp_experiment_go", p)
})

test_that("plot_enrich works with glyexp_experiment and enrich_type = 'kegg'", {
  p <- plot_enrich(test_gp_exp, enrich_type = "kegg")
  vdiffr::expect_doppelganger("plot_enrich_glyexp_experiment_kegg", p)
})

test_that("plot_enrich works with glyexp_experiment and enrich_type = 'reactome'", {
  p <- plot_enrich(test_gp_exp, enrich_type = "reactome")
  vdiffr::expect_doppelganger("plot_enrich_glyexp_experiment_reactome", p)
})