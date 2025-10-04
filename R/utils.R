.assert_exp_type <- function(exp, type) {
  if (glyexp::get_exp_type(exp) != type) {
    cli::cli_abort(c(
      "The experiment type must be {.val {type}}.",
      "i" = "Current experiment type: {.val {glyexp::get_exp_type(exp)}}"
    ))
  }
}