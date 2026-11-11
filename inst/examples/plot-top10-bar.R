# Reproducible synthetic glycoproteomic data with concrete monosaccharides.
# Counts and abundances below illustrate the plot; they are not measurements.
library(glyvis)

stem <- "Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-"
mannose <- c(
  paste0("Man(a1-3)[Man(a1-6)]", stem),
  paste0("Man(a1-3)[Man(a1-3)[Man(a1-6)]Man(a1-6)]", stem),
  paste0("Man(a1-2)Man(a1-3)[Man(a1-3)[Man(a1-6)]Man(a1-6)]", stem),
  paste0("Man(a1-2)Man(a1-3)[Man(a1-2)Man(a1-3)[Man(a1-6)]Man(a1-6)]", stem)
)
arm_g0 <- "GlcNAc(b1-2)"
arm_g1 <- "Gal(b1-4)GlcNAc(b1-2)"
arm_s1 <- "Neu5Ac(a2-6)Gal(b1-4)GlcNAc(b1-2)"
complex <- c(
  paste0(arm_g0, "Man(a1-3)[", arm_g0, "Man(a1-6)]", stem),
  paste0(arm_g1, "Man(a1-3)[", arm_g0, "Man(a1-6)]", stem),
  paste0(arm_g1, "Man(a1-3)[", arm_g1, "Man(a1-6)]", stem),
  paste0(arm_s1, "Man(a1-3)[", arm_g1, "Man(a1-6)]", stem),
  paste0(arm_s1, "Man(a1-3)[", arm_s1, "Man(a1-6)]", stem)
)
fucosylated <- sub("GlcNAc\\(b1-$", "[Fuc(a1-6)]GlcNAc(b1-", complex)
structures <- glyparse::auto_parse(c(mannose, complex, fucosylated))
counts <- c(
  95L,
  82L,
  70L,
  61L,
  58L,
  53L,
  49L,
  44L,
  39L,
  35L,
  31L,
  27L,
  23L,
  19L
)
index <- rep(seq_along(structures), counts)

example_se <- glyexp::GlycoproteomicSE(
  cbind(sample_A = rep(1, length(index)), sample_B = rep(2, length(index))),
  rowData = S4Vectors::DataFrame(
    protein = rep("ExampleProtein", length(index)),
    protein_site = sequence(counts),
    glycan_structure = structures[index],
    glycan_composition = glyrepr::as_glycan_composition(structures[index])
  ),
  metadata = list(glycan_type = "N", scale = "raw")
)

p_count <- plot_top10_bar(example_se)
p_abundance <- plot_top10_bar(example_se, weight = "abundance")
p_count
