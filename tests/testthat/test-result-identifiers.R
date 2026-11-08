# Tiny schema fixtures keep this compatibility test independent of glystats versions.
new_id_result <- function(tidy_result) {
  list(
    tidy_result = tidy_result,
    identifiers = list(
      columns = c(variable = ".variable", sample = ".sample")
    )
  )
}

test_that("schema markers distinguish identity from ordinary metadata", {
  df <- tibble::tibble(.sample = c("S2", "S1"), sample = c("B", "A"))
  new <- new_id_result(df)
  expect_identical(.get_samples(new), c("S2", "S1"))
  expect_identical(
    .default_group_extractor(new, "sample"),
    c(S2 = "B", S1 = "A")
  )
  expect_identical(.get_samples(list(tidy_result = df)), c("B", "A"))
  nested <- new_id_result(list(
    variables = tibble::tibble(sample = "metadata"),
    samples = df
  ))
  expect_identical(.get_samples(nested), c("S2", "S1"))
  expect_identical(
    .default_group_extractor(nested, "sample"),
    c(S2 = "B", S1 = "A")
  )
  expect_identical(.result_id_column(list(), "variable"), "variable")
})

test_that("variable plots use dot identities without replacing ordinary metadata", {
  df <- tibble::tibble(
    .variable = c("V1", "V2"),
    variable = c("annotation", "annotation"),
    p_val = c(.01, .5),
    p_adj = c(.02, .5),
    log2fc = c(2, -.5)
  )
  object <- new_id_result(df)
  p <- autoplot.glystats_cox_res(object)
  expect_identical(as.character(p$data$.variable), df$.variable)
  expect_identical(p$data$variable, df$variable)
  expect_silent(ggplot2::ggplot_build(p))
  p <- .plot_volcano(object, 1, .05, "p_adj", label = TRUE)
  expect_true(any(vapply(
    ggplot2::ggplot_build(p)$data,
    \(layer) "label" %in% names(layer) && all(layer$label %in% df$.variable),
    logical(1)
  )))
  roc <- new_id_result(list(
    auc = tibble::tibble(
      .variable = c("V1", "V2"),
      variable = "annotation",
      auc = c(.8, .9)
    ),
    coords = tibble::tibble(
      .variable = rep(c("V1", "V2"), each = 3),
      variable = "annotation",
      specificity = rep(c(1, .5, 0), 2),
      sensitivity = c(0, .7, 1, 0, .8, 1)
    )
  ))
  expect_silent(ggplot2::ggplot_build(.plot_roc_dotplot(roc, .5)))
  built <- ggplot2::ggplot_build(.plot_roc_curves(roc))
  expect_equal(length(unique(built$data[[1]]$group)), 2L)
})

test_that("embedding and loading plots accept new identities", {
  object <- new_id_result(list(
    samples = tibble::tibble(
      .sample = c("S1", "S2", "S3"),
      sample = "annotation",
      p1 = c(1, 2, 3),
      p2 = c(3, 1, 2)
    ),
    variables = tibble::tibble(
      .variable = c("V1", "V2"),
      variable = "annotation",
      p1 = c(1, 2),
      p2 = c(2, 1)
    ),
    vip = tibble::tibble(
      .variable = c("V1", "V2"),
      variable = "annotation",
      vip = c(1, 2)
    )
  ))
  expect_silent(ggplot2::ggplot_build(.plot_oplsda_scores(object, "p2", NULL)))
  expect_silent(ggplot2::ggplot_build(.plot_oplsda_loadings(object, "p2")))
  expect_silent(ggplot2::ggplot_build(.plot_oplsda_vip(object)))
})


test_that("embedding plots preserve annotation named sample", {
  df <- tibble::tibble(
    .sample = c("S1", "S2", "S3"),
    sample = c("A", "B", "B"),
    tsne1 = 1:3,
    tsne2 = c(2, 1, 3),
    umap1 = 1:3,
    umap2 = c(2, 1, 3)
  )
  object <- new_id_result(df)
  for (plot in list(.plot_tsne, .plot_umap)) {
    p <- plot(object, group_col = "sample", label = TRUE)
    built <- ggplot2::ggplot_build(p)
    expect_equal(length(unique(built$data[[1]]$colour)), 2L)
    expect_true(any(vapply(
      built$data,
      \(x) "label" %in% names(x) && setequal(x$label, df$.sample),
      logical(1)
    )))
    old <- list(
      tidy_result = tibble::as_tibble(transform(
        df,
        sample = .sample,
        .sample = "metadata"
      ))
    )
    expect_silent(ggplot2::ggplot_build(plot(old)))
  }
})
