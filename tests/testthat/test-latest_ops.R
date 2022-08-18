# setup ------------------------------------------------------------------------
local_prefix <- tempfile()

# Create sample dataframe
numbers <- 1:6
letters2 <- c("s", "j", "f", "u", "l", "i")

new_df <- data.frame(a = numbers[2:6], b = letters2[2:6])
new_df[3, 2] <- "update"


# tests ------------------------------------------------------------------------
test_that("local get latest",
          {
            expect_error({
              get_latest(local_prefix)
            })
          })

test_that("local put latest",
          {
            expect_true({
              put_latest(new_df, local_prefix)
            })
          })

test_that("local get latest",
          {
            expect_equal({
              get_latest(local_prefix)
            }, new_df)
          })

if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 get latest",
            {
              expect_error({
                get_latest(s3dir)
              }, "No such file or directory")
            })


  test_that("s3 put latest",
            {
              expect_true({
                put_latest(new_df, s3dir)
              })
            })

  test_that("s3 get latest",
            {
              expect_equal({
                get_latest(s3dir)
              }, new_df)
            })
}
# teardown ---------------------------------------------------------------------
withr::defer({
  unlink(local_prefix, recursive = TRUE)

  if (Sys.getenv("TEST_S3") == "TRUE") {
    s3$DeleteDirContents("dataversionr-tests/")
  }
})
