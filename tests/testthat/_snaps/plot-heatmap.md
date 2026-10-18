# custom trees are validated after zero-variance filtering

    Code
      do.call(plot_heatmap, c(list(x), args))
    Condition
      Warning:
      Removed 1 variable with zero variance from heatmap:
      i Variables: "constant"
      Error in `.validate_heatmap_tree()`:
      ! `cluster_rows` must match the retained heatmap dimensions and their input order.
      i Zero-variance rows and columns are removed before plotting.
      i Rebuild the tree using the retained rows or columns in input order, or omit `cluster_rows` to compute it automatically.

---

    Code
      do.call(plot_heatmap, c(list(x), args))
    Condition
      Warning:
      Removed 1 sample with zero variance from heatmap:
      i Samples: "constant"
      Error in `.validate_heatmap_tree()`:
      ! `cluster_cols` must match the retained heatmap dimensions and their input order.
      i Zero-variance rows and columns are removed before plotting.
      i Rebuild the tree using the retained rows or columns in input order, or omit `cluster_cols` to compute it automatically.

