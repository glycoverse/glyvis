# Helper functions for glyvis tests

test_gp_se <- glyexp::as_glycoproteomic_se(test_gp_exp)

subset_test_gp_se <- function(
  exp = test_gp_se,
  variables = NULL,
  groups = NULL
) {
  if (!is.null(variables)) {
    exp <- exp[variables, , drop = FALSE]
  }
  if (!is.null(groups)) {
    exp <- exp[,
      SummarizedExperiment::colData(exp)$group %in% groups,
      drop = FALSE
    ]
  }
  exp
}

set_test_gp_col <- function(exp = test_gp_se, col, value) {
  SummarizedExperiment::colData(exp)[[col]] <- value
  exp
}

drop_test_gp_col <- function(exp = test_gp_se, col) {
  SummarizedExperiment::colData(exp)[[col]] <- NULL
  exp
}

new_test_se <- function(expr_mat, sample_info, var_info) {
  SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = expr_mat),
    colData = S4Vectors::DataFrame(
      sample_info,
      row.names = sample_info$sample
    ),
    rowData = S4Vectors::DataFrame(
      var_info,
      row.names = var_info$variable
    )
  )
}

exp_for_oplsda <- function() {
  exp <- subset_test_gp_se(variables = seq_len(2))
  SummarizedExperiment::colData(exp)$group <- dplyr::if_else(
    SummarizedExperiment::colData(exp)$group %in% c("H", "M"),
    "control",
    "case"
  )
  exp
}

exp_for_plsda <- function() {
  exp <- subset_test_gp_se(variables = seq_len(3))
  SummarizedExperiment::colData(exp)$group <- dplyr::if_else(
    SummarizedExperiment::colData(exp)$group %in% c("H", "M"),
    "control",
    "case"
  )
  exp
}
