# Read the explicit result schema, not metadata column names. Saved results and
# deprecated experiment results retain their original unprefixed identifiers.
.result_id_column <- function(object, axis) {
  columns <- object$identifiers$columns
  if (is.null(columns)) {
    return(axis)
  }
  column <- unname(columns[[axis]])
  checkmate::assert_string(column)
  column
}

# Select display rows without changing values or duplicating observations.
.select_result_variables <- function(data, id_col, variables) {
  if (is.null(variables)) {
    return(data)
  }
  checkmate::assert_character(variables, any.missing = FALSE, min.len = 1L)
  ids <- data[[id_col]]
  missing_variables <- setdiff(variables, ids)
  if (length(missing_variables) > 0L) {
    cli::cli_abort(
      "Can't find variables in the selected result: {.val {missing_variables}}."
    )
  }
  data[ids %in% variables, , drop = FALSE]
}
