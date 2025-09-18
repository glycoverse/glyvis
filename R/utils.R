.check_pkg_available <- function(pkg, install_hint = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (is.null(install_hint)) {
      install_hint <- stringr::str_glue("install.packages('{pkg}')")
    }
    cli::cli_abort(c(
      "Package {.pkg {pkg}} is required for this analysis.",
      "i" = "Install it with: {.code {install_hint}}"
    ))
  }
}

.assert_exp_type <- function(exp, type) {
  if (glyexp::get_exp_type(exp) != type) {
    cli::cli_abort(c(
      "The experiment type must be {.val {type}}.",
      "i" = "Current experiment type: {.val {glyexp::get_exp_type(exp)}}"
    ))
  }
}