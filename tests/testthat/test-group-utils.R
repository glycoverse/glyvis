skip_on_ci()
skip_on_cran()

# Test .prepare_groups function through autoplot.glystats_pca_res
# Using type = "individual" as the test scenario

test_that(".prepare_groups works with explicit groups parameter (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with explicit groups parameter
  groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", "D")
  names(groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3")

  vdiffr::expect_doppelganger(
    "group_utils_explicit_groups",
    autoplot(pca_res, type = "individual", groups = groups)
  )
})

test_that(".prepare_groups works with group_col parameter (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res_with_group <- glystats::gly_pca(test_gp_exp)
  )

  # Test with group_col parameter (using existing "group" column)
  vdiffr::expect_doppelganger(
    "group_utils_group_col",
    autoplot(pca_res_with_group, type = "individual", group_col = "group")
  )
})

test_that(".prepare_groups automatically uses 'group' column when available (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res_with_group <- glystats::gly_pca(test_gp_exp)
  )

  # Test automatic detection of "group" column
  vdiffr::expect_doppelganger(
    "group_utils_auto_group",
    autoplot(pca_res_with_group, type = "individual")
  )
})

test_that(".prepare_groups works without groups when no group info available (not colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res_no_group <- test_gp_exp |>
      glyexp::select_obs(-group) |>
      glystats::gly_pca()
  )

  # Test without any group information
  vdiffr::expect_doppelganger(
    "group_utils_no_group",
    autoplot(pca_res_no_group, type = "individual")
  )
})

test_that(".prepare_groups validates groups parameter length correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with wrong length groups
  wrong_groups <- c("A", "B", "C")  # Should be 12 elements
  names(wrong_groups) <- c("C_1", "C_2", "C_3")
  expect_error(
    autoplot(pca_res, type = "individual", groups = wrong_groups),
    "Length of.*groups.*must be equal to the number of samples"
  )
})

test_that(".prepare_groups validates group_col parameter correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with non-existent group_col
  expect_error(
    autoplot(pca_res, type = "individual", group_col = "nonexistent_column"),
    "Column.*nonexistent_column.*not found"
  )
})

test_that(".prepare_groups handles groups parameter precedence over group_col (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # When both groups and group_col are provided, groups should be used
  groups <- c("X", "X", "X", "Y", "Y", "Y", "Z", "Z", "Z", "W", "W", "W")
  names(groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3")

  vdiffr::expect_doppelganger(
    "group_utils_groups_precedence",
    autoplot(pca_res, type = "individual", groups = groups, group_col = "group")
  )
})

test_that(".prepare_groups accepts both factor and character groups (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with character groups
  char_groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", "D")
  names(char_groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3")
  vdiffr::expect_doppelganger(
    "group_utils_character_groups",
    autoplot(pca_res, type = "individual", groups = char_groups)
  )

  # Test with factor groups
  factor_groups <- factor(char_groups)
  vdiffr::expect_doppelganger(
    "group_utils_factor_groups",
    autoplot(pca_res, type = "individual", groups = factor_groups)
  )
})

test_that(".prepare_groups validates groups parameter names correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with unnamed groups
  unnamed_groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", "D")
  expect_error(
    autoplot(pca_res, type = "individual", groups = unnamed_groups),
    "groups.*must be named by sample names"
  )
})

test_that(".prepare_groups validates groups parameter sample name alignment correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with mismatched sample names
  mismatched_groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", "D")
  names(mismatched_groups) <- c("Wrong_1", "Wrong_2", "Wrong_3", "Names_1", "Names_2", "Names_3",
                                "Not_1", "Not_2", "Not_3", "Matching_1", "Matching_2", "Matching_3")
  expect_error(
    autoplot(pca_res, type = "individual", groups = mismatched_groups),
    "Sample names in.*groups.*must match those in.*object"
  )
})

test_that(".prepare_groups handles partial sample name mismatch correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with partially matching sample names
  partial_groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D")
  names(partial_groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2")
  expect_error(
    autoplot(pca_res, type = "individual", groups = partial_groups),
    "Length of.*groups.*must be equal to the number of samples"
  )
})

test_that(".prepare_groups handles extra sample names in groups correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with extra sample names in groups
  extra_groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", "D", "E")
  names(extra_groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3", "Extra")
  expect_error(
    autoplot(pca_res, type = "individual", groups = extra_groups),
    "Length of.*groups.*must be equal to the number of samples"
  )
})

test_that(".prepare_groups handles NULL groups and NULL group_col correctly (not colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res_no_group <- test_gp_exp |>
      glyexp::select_obs(-group) |>
      glystats::gly_pca()
  )

  # Test with both groups and group_col as NULL
  vdiffr::expect_doppelganger(
    "group_utils_null_groups_null_col",
    autoplot(pca_res_no_group, type = "individual", groups = NULL, group_col = NULL)
  )
})

test_that(".prepare_groups handles NULL groups with valid group_col (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with groups = NULL but valid group_col
  vdiffr::expect_doppelganger(
    "group_utils_null_groups_valid_col",
    autoplot(pca_res, type = "individual", groups = NULL, group_col = "group")
  )
})

test_that(".prepare_groups handles empty character groups correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with empty character vector
  empty_groups <- character(0)
  expect_error(
    autoplot(pca_res, type = "individual", groups = empty_groups),
    "Length of.*groups.*must be equal to the number of samples"
  )
})

test_that(".prepare_groups handles single-level factor groups (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with single-level factor (all samples in same group)
  single_groups <- rep("SameGroup", 12)
  names(single_groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3")
  vdiffr::expect_doppelganger(
    "group_utils_single_level_groups",
    autoplot(pca_res, type = "individual", groups = single_groups)
  )
})

test_that(".prepare_groups handles groups with NA values correctly (colored)", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with groups containing NA values
  na_groups <- c("A", "A", "A", "B", "B", "B", "C", "C", "C", "D", "D", NA)
  names(na_groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3")
  # Suppress expected warning about missing values in ggplot
  suppressWarnings(
    vdiffr::expect_doppelganger(
      "group_utils_na_groups",
      autoplot(pca_res, type = "individual", groups = na_groups)
    )
  )
})

test_that(".prepare_groups validates numeric groups correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with numeric groups (should be rejected)
  numeric_groups <- c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4)
  names(numeric_groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3")
  expect_error(
    autoplot(pca_res, type = "individual", groups = numeric_groups),
    "Must be of type.*factor.*character.*NULL"
  )
})

test_that(".prepare_groups validates logical groups correctly", {
  set.seed(1234)
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )

  # Test with logical groups (should be rejected)
  logical_groups <- c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)
  names(logical_groups) <- c("C_1", "C_2", "C_3", "H_1", "H_2", "H_3", "M_1", "M_2", "M_3", "Y_1", "Y_2", "Y_3")
  expect_error(
    autoplot(pca_res, type = "individual", groups = logical_groups),
    "Must be of type.*factor.*character.*NULL"
  )
})
