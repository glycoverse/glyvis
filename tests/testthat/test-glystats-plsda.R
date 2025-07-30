skip_on_ci()
skip_on_cran()
skip_if_not_installed("ropls")

# Helper function to create test data for PLS-DA
exp_for_plsda <- function() {
  test_gp_exp |>
    glyexp::slice_head_var(n = 3) |>
    glyexp::mutate_obs(group = dplyr::if_else(group %in% c("H", "M"), "control", "case"))
}

test_that("autoplot works for glystats_plsda_res with default parameters", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 2)
    }, type = "output")
  }))

  # Test default plot (scores with p2)
  vdiffr::expect_doppelganger(
    "autoplot.glystats_plsda_res_scores_default",
    autoplot(plsda_res)
  )
})

test_that("autoplot works for glystats_plsda_res scores plots", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 2)
    }, type = "output")
  }))

  # Test scores plot (default uses p2)
  vdiffr::expect_doppelganger(
    "autoplot.glystats_plsda_res_scores",
    autoplot(plsda_res, type = "scores")
  )
})

test_that("autoplot works for glystats_plsda_res loadings plots", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 2)
    }, type = "output")
  }))

  # Test loadings plot
  vdiffr::expect_doppelganger(
    "autoplot.glystats_plsda_res_loadings",
    autoplot(plsda_res, type = "loadings")
  )
})

test_that("autoplot works for glystats_plsda_res vip", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 2)
    }, type = "output")
  }))

  # Test VIP plot
  vdiffr::expect_doppelganger(
    "autoplot.glystats_plsda_res_vip",
    autoplot(plsda_res, type = "vip")
  )
})

test_that("autoplot works for glystats_plsda_res variance", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 2)
    }, type = "output")
  }))

  # Test variance plot
  vdiffr::expect_doppelganger(
    "autoplot.glystats_plsda_res_variance",
    autoplot(plsda_res, type = "variance")
  )
})

test_that("autoplot type validation works correctly", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 2)
    }, type = "output")
  }))

  # Test invalid type
  expect_error(
    autoplot(plsda_res, type = "invalid_type"),
    "Must be element of set"
  )
})

test_that("autoplot handles missing second predictive component gracefully", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      # Use only 1 component
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 1)
    }, type = "output")
  }))

  # Should error when trying to plot p2 if only 1 component
  expect_error(
    autoplot(plsda_res, type = "scores"),
    "Can't find predictive component scores"
  )

  expect_error(
    autoplot(plsda_res, type = "loadings"),
    "Can't find predictive component scores"
  )
})

test_that("autoplot works with group coloring", {
  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      plsda_res <- glystats::gly_plsda(exp_for_plsda(), ncomp = 2)
    }, type = "output")
  }))

  # Test with group coloring
  vdiffr::expect_doppelganger(
    "autoplot.glystats_plsda_res_scores_grouped",
    autoplot(plsda_res, type = "scores", group_col = "group")
  )
})
