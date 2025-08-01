skip_on_ci()
skip_on_cran()
skip_if_not_installed("ConsensusClusterPlus")

test_that("autoplot raises error for glystats cc results", {
  cc_res <- suppressMessages(glystats::gly_consensus_clustering(test_gp_exp, max_k = 3, reps = 30))
  expect_error(autoplot(cc_res), "Can't plot consensus clustering results currectly.")
})