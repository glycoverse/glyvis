skip_on_ci()
skip_on_cran()
skip_if_not_installed("limma")

test_that("plot_volcano works with default parameters", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H"))
  )

  suppressMessages(
    p <- plot_volcano(sub_exp)
  )

  vdiffr::expect_doppelganger(
    "plot_volcano_default",
    p
  )
})

test_that("plot_volcano works with custom group_col", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glyexp::mutate_obs(treatment = group)
  )

  suppressMessages(
    p <- plot_volcano(sub_exp, stats_args = list(group_col = "treatment"))
  )

  vdiffr::expect_doppelganger(
    "plot_volcano_custom_group_col",
    p
  )
})

test_that("plot_volcano works for glystats_ttest_res", {
  suppressMessages(
    ttest_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_ttest()
  )
  vdiffr::expect_doppelganger(
    "plot_volcano_ttest_res",
    plot_volcano(ttest_res)
  )
})

test_that("plot_volcano works for glystats_wilcox_res", {
  suppressMessages(
    wilcox_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_wilcox()
  )
  vdiffr::expect_doppelganger(
    "plot_volcano_wilcox_res",
    plot_volcano(wilcox_res)
  )
})

test_that("plot_volcano works for glystats_limma_res", {
  suppressMessages(
    limma_res <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H")) |>
      glystats::gly_limma()
  )
  vdiffr::expect_doppelganger(
    "plot_volcano_limma_res",
    plot_volcano(limma_res)
  )
})

test_that("plot_volcano works for glystats_limma_res with contrast", {
  suppressMessages(
    limma_res <- test_gp_exp |>
      glyexp::mutate_obs(group = factor(group, levels = c("H", "M", "Y", "C"))) |>
      glystats::gly_limma()
  )
  p1 <- plot_volcano(limma_res, contrast = "H_vs_C")
  p2 <- plot_volcano(limma_res, contrast = "Y_vs_C")
  vdiffr::expect_doppelganger(
    "plot_volcano_limma_res_contrast",
    patchwork::wrap_plots(p1, p2)
  )
})