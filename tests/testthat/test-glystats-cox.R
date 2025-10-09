skip_on_ci()
skip_on_cran()
skip_if_not_installed("survival")

test_that("autoplot works for glystats cox results", {

  # Create test survival data with fixed seed for reproducibility
  set.seed(123)

  # Create expression matrix (5 variables, 20 samples)
  expr_mat <- matrix(rnorm(100), nrow = 5, ncol = 20)
  rownames(expr_mat) <- paste0("var", 1:5)
  colnames(expr_mat) <- paste0("sample", 1:20)

  # Create sample info with survival data
  sample_info <- tibble::tibble(
    sample = paste0("sample", 1:20),
    time = rexp(20, rate = 0.1),
    event = rbinom(20, 1, 0.7)
  )

  # Create variable info
  var_info <- tibble::tibble(
    variable = paste0("var", 1:5),
    type = rep("marker", 5)
  )

  # Create experiment object
  exp <- glyexp::experiment(
    expr_mat = expr_mat,
    sample_info = sample_info,
    var_info = var_info,
    exp_type = "others"
  )

  # Get Cox results
  cox_result <- suppressMessages(glystats::gly_cox(exp))

  # Test autoplot function with vdiffr
  vdiffr::expect_doppelganger(
    "autoplot.glystats_cox_res",
    autoplot(cox_result)
  )
})

test_that("autoplot works for glystats cox results with different p_col options", {

  # Create test survival data with fixed seed for reproducibility
  set.seed(456)

  # Create expression matrix (3 variables, 15 samples)
  expr_mat <- matrix(rnorm(45), nrow = 3, ncol = 15)
  rownames(expr_mat) <- paste0("gene", 1:3)
  colnames(expr_mat) <- paste0("sample", 1:15)

  # Create sample info with survival data
  sample_info <- tibble::tibble(
    sample = paste0("sample", 1:15),
    time = rexp(15, rate = 0.15),
    event = rbinom(15, 1, 0.8)
  )

  # Create variable info
  var_info <- tibble::tibble(
    variable = paste0("gene", 1:3),
    type = rep("gene", 3)
  )

  # Create experiment object
  exp <- glyexp::experiment(
    expr_mat = expr_mat,
    sample_info = sample_info,
    var_info = var_info,
    exp_type = "others"
  )

  # Get Cox results
  cox_result <- suppressMessages(glystats::gly_cox(exp))

  # Test with raw p-values
  vdiffr::expect_doppelganger(
    "autoplot.glystats_cox_res_p_raw",
    autoplot(cox_result, p_col = "p_val")
  )
})

test_that("autoplot works for glystats cox results with different p_cutoff values", {

  # Create test survival data with fixed seed for reproducibility
  set.seed(789)

  # Create expression matrix (4 variables, 12 samples)
  expr_mat <- matrix(rnorm(48), nrow = 4, ncol = 12)
  rownames(expr_mat) <- paste0("marker", 1:4)
  colnames(expr_mat) <- paste0("sample", 1:12)

  # Create sample info with survival data
  sample_info <- tibble::tibble(
    sample = paste0("sample", 1:12),
    time = rexp(12, rate = 0.2),
    event = rbinom(12, 1, 0.6)
  )

  # Create variable info
  var_info <- tibble::tibble(
    variable = paste0("marker", 1:4),
    type = rep("biomarker", 4)
  )

  # Create experiment object
  exp <- glyexp::experiment(
    expr_mat = expr_mat,
    sample_info = sample_info,
    var_info = var_info,
    exp_type = "others"
  )

  # Get Cox results
  cox_result <- suppressMessages(glystats::gly_cox(exp))

  # Test with different p_cutoff
  vdiffr::expect_doppelganger(
    "autoplot.glystats_cox_res_p_cutoff_0.01",
    autoplot(cox_result, p_cutoff = 0.01)
  )
})

test_that("autoplot.glystats_cox_res parameter validation works", {

  # Create minimal test data
  set.seed(999)
  expr_mat <- matrix(rnorm(20), nrow = 2, ncol = 10)
  rownames(expr_mat) <- paste0("var", 1:2)
  colnames(expr_mat) <- paste0("sample", 1:10)

  sample_info <- tibble::tibble(
    sample = paste0("sample", 1:10),
    time = rexp(10, rate = 0.3),
    event = rbinom(10, 1, 0.5)
  )

  var_info <- tibble::tibble(
    variable = paste0("var", 1:2),
    type = rep("test", 2)
  )

  exp <- glyexp::experiment(
    expr_mat = expr_mat,
    sample_info = sample_info,
    var_info = var_info,
    exp_type = "others"
  )

  cox_result <- suppressMessages(glystats::gly_cox(exp))

  # Test invalid p_cutoff
  expect_error(
    autoplot(cox_result, p_cutoff = -0.1),
    "Assertion on 'p_cutoff' failed"
  )

  # Test invalid p_col
  expect_error(
    autoplot(cox_result, p_col = "invalid_col"),
    "Assertion on 'p_col' failed"
  )
})
