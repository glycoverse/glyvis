test_that("autoplot works for glystats_dea_res", {
  suppressMessages(
    ttest_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_ttest()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_dea_res_ttest",
    autoplot(ttest_res)
  )

  suppressMessages(
    wilcox_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_wilcox()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_dea_res_wilcoxon",
    autoplot(wilcox_res)
  )

  suppressMessages(
    anova_res <- glystats::gly_anova(test_gp_exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_dea_res_anova",
    autoplot(anova_res)
  )

  suppressMessages(
    kruskal_res <- glystats::gly_kruskal(test_gp_exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_dea_res_kruskal",
    autoplot(kruskal_res)
  )
})
