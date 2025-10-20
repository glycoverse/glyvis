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
    p <- plot_volcano(sub_exp, group_col = "treatment")
  )

  vdiffr::expect_doppelganger(
    "plot_volcano_custom_group_col",
    p
  )
})

test_that("plot_volcano works with custom p_adj_method", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H"))
  )

  suppressMessages(
    p <- plot_volcano(sub_exp, p_adj_method = "bonferroni")
  )

  vdiffr::expect_doppelganger(
    "plot_volcano_bonferroni",
    p
  )
})

test_that("plot_volcano works with no p-value adjustment", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H"))
  )

  suppressMessages(
    p <- plot_volcano(sub_exp, p_adj_method = NULL)
  )

  vdiffr::expect_doppelganger(
    "plot_volcano_no_adjustment",
    p
  )
})

test_that("plot_volcano works with custom ref_group", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H"))
  )

  suppressMessages(
    p <- plot_volcano(sub_exp, ref_group = "H")
  )

  vdiffr::expect_doppelganger(
    "plot_volcano_custom_ref_group",
    p
  )
})

test_that("plot_volcano fails with invalid group_col", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H"))
  )

  expect_error(
    plot_volcano(sub_exp, group_col = 123),
    "Must be of type 'string'"
  )
})

test_that("plot_volcano fails with invalid p_adj_method", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H"))
  )

  expect_error(
    plot_volcano(sub_exp, p_adj_method = "invalid_method"),
    "Must be element of set"
  )
})

test_that("plot_volcano fails with more than 2 groups", {
  expect_error(
    suppressMessages(plot_volcano(test_gp_exp)),
    "exactly 2 levels"
  )
})

test_that("plot_volcano fails with only 1 group", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group == "C")
  )

  expect_error(
    plot_volcano(sub_exp),
    "exactly 2 levels"
  )
})

test_that("plot_volcano fails with non-existent group_col", {
  suppressMessages(
    sub_exp <- test_gp_exp |>
      glyexp::filter_obs(group %in% c("C", "H"))
  )

  expect_error(
    plot_volcano(sub_exp, group_col = "non_existent_col"),
    "not found in sample information"
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