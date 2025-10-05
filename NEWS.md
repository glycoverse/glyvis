# glyvis 0.3.0

## New features

* Add a `test` parameter to `plot_volcano()` to specify the statistical test type.
* Add `plot_boxplot()` to plot grouped boxplots for experiment objects.
* ROC curves can be plotted for `glystats::gly_roc()` results using `autoplot()` now.
* Add `plot_roc()` to plot ROC curves directly from experiment objects.

## Minor improvements and bug fixes

* Better volcano plots using `EnhancedVolcano` package.
* Fix the inconsistent behaviour of plotting experiment objects with `autoplot()`. Previously, boxplots were actually plotted when `type = "barplot"`. Now boxplots grouped by the group column are plotted, faceted by variables, when `type = "boxplot"`.
* Use `rlang::check_installed()` for better optional dependency checking.

# glyvis 0.2.1

## Minor improvements and bug fixes

* Adapt to the breaking changes in `glystats` v0.5.0.

# glyvis 0.2.0

## New features

* Add `plot_logo()` to plot logo plots for glycosites.

## Minor improvements and bug fixes

* Re-export `autoplot()` from `ggplot2` to prevent the 'could not find function "autoplot"' error when `ggplot2` is not loaded.
* Add a Get Started vignette.

# glyvis 0.1.2

## Minor improvements and bug fixes

* Update dependencies to depend on release versions of glycoverse packages.

# glyvis 0.1.1

## Minor improvements and bug fixes

* Fix bugs in tests introduced by `glyexp` v0.8.0.

# glyvis 0.1.0

* First release.
