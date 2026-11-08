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
