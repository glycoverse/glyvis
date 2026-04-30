test_that("removed glystats result classes do not have autoplot methods", {
  removed_classes <- c("glystats_cc_res", "glystats_wgcna_res")

  purrr::walk(removed_classes, function(class) {
    expect_null(getS3method("autoplot", class, optional = TRUE))
  })
})
