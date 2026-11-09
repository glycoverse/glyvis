# glyvis

The goal of glyvis is to visualize everything in the `glycoverse`
ecosystem. Visualization is an essential part of data analysis. Human
beings are more sensitive to visual information than text and numbers.
Plotting helps us to understand the data better. `glyvis` provides a
unified interface for visualizing `glycoverse` data, including
statistical results and experimental data. It implements the
[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
method for various `glycoverse` data structures. Just
[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
it!

## Installation

### Install glycoverse

We recommend installing the meta-package
[glycoverse](https://github.com/glycoverse/glycoverse), which includes
this package and other core glycoverse packages.

### Install glyvis alone

If you don’t want to install all glycoverse packages, you can only
install glyvis.

You can install the latest release of glyvis from
[r-universe](https://glycoverse.r-universe.dev/glyvis)
(**recommended**):

``` r

# install.packages("pak")
pak::repo_add(glycoverse = "https://glycoverse.r-universe.dev")
pak::pkg_install("glyvis")
```

Or from [GitHub](https://github.com/glycoverse/glyvis):

``` r

pak::pkg_install("glycoverse/glyvis@*release")
```

Or install the development version (NOT recommended):

``` r

pak::pkg_install("glycoverse/glyvis")
```

**Note:** Tips and troubleshooting for the meta-package
[glycoverse](https://github.com/glycoverse/glycoverse) are also
applicable here: [Installation of
glycoverse](https://github.com/glycoverse/glycoverse#installation).

## Documentation

- 🚀 Get started:
  [Here](https://glycoverse.github.io/glyvis/articles/glyvis.html)
- 📚 Reference:
  [Here](https://glycoverse.github.io/glyvis/reference/index.html)

## Role in `glycoverse`

The main purpose of `glyvis` is to provide visualization for `glystats`
results. It implements
[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
methods for each result class in `glystats`, so that the users can
visualize the results directly to get a quick overview. It also provides
some other visualization functions for `glycoverse` data structures,
such as
[`glyexp::GlycomicSE`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
[`glyexp::GlycoproteomicSE`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html),
and others. All plotting entry points use
[tidyplots](https://tidyplots.org/) and return composable `tidyplot`
objects. Defaults use a white background, restrained colors, and
readable typography; adjust the returned plot for your output size and
audience.

## Example

``` r

library(glyexp)
library(glyclean)
library(glystats)
library(glyvis)

set.seed(42)
exp <- auto_clean(real_experiment)

pca_res <- gly_pca(exp)
autoplot(pca_res)
```

![](reference/figures/README-pca.svg)
