test_that("autoplot works for glystats_pca_res", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_individual",
    autoplot(pca_res)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_variables",
    autoplot(pca_res, type = "variables")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_screeplot",
    autoplot(pca_res, type = "screeplot")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_biplot",
    autoplot(pca_res, type = "biplot")
  )
})

test_that("autoplot works for glystats_pca_res with groups parameter", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with explicit groups parameter
  groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", "D")

  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_individual_with_groups",
    autoplot(pca_res, type = "individual", groups = groups)
  )

  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_biplot_with_groups",
    autoplot(pca_res, type = "biplot", groups = groups)
  )
})

test_that("autoplot works for glystats_pca_res with group_col parameter", {
  set.seed(1234)
  suppressMessages(
    pca_res_with_group <- glystats::gly_pca(test_gp_exp)
  )

  # Test with group_col parameter (using existing "group" column)
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_individual_with_group_col",
    autoplot(pca_res_with_group, type = "individual", group_col = "group")
  )

  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_biplot_with_group_col",
    autoplot(pca_res_with_group, type = "biplot", group_col = "group")
  )
})

test_that("autoplot automatically uses 'group' column when available", {
  set.seed(1234)
  suppressMessages(
    pca_res_with_group <- glystats::gly_pca(test_gp_exp)
  )

  # Test automatic detection of "group" column
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_individual_auto_group",
    autoplot(pca_res_with_group, type = "individual")
  )

  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_biplot_auto_group",
    autoplot(pca_res_with_group, type = "biplot")
  )
})

test_that("autoplot works without groups when no group info available", {
  set.seed(1234)
  suppressMessages(
    pca_res_no_group <- test_gp_exp |>
      glyexp::select_obs(-group) |>
      glystats::gly_pca()
  )

  # Test without any group information
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_individual_no_group",
    autoplot(pca_res_no_group, type = "individual")
  )

  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_biplot_no_group",
    autoplot(pca_res_no_group, type = "biplot")
  )
})

test_that("autoplot validates groups parameter correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with wrong length groups
  wrong_groups <- c("A", "B", "C")  # Should be 12 elements
  expect_error(
    autoplot(pca_res, groups = wrong_groups),
    "Length of.*groups.*must be equal to the number of samples"
  )
})

test_that("autoplot validates group_col parameter correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with non-existent group_col
  expect_error(
    autoplot(pca_res, group_col = "nonexistent_column"),
    "Column.*nonexistent_column.*not found"
  )
})

test_that("groups parameter takes precedence over group_col", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # When both groups and group_col are provided, groups should be used
  groups <- c("X", "X", "X", "Y", "Y", "Y", "Z", "Z", "Z", "W", "W", "W")

  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_groups_precedence",
    autoplot(pca_res, type = "individual", groups = groups, group_col = "group")
  )
})

test_that("autoplot type validation works correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test invalid type
  expect_error(
    autoplot(pca_res, type = "invalid_type"),
    "Must be element of set"
  )
})

test_that("groups parameter accepts both factor and character", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with character groups
  char_groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", "D")
  expect_no_error(
    autoplot(pca_res, type = "individual", groups = char_groups)
  )

  # Test with factor groups
  factor_groups <- factor(char_groups)
  expect_no_error(
    autoplot(pca_res, type = "individual", groups = factor_groups)
  )
})