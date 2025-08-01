#' Plots for Principal Component Analysis (PCA)
#'
#' Visualization for [glystats::gly_pca()] results (`glystats_pca_res` object).
#' Possible `type`s of plots:
#' - "screeplot": Scree plot to see the contribution of each PC.
#' - "individual" (default): Plot samples as individuals.
#' - "variables": Plot loadings for variables.
#' - "biplot": Biplot showing both samples and variables.
#'
#' @param object A `glystats_pca_res` object.
#' @param type The type of plot, one of "screeplot", "individual", "variables", or "biplot".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "individual" and "biplot" types.
#'   Passed to the `habillage` paramter of [factoextra::fviz_pca_ind()] or [factoextra::fviz_pca_biplot()].
#' @param group_col A character string specifying where to find the group information.
#'   If you uses [glystats::gly_pca()] on a [glyexp::experiment()] to get the result,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @param ... Other arguments passed to factoextra functions.
#'   - For "screeplot", see [factoextra::fviz_screeplot()].
#'   - For "individual", see [factoextra::fviz_pca_ind()].
#'   - For "variables", see [factoextra::fviz_pca_var()].
#'   - For "biplot", see [factoextra::fviz_pca_biplot()].
#'
#' @returns A ggplot object.
#' @seealso [factoextra::fviz_screeplot()], [factoextra::fviz_pca_ind()],
#'   [factoextra::fviz_pca_var()], [factoextra::fviz_pca_biplot()]
#' @export
autoplot.glystats_pca_res <- function(object, type = "individual", groups = NULL, group_col = NULL, ...) {
  .check_pkg_available("factoextra")
  checkmate::assert_choice(type, c("screeplot", "individual", "variables", "biplot"))
  .validate_group_args(groups, group_col)

  groups <- .prepare_groups(object, groups, group_col)

  switch(
    type,
    screeplot = .plot_pca_screeplot(object, ...),
    individual = .plot_pca_individual(object, groups, ...),
    variables = .plot_pca_variables(object, ...),
    biplot = .plot_pca_biplot(object, groups, ...)
  )
}

.plot_pca_screeplot <- function(object, ...) {
  factoextra::fviz_screeplot(object$raw_result, ...)
}

.plot_pca_individual <- function(object, groups, ...) {
  if (is.null(groups)) {
    factoextra::fviz_pca_ind(object$raw_result, ...)
  } else {
    factoextra::fviz_pca_ind(object$raw_result, habillage = groups, ...)
  }
}

.plot_pca_variables <- function(object, ...) {
  factoextra::fviz_pca_var(object$raw_result, ...)
}

.plot_pca_biplot <- function(object, groups, ...) {
  if (is.null(groups)) {
    factoextra::fviz_pca_biplot(object$raw_result, ...)
  } else {
    factoextra::fviz_pca_biplot(object$raw_result, habillage = groups, ...)
  }
}
