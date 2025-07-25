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
  checkmate::assert(
    checkmate::check_factor(groups),
    checkmate::check_character(groups),
    checkmate::check_null(groups)
  )

  groups <- .get_pca_groups(object, groups, group_col)

  switch(
    type,
    screeplot = .plot_pca_screeplot(object, ...),
    individual = .plot_pca_individual(object, groups, ...),
    variables = .plot_pca_variables(object, ...),
    biplot = .plot_pca_biplot(object, groups, ...)
  )
}

.get_pca_groups <- function(object, groups, group_col) {
  # Case 1: `groups` is specified: use `groups` directly and ignore `group_col`
  if (!is.null(groups)) {
    if (length(groups) != length(unique(object$tidy_result$samples$sample))) {
      cli::cli_abort(c(
        "Length of {.arg groups} must be equal to the number of samples.",
        "i" = "Number of samples: {.val {length(unique(object$tidy_result$samples$sample))}}.",
        "i" = "Length of {.arg groups}: {.val {length(groups)}}."
      ))
    }
    return(groups)
  }

  # Case 2: `group_col` is specified: check existence, and extract from `object$tidy_result$samples`
  if (!is.null(group_col)) {
    if (!group_col %in% colnames(object$tidy_result$samples)) {
      cli::cli_abort(c(
        "Column {.val {group_col}} not found.",
        "i" = "Does your `glyexp::experiment()` contain the column in the sample information tibble?"
      ))
    }
    return(.get_groups_from_pca_res(object, group_col))
  }

  # Case 3: both are not specified: try "group"
  if ("group" %in% colnames(object$tidy_result$samples)) {
    return(.get_groups_from_pca_res(object, "group"))
  }

  # Case 4: neither is specified and "group" doesn't exist: return NULL
  return(NULL)
}

.get_groups_from_pca_res <- function(object, group_col) {
  object$tidy_result$samples %>%
    dplyr::distinct(.data$sample, .data[[group_col]]) %>%
    dplyr::pull(.data[[group_col]])
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
