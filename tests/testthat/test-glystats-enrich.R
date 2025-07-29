skip_on_ci()
skip_on_cran()
skip_if_not_installed("clusterProfiler")
skip("Enrichment functions are too slow.")

test_that("autoplot works for glystats go enrich results", {
  suppressMessages(go_res <- glystats::gly_enrich_go(test_gp_exp))

  vdiffr::expect_doppelganger(
    "autoplot.glystats_go_ora_res",
    autoplot(go_res)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_go_ora_res_barplot",
    autoplot(go_res, type = "barplot")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_go_ora_res_network",
    autoplot(go_res, type = "network")
  )
})

test_that("autoplot works for glystats kegg enrich results", {
  skip_if_offline()
  suppressMessages(kegg_res <- glystats::gly_enrich_kegg(test_gp_exp))

  vdiffr::expect_doppelganger(
    "autoplot.glystats_kegg_ora_res",
    autoplot(kegg_res)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_kegg_ora_res_barplot",
    autoplot(kegg_res, type = "barplot")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_kegg_ora_res_network",
    autoplot(kegg_res, type = "network")
  )
})

test_that("autoplot works for glystats reactome enrich results", {
  skip_if_offline()
  suppressMessages(reactome_res <- glystats::gly_enrich_reactome(test_gp_exp))

  vdiffr::expect_doppelganger(
    "autoplot.glystats_reactome_ora_res",
    autoplot(reactome_res)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_reactome_ora_res_barplot",
    autoplot(reactome_res, type = "barplot")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_reactome_ora_res_network",
    autoplot(reactome_res, type = "network")
  )
})