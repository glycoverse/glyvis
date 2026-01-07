# plot_logo UniProt.ws Fallback Design

## Summary

Add a UniProt.ws-backed fallback to `plot_logo()` when `site_sequence` is absent and
`fasta` is `NULL`, and introduce a `tax_id` argument defaulting to human (9606).

## Architecture and Data Flow

`plot_logo()` and `plot_logo.glyexp_experiment()` will accept a new `tax_id`
argument and pass it through to `.plot_exp_logo()`. The plot path remains the
same once a `site_sequence` column exists. When `site_sequence` is missing and
`fasta` is provided, we keep the existing `glyclean::add_site_seq()` workflow.
When `site_sequence` is missing and `fasta` is `NULL`, we fetch sequences using
UniProt.ws. We will validate the required columns (`protein` and
`protein_site`) and then query UniProt for the unique protein accessions with
`UniProt.ws::select()` using `keytype = "UniProtKB"` and `columns = "sequence"`.
We then map each row to a site-centered window of length `2 * n_aa + 1` using a
small internal helper that pads with "X" when the site is near the N/C termini.
The resulting `site_sequence` column is stored in the experiment and passed to
`ggseqlogo::ggseqlogo()` as before.

## Error Handling

If `protein` or `protein_site` columns are missing, or if sequences cannot be
retrieved for any accession, we raise a clear `cli_abort()` explaining the
problem and suggesting either providing a `fasta` file or precomputing
`site_sequence` with `glyclean::add_site_seq()`. We also validate that
`tax_id` is a positive integer and error if `protein_site` exceeds the sequence
length (this indicates inconsistent data or accession mismatch).

## Testing

Tests will be updated with a new case that calls `plot_logo(exp, tax_id = 9606)`
when `site_sequence` is absent and `fasta` is `NULL`. The test will be guarded
with `skip_if_not_installed("UniProt.ws")` and `skip_if_offline()` to avoid
network failures. The existing error test will be updated to only expect a
failure when UniProt.ws is unavailable or required columns are missing. Existing
snapshot tests remain, with updates only if the UniProt-backed case produces a
new snapshot.

## Documentation

Roxygen for `plot_logo()` will document the new `tax_id` argument and mention
that UniProt.ws is used when `site_sequence` is missing and `fasta` is `NULL`.
Then `devtools::document()` will update the `.Rd` files and `NAMESPACE`.
