compatibility_test_exp <- function(scale = "logx", legacy = FALSE) {
  x <- legacy_toy_experiment()
  x$meta_data$scale <- scale
  x$expr_mat <- matrix(
    c(-2, 1, 0, 3, 2, -1, 4, 2, -1, 4, 2, 0,
      1, 2, 3, -2, 2, 4, 0, 1, 3, 1, -1, 2),
    nrow = 4, dimnames = dimnames(x$expr_mat)
  )
  if (legacy) return(x)
  SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = x$expr_mat),
    colData = S4Vectors::DataFrame(x$sample_info),
    metadata = x$meta_data
  )
}

test_that("all container analysis routes reject incompatible logged inputs", local({
  withr::local_options(lifecycle_verbosity = "quiet")
  skip_if_not_installed("glystats")
  local_mocked_bindings(.glystats_supports_logged_inputs = function() FALSE)
  # No user's analysis may run before the compatibility error, including ROC
  # and every selectable differential test used by the volcano entry point.
  unexpected_analysis <- function(...) stop("User analysis must not run")
  local_mocked_bindings(
    gly_pca = unexpected_analysis, gly_tsne = unexpected_analysis,
    gly_umap = unexpected_analysis, gly_plsda = unexpected_analysis,
    gly_oplsda = unexpected_analysis, gly_cor = unexpected_analysis,
    gly_roc = unexpected_analysis, gly_ttest = unexpected_analysis,
    gly_wilcox = unexpected_analysis, gly_limma = unexpected_analysis,
    .package = "glystats"
  )
  plotters <- list(plot_pca, plot_tsne, plot_umap, plot_plsda,
                   plot_oplsda, plot_corrplot, plot_roc)
  for (legacy in c(FALSE, TRUE)) {
    for (scale in c("log", "log2", "log10", "logx")) {
      x <- compatibility_test_exp(scale, legacy)
      for (plotter in plotters) {
        expect_error(plotter(x), class = "glyvis_incompatible_glystats")
        expect_error(plotter(x, stats_args = list(log_transform = FALSE)),
                     "Update with")
      }
      for (test in c("ttest", "wilcox", "limma")) {
        expect_error(plot_volcano(x, test = test),
                     class = "glyvis_incompatible_glystats")
      }
    }
  }
}))

test_that("raw and absent-scale inputs retain delegated arguments and values", local({
  withr::local_options(lifecycle_verbosity = "quiet")
  skip_if_not_installed("glystats")
  local_mocked_bindings(.glystats_supports_logged_inputs = function() {
    stop("Raw input should not need a compatibility probe")
  })
  local_mocked_bindings(gly_pca = function(exp, ...) {
    list(exp = exp, args = list(...))
  }, .package = "glystats")
  for (legacy in c(FALSE, TRUE)) {
    for (scale in list("raw", NULL)) {
      x <- compatibility_test_exp(scale, legacy)
      original <- x
      result <- .run_glystats_analysis(x, "gly_pca", list(log_transform = FALSE))
      expect_identical(result$exp, original)
      expect_identical(result$args, list(log_transform = FALSE))
      expect_identical(x, original)
    }
  }
}))

test_that("invalid metadata fails before calling any backend", local({
  withr::local_options(lifecycle_verbosity = "quiet")
  local_mocked_bindings(.glystats_supports_logged_inputs = function() {
    stop("Invalid metadata must fail before the probe")
  })
  for (legacy in c(FALSE, TRUE)) {
    for (scale in list("custom", NA_character_, c("raw", "log2"), 1, NULL)) {
      x <- compatibility_test_exp("raw", legacy)
      if (legacy) x$meta_data["scale"] <- list(scale)
      else S4Vectors::metadata(x)["scale"] <- list(scale)
      expect_error(.run_glystats_analysis(x, "gly_pca", list()), "Metadata `scale`")
    }
  }
}))

test_that("the compatibility probe requires the public logged-input contract", local({
  withr::local_options(lifecycle_verbosity = "quiet")
  skip_if_not_installed("glystats")
  results <- list(
    list(),
    list(preprocessing = list(input_scale = "logx", analysis_scale = "log",
                             log_transform = TRUE, transformation = "log(x + 1)")),
    list(preprocessing = list(input_scale = "logx", analysis_scale = "logx",
                             log_transform = FALSE, transformation = "none"))
  )
  for (i in seq_along(results)) {
    local({
      result <- results[[i]]
      local_mocked_bindings(gly_pca = function(exp, scale, add_info, log_transform) {
        expect_identical(S4Vectors::metadata(exp)$scale, "logx")
        expect_true(any(SummarizedExperiment::assay(exp) < -1))
        expect_false(scale)
        expect_false(add_info)
        expect_true(log_transform)
        result
      }, .package = "glystats")
      expect_identical(.glystats_supports_logged_inputs(), i == 3L)
    })
  }
  local_mocked_bindings(gly_pca = function(...) {
    stop("Metadata scale must be raw, log, log2, or log10")
  }, .package = "glystats")
  expect_false(.glystats_supports_logged_inputs())
}))

test_that("compatible analyses preserve logged input and caller options", local({
  withr::local_options(lifecycle_verbosity = "quiet")
  skip_if_not_installed("glystats")
  local_mocked_bindings(.glystats_supports_logged_inputs = function() TRUE)
  local_mocked_bindings(gly_pca = function(exp, ...) {
    list(exp = exp, args = list(...))
  }, .package = "glystats")
  for (legacy in c(FALSE, TRUE)) {
    x <- compatibility_test_exp("logx", legacy)
    original <- x
    for (option in list(NULL, TRUE, FALSE)) {
      args <- list(log_transform = option, center = FALSE)
      result <- .run_glystats_analysis(x, "gly_pca", args)
      expect_identical(result$exp, original)
      expect_identical(result$args, args)
      expect_identical(x, original)
    }
  }
}))

test_that("precomputed results and abundance-only plots bypass analysis checks", local({
  withr::local_options(lifecycle_verbosity = "quiet")
  local_mocked_bindings(.glystats_supports_logged_inputs = function() {
    stop("No statistical analysis should be needed")
  })
  result <- structure(list(tidy_result = tibble::tibble(
    sample = c("A", "B"), tsne1 = c(-2, 0), tsne2 = c(0, 3)
  )), class = "glystats_tsne_res")
  expect_s3_class(plot_tsne(result), "tidyplot")
  expect_s3_class(plot_boxplot(compatibility_test_exp()), "tidyplot")
  expect_s3_class(plot_heatmap(compatibility_test_exp(), scale = "none"), "tidyplot")
}))

test_that("installed glystats is guarded or preserves logged coordinates in PCA", local({
  withr::local_options(lifecycle_verbosity = "quiet")
  skip_if_not_installed("glystats")
  supported <- .glystats_supports_logged_inputs()
  if (identical(Sys.getenv("GLYVIS_REQUIRE_LOGGED_GLYSTATS"), "true")) {
    expect_true(supported)
  }
  if (!supported) {
    expect_error(plot_pca(compatibility_test_exp()),
                 class = "glyvis_incompatible_glystats")
    return(invisible(NULL))
  }
  withr::local_seed(859)
  seed <- .Random.seed
  expect_true(.glystats_supports_logged_inputs())
  expect_identical(.Random.seed, seed)
  for (scale in c("log", "log2", "log10", "logx")) {
    x <- compatibility_test_exp(scale)
    original <- x
    result <- .run_glystats_analysis(x, "gly_pca", list(scale = FALSE))
    reference <- stats::prcomp(t(SummarizedExperiment::assay(x)), scale. = FALSE)
    expect_equal(result$raw_result, reference)
    expect_identical(result$preprocessing$log_transform, FALSE)
    expect_warning(explicit <- .run_glystats_analysis(
      x, "gly_pca", list(scale = FALSE, log_transform = TRUE)
    ), class = "glystats_already_logged")
    expect_equal(explicit$raw_result, reference)
    expect_identical(x, original)
    expect_s3_class(plot_pca(x, stats_args = list(scale = FALSE)), "tidyplot")
  }
}))
