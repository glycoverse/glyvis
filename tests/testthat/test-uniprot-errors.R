test_that("UniProt initialization failures include recovery guidance", {
  skip_if_not_installed("UniProt.ws")
  original <- errorCondition("Connection failed", class = "httr2_failure")
  local_mocked_bindings(
    UniProt.ws = function(...) stop(original),
    .package = "UniProt.ws"
  )

  err <- tryCatch(
    .fetch_uniprot_sequences("P02768", 9606L),
    glyvis_uniprot_error = identity
  )
  expect_s3_class(err, "glyvis_uniprot_error")
  expect_match(conditionMessage(err), "Failed to retrieve protein sequences")
  expect_match(conditionMessage(err), "try again later")
  expect_match(conditionMessage(err), "fasta")
  expect_match(conditionMessage(err), "add_site_seq")
  expect_identical(err$parent, original)
})

test_that("UniProt mapping failures retain the HTTP error and response", {
  skip_if_not_installed("UniProt.ws")
  original <- errorCondition(
    "HTTP 400 Bad Request.",
    class = "httr2_http_400",
    resp = list(body = '{"jobStatus":"ERROR","errors":[{"code":50}]}')
  )
  local_mocked_bindings(
    UniProt.ws = function(...) list(),
    select = function(...) stop(original),
    .package = "UniProt.ws"
  )

  err <- tryCatch(
    .fetch_uniprot_sequences("P02768", 9606L),
    glyvis_uniprot_error = identity
  )
  expect_s3_class(err, "glyvis_uniprot_error")
  expect_identical(err$parent, original)
  expect_identical(err$parent$resp, original$resp)
})

test_that("successful UniProt queries return sequences unchanged", {
  skip_if_not_installed("UniProt.ws")
  result <- data.frame(From = "P02768", Sequence = "MKWVTFISLL")
  local_mocked_bindings(
    UniProt.ws = function(taxId) {
      expect_identical(taxId, 9606L)
      "mock-client"
    },
    select = function(x, keys, columns, keytype) {
      expect_identical(x, "mock-client")
      expect_identical(keys, "P02768")
      expect_identical(columns, "sequence")
      expect_identical(keytype, "UniProtKB")
      result
    },
    .package = "UniProt.ws"
  )

  expect_identical(.fetch_uniprot_sequences("P02768", 9606L), result)
})
