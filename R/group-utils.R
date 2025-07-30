#' Prepare group information for analysis
#'
#' @description
#' This function prepares group information for analysis by validating and converting
#' the input to a factor. It also checks for the minimum and maximum number of groups
#' required for the analysis.
#'
#' It follows the following logic:
#' 1. If `groups` is provided, it is used as the group information.
#'    Length of `groups` will be checked against the number of samples in `object`.
#' 2. If `groups` is not provided but `group_col` is, `group_extractor` will be used
#'    to extract group information from `object` using `group_col`.
#'    An error will be thrown if `group_col` does not exist in `object`.
#' 3. If neither `groups` nor `group_col` is provided, try to use the "group" column in `object`.
#'    If "group" column does not exist, return NULL.
#'
#' @param object The input object (e.g. experiment, `glystats` results, etc.).
#' @param groups Input group information (factor or character vector).
#'   Must be named by sample names. This ensures the group information is correctly aligned
#'   with the sample information in `object`.
#' @param group_col Column name of the group information in the sample information.
#' @param group_extractor Function to extract group information from sample information.
#'   It should have signature `function(object, group_col)`.
#'   It should return NULL if `group_col` does not exist in `object`,
#'   and return a named-by-samples factor vector if it exists.
#'   Default to `.default_group_extractor`.
#'
#' @returns A factor vector of group information, or NULL if no valid group information is provided.
#'
#' @keywords internal
#' @noRd
.prepare_groups <- function(object, groups, group_col, group_extractor = .default_group_extractor) {
  # Get sample names from object
  samples <- .get_samples(object)

  # Case 1: `groups` is specified
  # Use `groups` directly and ignore `group_col`
  if (!is.null(groups)) {
    return(.prepare_groups_from_groups_arg(groups, samples))
  }

  # Case 2: `groups` not specified but `group_col` is specified
  # Check column existence, and extract from `object$tidy_result$samples`.
  if (!is.null(group_col)) {
    return(.prepare_groups_from_group_col_arg(object, samples, group_col, group_extractor))
  }

  # Case 3: neither is specified: try "group" (if exists)
  groups <- group_extractor(object, "group")
  return(groups[samples])  # either NULL or extracted groups
}

#' Get samples from object
#'
#' This function scans all tibbles in `object$tidy_result` for the "sample" column,
#' and returns the unique values.
#'
#' @param object The input object (e.g. experiment, `glystats` results, etc.).
#' @returns A character vector of sample names.
#' @keywords internal
#' @noRd
.get_samples <- function(object) {
  abort_no_sample <- function() {
    cli::cli_abort(c(
      "Can't extract sample information from {.arg object}.",
      "i" = "It's not you, it's us. Please report this bug."
    ))
  }

  tidy_result <- object$tidy_result

  # Case 1: `tidy_result` is a single tibble
  if (tibble::is_tibble(tidy_result)) {
    samples <- unique(tidy_result$sample)
    if (is.null(samples)) {
      abort_no_sample()
    }
    return(samples)
  }
  # Case 2: `tidy_result` is a list of tibbles
  df <- purrr::detect(tidy_result, ~ "sample" %in% colnames(.x))
  if (is.null(df)) {
    abort_no_sample()
  }
  return(unique(df$sample))
}

.prepare_groups_from_groups_arg <- function(groups, samples) {
  # Case 1-1: `groups` has incorrect length
  if (length(groups) != length(samples)) {
    cli::cli_abort(c(
      "Length of {.arg groups} must be equal to the number of samples.",
      "i" = "Number of samples: {.val {length(samples)}}.",
      "i" = "Length of {.arg groups}: {.val {length(groups)}}."
    ))
  }
  # Case 1-2: `groups` is not named
  if (!rlang::is_named(groups)) {
    cli::cli_abort("{.arg groups} must be named by sample names.")
  }
  # Case 1-3: `groups` is not aligned with sample names
  if (!setequal(names(groups), samples)) {
    not_in_samples <- setdiff(names(groups), samples)
    not_in_groups <- setdiff(samples, names(groups))
    cli::cli_abort(c(
      "Sample names in {.arg groups} must match those in {.arg object}.",
      "x" = "Samples in {.arg groups} but not in {.arg object}: {.val {not_in_samples}}.",
      "x" = "Samples in {.arg object} but not in {.arg groups}: {.val {not_in_groups}}."
    ))
  }
  # Case 1-4: `groups` is valid, reorder and return
  return(groups[samples])  # reorder groups to match sample order
}

.prepare_groups_from_group_col_arg <- function(object, samples, group_col, group_extractor) {
  groups <- group_extractor(object, group_col)
  if (is.null(groups)) {
    cli::cli_abort(c(
      "Column {.field {group_col}} not found.",
      "i" = "Does your `glyexp::experiment()` contain the {.field {group_col}} column in the sample information tibble?"
    ))
  }
  return(groups[samples])  # reorder groups to match sample order
}

.default_group_extractor <- function(object, group_col) {
  tibble_group_extractor <- function(df, group_col) {
    if (!group_col %in% colnames(df)) {
      return(NULL)
    }
    df <- dplyr::distinct(df, .data$sample, .data[[group_col]])
    groups <- df[[group_col]]
    names(groups) <- df$sample
    groups
  }

  if (tibble::is_tibble(object$tidy_result)) {
    return(tibble_group_extractor(object$tidy_result, group_col))
  } else {
    for (df in object$tidy_result) {
      groups <- tibble_group_extractor(df, group_col)
      if (!is.null(groups)) {
        return(groups)
      }
    }
    return(NULL)
  }
}