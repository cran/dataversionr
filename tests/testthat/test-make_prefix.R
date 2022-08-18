# setup ------------------------------------------------------------------------
local_prefix <- tempfile()

# tests ------------------------------------------------------------------------
test_that("local make_prefix",
          {
            expect_invisible({
              make_prefix(LocalFileSystem$create()$cd(local_prefix))
            })
          })

test_that("local make_prefix string",
          {
            expect_invisible({
              make_prefix(local_prefix)
            })
          })


test_that("local dir now exists",
          {
            expect_true({
              dir.exists(local_prefix)
            })
          })

if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 make_prefix",
            {
              expect_invisible({
                make_prefix(s3$cd(local_prefix))
              })
            })

  test_that("s3 root make_prefix",
            {
              expect_invisible({
                make_prefix(s3dir)
              })
            })
}
# teardown ---------------------------------------------------------------------
withr::defer({
  unlink(local_prefix, recursive = TRUE)

  if (Sys.getenv("TEST_S3") == "TRUE") {
    s3$DeleteDirContents("dataversionr-tests/")
  }
})
