#' PCA Plot
#'
#' Draw a PCA scores plot.
#' Currently supported data types:
#' - `glystats_pca_res`: Result from [glystats::gly_pca()].
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   PCA analysis is first performed using [glystats::gly_pca()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "screeplot", "individual", "variables", or "biplot".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "individual" and "biplot" types.
#'   Passed to the `habillage` paramter of [factoextra::fviz_pca_ind()] or [factoextra::fviz_pca_biplot()].
#' @param group_col A character string specifying where to find the group information.
#   If you uses [glystats::gly_pca()] on a [glyexp::experiment()] to get the result,
#   sample information has already been added to the result.
#   In this case, you can specify the column name in the sample information tibble
#   to be used for coloring.
#' @param ... Additional arguments passed to underlying factoextra functions:
#'   - type = "screeplot": [factoextra::fviz_screeplot()].
#'   - type = "individual": [factoextra::fviz_pca_ind()].
#'   - type = "variables": [factoextra::fviz_pca_var()].
#'   - type = "biplot": [factoextra::fviz_pca_biplot()].
#'
#' @returns A ggplot object.
#' @seealso [factoextra::fviz_screeplot()], [factoextra::fviz_pca_ind()],
#'   [factoextra::fviz_pca_var()], [factoextra::fviz_pca_biplot()]
#' @export
plot_pca <- function(x, type = "individual", groups = NULL, group_col = NULL, ...) {
  UseMethod("plot_pca")
}

#' @rdname plot_pca
#' @export
plot_pca.glystats_pca_res <- function(x, type = "individual", groups = NULL, group_col = NULL, ...) {
  .plot_pca(x, type = type, ...)
}

#' @rdname plot_pca
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_pca()].
#' @export
plot_pca.glyexp_experiment <- function(x, type = "individual", groups = NULL, group_col = NULL, stats_args = list(), ...) {
  pca_res <- rlang::exec(glystats::gly_pca, x, !!!stats_args)
  .plot_pca(pca_res, type = type, groups = groups, group_col = group_col)
}

.plot_pca <- function(pca_res, type = "individual", groups = NULL, group_col = NULL, ...) {
  rlang::check_installed("factoextra")
  checkmate::assert_choice(type, c("screeplot", "individual", "variables", "biplot"))
  .validate_group_args(groups, group_col)

  groups <- .prepare_groups(pca_res, groups, group_col)
  switch(type,
    screeplot = .plot_pca_screeplot(pca_res, ...),
    individual = .plot_pca_individual(pca_res, groups, ...),
    variables = .plot_pca_variables(pca_res, ...),
    biplot = .plot_pca_biplot(pca_res, groups, ...)
  )
}

.plot_pca_screeplot <- function(pca_res, ...) {
  factoextra::fviz_screeplot(pca_res$raw_result, ...)
}

.plot_pca_individual <- function(pca_res, groups, ...) {
  if (is.null(groups)) {
    factoextra::fviz_pca_ind(pca_res$raw_result, ...)
  } else {
    factoextra::fviz_pca_ind(pca_res$raw_result, habillage = groups, ...)
  }
}

.plot_pca_variables <- function(pca_res, ...) {
  factoextra::fviz_pca_var(pca_res$raw_result, ...)
}

.plot_pca_biplot <- function(pca_res, groups, ...) {
  if (is.null(groups)) {
    factoextra::fviz_pca_biplot(pca_res$raw_result, ...)
  } else {
    factoextra::fviz_pca_biplot(pca_res$raw_result, habillage = groups, ...)
  }
}
