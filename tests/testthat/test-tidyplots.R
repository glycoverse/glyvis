test_that("plot sizes inherit tidyplots defaults and allow explicit overrides", {
  df <- tibble::tibble(sample = c("A", "B"), tsne1 = 1:2, tsne2 = 2:1)
  object <- structure(list(tidy_result = df), class = "glystats_tsne_res")
  reference <- tidyplots::tidyplot(df, x = tsne1, y = tsne2)
  dimensions <- c("width", "height", "unit")
  expect_equal(
    plot_tsne(object)$tidyplot[dimensions],
    reference$tidyplot[dimensions]
  )
  expect_equal(
    plot_tsne(object, width = 80, height = 60)$tidyplot[dimensions],
    list(width = 80, height = 60, unit = "mm")
  )
  expect_equal(
    plot_tsne(object, width = NA, height = NA)$tidyplot[dimensions],
    list(width = NA, height = NA, unit = "mm")
  )
})

test_that("all result entry points return composable tidyplots and forward styling", {
  withr::local_seed(42)
  sample_names <- paste0("S", 1:8)
  groups <- rep(c("A", "B"), each = 4)
  samples <- tibble::tibble(
    sample = sample_names,
    p1 = rnorm(8),
    p2 = rnorm(8),
    o1 = rnorm(8),
    group = groups
  )
  variables <- tibble::tibble(
    variable = paste0("V", 1:5),
    p1 = rnorm(5),
    p2 = rnorm(5),
    o1 = rnorm(5),
    pcorr1 = seq(-1, 1, length.out = 5)
  )
  latent <- list(
    tidy_result = list(
      samples = samples,
      variables = variables,
      vip = tibble::tibble(variable = variables$variable, vip = 1:5),
      variance = tibble::tibble(
        component = c("p1", "p2"),
        prop_var_explained = c(.6, .3)
      )
    )
  )
  plots <- list()
  for (cls in c("glystats_plsda_res", "glystats_oplsda_res")) {
    object <- structure(latent, class = cls)
    types <- c("scores", "loadings", "vip", "variance")
    if (cls == "glystats_oplsda_res") {
      types <- c(types, "s-plot")
    }
    direct <- if (cls == "glystats_oplsda_res") plot_oplsda else plot_plsda
    for (type in types) {
      plots <- c(
        plots,
        list(
          autoplot(object, type = type, title = "Custom"),
          direct(object, type = type, title = "Custom")
        )
      )
    }
  }
  for (kind in c("tsne", "umap")) {
    df <- tibble::tibble(
      sample = sample_names,
      a = samples$p1,
      b = samples$p2,
      group = groups
    )
    names(df)[2:3] <- paste0(kind, 1:2)
    object <- structure(
      list(tidy_result = df),
      class = paste0("glystats_", kind, "_res")
    )
    direct <- if (kind == "tsne") plot_tsne else plot_umap
    plots <- c(
      plots,
      list(autoplot(object, title = "Custom"), direct(object, title = "Custom"))
    )
    object$tidy_result$group <- NULL
    plots <- c(plots, list(direct(object, title = "Custom")))
  }
  for (p in plots) {
    expect_s3_class(p, "tidyplot")
    expect_equal(p$labels$title, "Custom")
    changed <- p |>
      tidyplots::adjust_font(fontsize = 11) |>
      tidyplots::adjust_size(width = 80, height = 60)
    expect_s3_class(ggplot2::ggplot_build(changed), "ggplot_built")
    expect_equal(changed$tidyplot$width, 80)
  }
})

test_that("PCA preserves scores, grouping and explained variance across plot types", {
  withr::local_seed(42)
  mat <- matrix(
    rnorm(40),
    8,
    dimnames = list(paste0("S", 1:8), paste0("V", 1:5))
  )
  model <- stats::prcomp(mat)
  samples <- tibble::tibble(
    sample = rownames(mat),
    group = rep(c("A", "B"), each = 4)
  )
  object <- structure(
    list(raw_result = model, tidy_result = list(samples = samples)),
    class = "glystats_pca_res"
  )
  palette <- c(A = "#333333", B = "#0072B2")
  p <- plot_pca(object, axes = c(2, 3), palette = palette)
  expect_equal(p$data$x, unname(model$x[, 2]))
  expect_equal(p$data$y, unname(model$x[, 3]))
  expect_equal(as.character(p$data$group), samples$group)
  expect_equal(
    ggplot2::ggplot_build(p)$plot$scales$get_scales("colour")$map(c("B", "A")),
    unname(palette[c("B", "A")])
  )
  expect_length(p$layers, 1)
  for (type in c("individual", "variables", "screeplot", "biplot")) {
    for (label in c(FALSE, TRUE)) {
      p <- plot_pca(object, type = type, label = label)
      expect_s3_class(p, "tidyplot")
      expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
    }
  }
  p <- plot_pca(object, type = "variables")
  expect_equal(nrow(p$data), ncol(mat))
  expect_equal(nrow(plot_pca(object, type = "variables", top_n = 2)$data), 2)
  expect_equal(
    plot_pca(object, type = "screeplot")$data$variance,
    model$sdev^2 / sum(model$sdev^2) * 100
  )
  expect_snapshot(error = TRUE, plot_pca(object, geom = "point"))
})

test_that("heatmap scaling and clustering preserve values and missingness", {
  mat <- matrix(
    c(2, 4, 7, 9, 3, 5, 8, 14, 4, 6, NA, 21),
    3,
    dimnames = list(c("A", "B", "C"), paste0("S", 1:4))
  )
  se <- SummarizedExperiment::SummarizedExperiment(assays = list(mat))
  logged <- log2(mat + 1)
  p <- plot_heatmap(se, cluster_rows = FALSE, cluster_cols = FALSE)
  expected <- t(apply(logged, 1, function(x) {
    (x - mean(x, na.rm = TRUE)) / stats::sd(x, na.rm = TRUE)
  }))
  expect_equal(p$data$value, as.vector(expected))
  expect_equal(is.na(p$data$value), is.na(as.vector(mat)))
  expect_equal(levels(p$data$sample), colnames(mat))
  expect_equal(levels(p$data$variable), rev(rownames(mat)))
  expect_equal(plot_heatmap(se, scale = "none")$data$value, as.vector(logged))
  col_scaled <- apply(logged, 2, function(x) {
    (x - mean(x, na.rm = TRUE)) / stats::sd(x, na.rm = TRUE)
  })
  expect_equal(
    plot_heatmap(se, scale = "column")$data$value,
    as.vector(col_scaled)
  )
  tree <- stats::hclust(stats::dist(logged))
  expect_equal(
    levels(plot_heatmap(se, cluster_rows = tree)$data$variable),
    rev(rownames(mat)[tree$order])
  )
  expect_s3_class(
    ggplot2::ggplot_build(p |> tidyplots::adjust_legend_title("Row Z score")),
    "ggplot_built"
  )
})

test_that("volcano, significance and ROC plots retain numerical results", {
  df <- tibble::tibble(
    variable = c("A", "B", "C", "D"),
    log2fc = c(-2, 0, 2, 1),
    p_adj = c(.001, .8, 0, .01),
    p_val = c(.0001, .7, 0, .001)
  )
  for (cls in c("glystats_ttest_res", "glystats_wilcox_res")) {
    object <- structure(list(tidy_result = df), class = cls)
    for (p in list(
      plot_volcano(object, title = "Custom"),
      autoplot(object, title = "Custom")
    )) {
      expect_s3_class(p, "tidyplot")
      expect_equal(
        p$data$status,
        factor(
          c("Down", "Unchanged", "Up", "Unchanged"),
          levels = c("Down", "Unchanged", "Up")
        )
      )
      expect_equal(p$data$neglog10p[3], -log10(.Machine$double.xmin))
      expect_equal(p$labels$title, "Custom")
      expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
    }
  }
  limma_df <- df
  limma_df$ref_group <- "A"
  limma_df$test_group <- "B"
  limma <- structure(list(tidy_result = limma_df), class = "glystats_limma_res")
  expect_equal(plot_volcano(limma)$data$log2fc, df$log2fc)
  for (cls in c(
    "glystats_anova_res",
    "glystats_kruskal_res",
    "glystats_cox_res"
  )) {
    tidy <- if (cls == "glystats_cox_res") df else list(main_test = df)
    p <- autoplot(
      structure(list(tidy_result = tidy), class = cls),
      title = "Custom"
    )
    expect_s3_class(p, "tidyplot")
    expect_equal(nrow(p$data), nrow(df))
    expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
  }
  coords <- tibble::tibble(
    variable = rep(c("A", "B"), each = 3),
    specificity = rep(c(1, .5, 0), 2),
    sensitivity = c(0, .8, 1, 0, .7, 1)
  )
  object <- structure(
    list(
      tidy_result = list(
        coords = coords,
        auc = tibble::tibble(variable = c("A", "B"), auc = c(.9, .7))
      )
    ),
    class = "glystats_roc_res"
  )
  expect_equal(
    plot_roc(object)$data$false_positive_rate,
    1 - coords$specificity
  )
  expect_equal(plot_roc(object)$data$sensitivity, coords$sensitivity)
  expect_equal(sort(plot_roc(object, type = "dotplot")$data$auc), c(.7, .9))
  expect_s3_class(autoplot(object, title = "AUC"), "tidyplot")
})

test_that("specialized geometry uses a tidyplots canvas", {
  skip_if_not_installed("ggdendro")
  skip_if_not_installed("ggseqlogo")
  tree <- stats::hclust(stats::dist(matrix(1:12, 4)))
  p <- autoplot(
    structure(list(raw_result = tree), class = "glystats_hclust_res"),
    title = "Tree"
  )
  expect_s3_class(p, "tidyplot")
  expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
  se <- test_gp_se[1:4, ]
  SummarizedExperiment::rowData(se)$site_sequence <- c(
    "AANST",
    "TTNSS",
    "AANAT",
    "GGNTS"
  )
  p <- plot_logo(
    se,
    n_aa = 2,
    logo_args = list(method = "prob"),
    title = "Logo"
  )
  expect_s3_class(p, "tidyplot")
  expect_equal(p$labels$title, "Logo")
  expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
})
