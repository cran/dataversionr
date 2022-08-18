# setup ------------------------------------------------------------------------
local_prefix <- tempfile()
if (Sys.getenv("TEST_S3") == "TRUE") {
  s3_prefix <- fix_path("prefix", s3dir)
}
filename <- "file-test.csv"
df <- iris
make_prefix(local_prefix)
write.csv(df, file.path(local_prefix, filename))
if (Sys.getenv("TEST_S3") == "TRUE") {
  aws.s3::put_object(
    file.path(local_prefix, filename),
    file.path("prefix", filename),
    bucket,
    key = "minio",
    secret = "password",
    base_url = "localhost:9000",
    region = "",
    use_https = "false"
  )
}

# tests ------------------------------------------------------------------------
test_that("local verify file exists",
          {
            expect_true({
              file.exists(file.path(local_prefix, filename))
            })
          })


test_that("local remove prefix",
          {
            expect_true({
              remove_prefix(local_prefix, prompt = FALSE)
            })
          })

test_that("local verify object doesn't exist",
          {
            expect_false({
              file.exists(file.path(local_prefix,  filename))
            })
          })

test_that("local remove root filesystem fails",
          {
            expect_error(
              remove_prefix(LocalFileSystem$create()),
              'destination parameter must be a string or SubTreeFileSystem'
            )
          })

if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 verify file exists",
            {
              expect_true({
                aws.s3::object_exists(
                  file.path("prefix", filename),
                  bucket,
                  key = "minio",
                  secret = "password",
                  base_url = "localhost:9000",
                  region = "",
                  use_https = "false"
                )
              })
            })


  test_that("s3 remove prefix",
            {
              expect_true({
                remove_prefix(destination = s3_prefix, prompt = FALSE)
              })
            })

  test_that("s3 verify file does not exist",
            {
              expect_false({
                aws.s3::object_exists(
                  file.path("prefix", filename),
                  bucket,
                  key = "minio",
                  secret = "password",
                  base_url = "localhost:9000",
                  region = "",
                  use_https = "false"
                )
              })
            })


  test_that("s3 remove bucket contents ",
            {
              expect_true(remove_prefix(s3dir, prompt = FALSE))
            })


  test_that("s3 bucket remove_prefix worked",
            {
              expect_equal({
                s3dir$ls()
              },
              character(0))
            })
}
# teardown ---------------------------------------------------------------------
withr::defer({
  unlink(local_prefix, recursive = TRUE)

  if (Sys.getenv("TEST_S3") == "TRUE") {
    s3$DeleteDirContents("dataversionr-tests/")
  }
})
