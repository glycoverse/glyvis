legacy_toy_experiment <- function() {
  structure(
    list(
      expr_mat = matrix(
        1:24,
        nrow = 4,
        dimnames = list(paste0("V", 1:4), paste0("S", 1:6))
      ),
      sample_info = tibble::tibble(
        sample = paste0("S", 1:6),
        group = rep(c("A", "B"), each = 3),
        batch = rep(1:2, 3)
      ),
      var_info = tibble::tibble(
        variable = paste0("V", 1:4),
        protein = c("PRO1", "PRO2", "PRO3", "PRO3"),
        peptide = paste0("PEP", 1:4),
        glycan_composition = c("H5N2", "H5N2", "H3N2", "H3N2")
      ),
      meta_data = list(exp_type = "others", glycan_type = "N")
    ),
    class = "glyexp_experiment"
  )
}
