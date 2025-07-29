skip_on_ci()
skip_on_cran()

test_that("autoplot works for glystats_oplsda_res with default parameters", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      # Force orthogonal components to ensure o1 is available for default plot
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda(), ortho_i = 1)
    }, type = "output")
  }))

  # Test default plot (scores with o1)
  vdiffr::expect_doppelganger(
    "autoplot.glystats_oplsda_res_scores_default",
    autoplot(oplsda_res)
  )
})

test_that("autoplot works for glystats_oplsda_res scores plots", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda(), pred_i = 2, ortho_i = 1)
    }, type = "output")
  }))

  # Test scores plot with o1 (default y_type)
  vdiffr::expect_doppelganger(
    "autoplot.glystats_oplsda_res_scores_o1",
    autoplot(oplsda_res, type = "scores", y_type = "o1")
  )

  # Test scores plot with p2 (if available)
  if ("p2" %in% colnames(oplsda_res$tidy_result$samples)) {
    vdiffr::expect_doppelganger(
      "autoplot.glystats_oplsda_res_scores_p2",
      autoplot(oplsda_res, type = "scores", y_type = "p2")
    )
  }
})

test_that("autoplot works for glystats_oplsda_res loadings plots", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda(), pred_i = 2, ortho_i = 1)
    }, type = "output")
  }))

  # Test loadings plot with o1
  vdiffr::expect_doppelganger(
    "autoplot.glystats_oplsda_res_loadings_o1",
    autoplot(oplsda_res, type = "loadings", y_type = "o1")
  )

  # Test loadings plot with p2 (if available)
  if ("p2" %in% colnames(oplsda_res$tidy_result$variables)) {
    vdiffr::expect_doppelganger(
      "autoplot.glystats_oplsda_res_loadings_p2",
      autoplot(oplsda_res, type = "loadings", y_type = "p2")
    )
  }
})

test_that("autoplot works for glystats_oplsda_res vip and variance plots", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda())
    }, type = "output")
  }))

  # Test VIP plot
  vdiffr::expect_doppelganger(
    "autoplot.glystats_oplsda_res_vip",
    autoplot(oplsda_res, type = "vip")
  )

  # Test variance plot
  vdiffr::expect_doppelganger(
    "autoplot.glystats_oplsda_res_variance",
    autoplot(oplsda_res, type = "variance")
  )
})

test_that("autoplot type validation works correctly", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda())
    }, type = "output")
  }))

  # Test invalid type
  expect_error(
    autoplot(oplsda_res, type = "invalid_type"),
    "Must be element of set"
  )
})

test_that("autoplot y_type validation works correctly", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda())
    }, type = "output")
  }))

  # Test invalid y_type
  expect_error(
    autoplot(oplsda_res, type = "scores", y_type = "invalid_y_type"),
    "Must be element of set"
  )
})

test_that("autoplot handles missing orthogonal components gracefully", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      # Force no orthogonal components
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda(), ortho_i = 0)
    }, type = "output")
  }))

  # Should error when trying to plot o1 if no orthogonal components
  expect_error(
    autoplot(oplsda_res, type = "scores", y_type = "o1"),
    "Can't find orthogonal component scores"
  )

  expect_error(
    autoplot(oplsda_res, type = "loadings", y_type = "o1"),
    "Can't find orthogonal component scores"
  )
})

test_that("autoplot handles missing second predictive component gracefully", {
  skip_if_not_installed("ropls")

  set.seed(1234)
  suppressMessages(suppressWarnings({
    capture.output({
      # Use only 1 predictive component
      oplsda_res <- glystats::gly_oplsda(exp_for_oplsda(), pred_i = 1)
    }, type = "output")
  }))

  # Should error when trying to plot p2 if only 1 predictive component
  expect_error(
    autoplot(oplsda_res, type = "scores", y_type = "p2"),
    "Can't find predictive component scores"
  )

  expect_error(
    autoplot(oplsda_res, type = "loadings", y_type = "p2"),
    "Can't find predictive component scores"
  )
})