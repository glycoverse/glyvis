test_that("autoplot works for glystats DEA results", {
  suppressMessages(
    ttest_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_ttest()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_ttest_res",
    autoplot(ttest_res)
  )

  suppressMessages(
    wilcox_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_wilcox()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_wilcox_res",
    autoplot(wilcox_res)
  )

  suppressMessages(
    anova_res <- glystats::gly_anova(test_gp_exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_anova_res",
    autoplot(anova_res)
  )

  suppressMessages(
    kruskal_res <- glystats::gly_kruskal(test_gp_exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_kruskal_res",
    autoplot(kruskal_res)
  )

  suppressMessages(
    limma_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_limma()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_limma_res",
    autoplot(limma_res)
  )
})
