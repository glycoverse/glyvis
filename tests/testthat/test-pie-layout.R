skip_if_not_installed("glydraw")
skip_if_not_installed("glydet")
skip_if_not_installed("glyrepr")

test_that("50 mm pie annotations remain separated across proportions", {
  withr::local_pdf(file = tempfile(fileext = ".pdf"))
  withr::local_seed(20261111)
  structure <- glyrepr::n_glycan_core()
  x <- glyexp::GlycomicSE(
    matrix(1, 1, 1),
    rowData = S4Vectors::DataFrame(
      glycan_structure = structure,
      glycan_composition = glyrepr::as_glycan_composition(structure)
    ),
    metadata = list(glycan_type = "N")
  )
  for (plot in list(plot_n_core_pie, plot_n_type_pie)) {
    df <- plot(x)$data
    n <- nrow(df)
    # Measure the widest possible percentage text with the real font/cartoons.
    df$value <- 1
    df$proportion <- 1
    labels <- .n_pie_labels(df, seq_len(n), 9 * 50 / 70, "sans", 0.08, 50 / 6.8)
    hw <- labels$box_width / 2
    hh <- labels$box_height / 2
    grid <- as.matrix(expand.grid(rep(list(0:20), n - 1)))
    grid <- grid[rowSums(grid) <= 20, , drop = FALSE]
    grid <- cbind(grid, 20 - rowSums(grid)) / 20
    random <- matrix(10^runif(500 * n, -14, 0), ncol = n)
    random <- random / rowSums(random)
    permutations <- as.matrix(expand.grid(rep(list(seq_len(n)), n)))
    permutations <- permutations[
      apply(permutations, 1, function(z) !anyDuplicated(z)),
      ,
      drop = FALSE
    ]
    tiny <- do.call(
      rbind,
      lapply(1:12, function(power) {
        v <- c(rep(10^-power, n - 1), 1)
        t(apply(permutations, 1, function(z) v[z] / sum(v)))
      })
    )
    cases <- rbind(grid, random, tiny)
    pairs <- utils::combn(seq_len(n), 2)
    failures <- vapply(
      seq_len(nrow(cases)),
      function(k) {
        proportions <- cases[k, ]
        angles <- 2 * pi * (cumsum(proportions) - proportions / 2)
        p <- .n_pie_label_layout(angles, which(proportions > 0), hw, hh)
        overlaps <- any(vapply(
          seq_len(ncol(pairs)),
          function(j) {
            ids <- pairs[, j]
            all(
              abs(p[ids[1], ] - p[ids[2], ]) <
                c(sum(hw[ids]), sum(hh[ids])) - 1e-9
            )
          },
          logical(1)
        ))
        touches_pie <- any(
          pmax(abs(p[, 1]) - hw, 0)^2 +
            pmax(abs(p[, 2]) - hh, 0)^2 <
            1 - 1e-9
        )
        outside <- any(abs(p[, 1]) + hw > 3.4 | abs(p[, 2]) + hh > 3.4)
        overlaps || touches_pie || outside
      },
      logical(1)
    )
    expect_false(
      any(failures),
      info = paste(
        n,
        "categories; failing proportions:",
        paste(
          capture.output(print(utils::head(cases[failures, , drop = FALSE]))),
          collapse = " "
        )
      )
    )
  }
})
