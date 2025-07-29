# Helper functions for glyvis tests

# Create a simple dataset for OPLS-DA testing
exp_for_oplsda <- function() {
  test_gp_exp |>
    glyexp::slice_head_var(n = 2) |>
    glyexp::mutate_obs(group = dplyr::if_else(group %in% c("H", "M"), "control", "case"))
}
