# Synthetic demonstration data only; not biological evidence.
# Run from the package root after devtools::load_all().
set.seed(42)
mat <- matrix(rnorm(80 * 24, 10, 1), nrow = 80)
mat[1:20, 13:24] <- mat[1:20, 13:24] + 2
mat[21:40, 13:24] <- mat[21:40, 13:24] - 2
mat <- 2^mat
dimnames(mat) <- list(paste0("Feature ", 1:80), paste0("S", 1:24))
se <- SummarizedExperiment::SummarizedExperiment(
  assays = list(abundance = mat),
  colData = S4Vectors::DataFrame(
    group = factor(rep(c("Control", "Treatment"), each = 12))
  )
)
plots <- list(
  pca = plot_pca(se),
  boxplot = plot_boxplot(se[c(1, 21, 41, 61), ], scales = "fixed", ncol = 2),
  volcano = plot_volcano(se),
  heatmap = plot_heatmap(se, show_colnames = FALSE)
)
for (name in names(plots)) {
  tidyplots::save_plot(
    plots[[name]],
    file.path("man/figures", paste0("pr-tidyplots-", name, ".png")),
    dpi = 300,
    device = ragg::agg_png,
    view_plot = FALSE
  )
}
