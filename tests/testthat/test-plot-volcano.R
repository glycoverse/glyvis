skip_on_ci()
skip_on_cran()
skip_if_not_installed("limma")

test_that("plot_volcano works with default parameters", {
  suppressMessages(
    sub_exp <- subset_test_gp_se(groups = c("C", "H"))
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
  sub_exp <- subset_test_gp_se(groups = c("C", "H"))
  suppressMessages(
    sub_exp <- set_test_gp_col(
      sub_exp,
      "treatment",
      SummarizedExperiment::colData(sub_exp)$group
    )
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
    ttest_res <- subset_test_gp_se(groups = c("C", "H")) |>
      glystats::gly_ttest()
  )
  vdiffr::expect_doppelganger(
    "plot_volcano_ttest_res",
    plot_volcano(ttest_res)
  )
})

test_that("plot_volcano works for glystats_wilcox_res", {
  suppressMessages(
    wilcox_res <- subset_test_gp_se(groups = c("C", "H")) |>
      glystats::gly_wilcox()
  )
  vdiffr::expect_doppelganger(
    "plot_volcano_wilcox_res",
    plot_volcano(wilcox_res)
  )
})

test_that("plot_volcano works for glystats_limma_res", {
  suppressMessages(
    limma_res <- subset_test_gp_se(groups = c("C", "H")) |>
      glystats::gly_limma()
  )
  vdiffr::expect_doppelganger(
    "plot_volcano_limma_res",
    plot_volcano(limma_res)
  )
})

test_that("plot_volcano works for glystats_limma_res with contrast", {
  exp <- set_test_gp_col(
    col = "group",
    value = factor(
      SummarizedExperiment::colData(test_gp_se)$group,
      levels = c("H", "M", "Y", "C")
    )
  )
  suppressMessages(
    limma_res <- glystats::gly_limma(exp)
  )
  p1 <- plot_volcano(limma_res, contrast = "H_vs_C")
  p2 <- plot_volcano(limma_res, contrast = "Y_vs_C")
  vdiffr::expect_doppelganger(
    "plot_volcano_limma_res_contrast",
    patchwork::wrap_plots(p1, p2)
  )
})
