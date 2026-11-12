test_that("plot-specific controls are discoverable on public entry points", {
  scatter <- c("label", "add_ellipse", "point_size", "alpha")
  box <- c("log_transform", "points", "ncol", "label_width", "scales")
  heat <- c(
    "log_transform",
    "scale",
    "cluster_rows",
    "cluster_cols",
    "show_rownames",
    "show_colnames",
    "na_col"
  )
  controls <- list(
    pca = c("axes", scatter, "top_n"),
    plsda = c(scatter, "top_n"),
    oplsda = c(scatter, "top_n"),
    tsne = scatter,
    umap = scatter,
    volcano = c("label", "point_size", "alpha"),
    boxplot = box,
    heatmap = heat,
    corrplot = c("label", "digits", "triangle"),
    logo = "logo_args",
    roc = "top_n"
  )
  ns <- asNamespace("glyvis")
  for (kind in names(controls)) {
    generic <- paste0("plot_", kind)
    entry_points <- c(generic, as.character(methods(generic)))
    for (entry in entry_points) {
      expect_true(
        all(controls[[kind]] %in% names(formals(get(entry, ns)))),
        info = entry
      )
    }
  }
  result_controls <- controls[c(
    "pca",
    "plsda",
    "oplsda",
    "tsne",
    "umap",
    "roc"
  )]
  result_controls$cor <- controls$corrplot
  for (kind in c("ttest", "wilcox", "limma")) {
    result_controls[[kind]] <- controls$volcano
  }
  for (kind in c("anova", "kruskal", "cox")) {
    result_controls[[kind]] <- "top_n"
  }
  for (kind in names(result_controls)) {
    entry <- paste0("autoplot.glystats_", kind, "_res")
    expect_true(
      all(result_controls[[kind]] %in% names(formals(get(entry, ns)))),
      info = entry
    )
  }
  for (cls in c("SummarizedExperiment", "glyexp_experiment")) {
    entry <- paste0("autoplot.", cls)
    expect_true(all(c(box, heat) %in% names(formals(get(entry, ns)))))
  }
})

test_that("latent plot controls reach only the applicable plot types", {
  samples <- tibble::tibble(
    sample = paste0("S", 1:6),
    p1 = c(1, 4, 2, 3, 6, 5),
    p2 = c(3, 1, 4, 2, 5, 6),
    o1 = c(6, 3, 5, 4, 1, 2)
  )
  variables <- tibble::tibble(
    variable = paste0("V", 1:4),
    p1 = 1:4,
    p2 = 1:4,
    o1 = 1:4,
    pcorr1 = c(-0.8, -0.2, 0.2, 0.8)
  )
  latent <- list(
    tidy_result = list(
      samples = samples,
      variables = variables,
      vip = tibble::tibble(variable = variables$variable, vip = 1:4),
      variance = tibble::tibble(
        component = c("p1", "p2"),
        prop_var_explained = c(.6, .3)
      )
    )
  )
  for (kind in c("plsda", "oplsda")) {
    object <- structure(latent, class = paste0("glystats_", kind, "_res"))
    for (draw in list(get(paste0("plot_", kind)), ggplot2::autoplot)) {
      p <- draw(
        object,
        label = TRUE,
        point_size = 4,
        alpha = 0.3,
        title = "Scores"
      )
      expect_equal(p$layers[[1]]$aes_params$size, 4)
      expect_equal(p$layers[[1]]$aes_params$alpha, 0.3)
      expect_length(p$layers, 2)
      expect_equal(p$labels$title, "Scores")
      for (type in c("loadings", "vip")) {
        p <- draw(object, type = type, top_n = 2, label = TRUE)
        expect_equal(as.character(p$data$variable), c("V4", "V3"))
      }
      expect_s3_class(draw(object, type = "variance"), "tidyplot")
      if (kind == "oplsda") {
        p <- draw(object, type = "s-plot", point_size = 3, alpha = 0.4)
        expect_equal(p$layers[[1]]$aes_params$size, 3)
        expect_equal(p$layers[[1]]$aes_params$alpha, 0.4)
      }
    }
  }
})

test_that("container controls survive dispatch for both heatmaps and boxplots", {
  withr::local_options(lifecycle_verbosity = "quiet")
  legacy <- legacy_toy_experiment()
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = legacy$expr_mat),
    colData = S4Vectors::DataFrame(group = legacy$sample_info$group)
  )
  for (object in list(legacy, se)) {
    for (draw in list(plot_heatmap, ggplot2::autoplot)) {
      p <- draw(
        object,
        log_transform = FALSE,
        scale = "none",
        cluster_rows = FALSE,
        cluster_cols = FALSE,
        show_rownames = TRUE,
        show_colnames = TRUE,
        na_col = "pink"
      )
      expect_equal(p$data$value, as.vector(legacy$expr_mat))
      expect_equal(levels(p$data$sample), colnames(legacy$expr_mat))
      expect_equal(p$scales$get_scales("fill")$na.value, "pink")
    }
    for (draw in list(plot_boxplot, function(x, ...) {
      autoplot(x, type = "boxplot", ...)
    })) {
      p <- draw(
        object,
        log_transform = FALSE,
        points = FALSE,
        ncol = 2,
        label_width = 1,
        scales = "fixed"
      )
      expect_length(p$layers, 1)
      expect_equal(p$facet$params$ncol, 2)
      expect_equal(p$facet$params$free, list(x = FALSE, y = FALSE))
    }
  }
})


test_that("named facet controls retain their meaning", {
  withr::local_options(lifecycle_verbosity = "quiet")
  object <- legacy_toy_experiment()
  p <- plot_boxplot(
    object,
    group_col = "group",
    ncol = 1,
    label_width = 12,
    scales = "fixed",
    log_transform = FALSE
  )
  expect_equal(p$facet$params$ncol, 1)
  expect_equal(p$facet$params$free, list(x = FALSE, y = FALSE))
  p <- autoplot(
    object,
    type = "boxplot",
    group_col = "group",
    ncol = 1,
    label_width = 12,
    scales = "fixed",
    log_transform = FALSE
  )
  expect_equal(p$facet$params$ncol, 1)
  expect_equal(p$facet$params$free, list(x = FALSE, y = FALSE))
})


test_that("all public plotting controls follow dots", {
  ns <- asNamespace("glyvis")
  entries <- grep("^(plot_|autoplot[.])", ls(ns), value = TRUE)
  expect_gt(length(entries), 0)
  for (entry in entries) {
    args <- names(formals(get(entry, ns)))
    expect_identical(args[[2]], "...", info = entry)
    expect_true(args[[1]] %in% c("x", "object"), info = entry)
  }
})
