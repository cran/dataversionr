# setup ------------------------------------------------------------------------
local_prefix <- tempfile()

correct_metadata <- list()
correct_metadata$schema_ver <- "20220727"
if (Sys.getenv("TEST_S3") == "TRUE") {
  correct_metadata$base_path <- s3dir$base_path
} else {
  # test local generate_metadata
  correct_metadata$base_path <-
    make_SubTreeFileSystem(local_prefix)$base_path

}
correct_metadata$key_cols <- c("a", "b")
correct_metadata$diffed <- TRUE
correct_metadata$backup_count <- 4L

# Create sample dataframe
numbers <- 1:6
letters2 <- c("s", "j", "f", "u", "l", "i")

new_df <- data.frame(a = numbers[2:6], b = letters2[2:6])
new_df[3, 2] <- "update"

# tests ------------------------------------------------------------------------
# test s3 generate_metadata
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 generate_metadata",
            {
              expect_equal({
                generate_metadata(
                  new_df,
                  s3dir,
                  key_cols = c("a", "b"),
                  diffed = TRUE,
                  backup_count = 4L
                )
              },
              correct_metadata)
            })

}
# test local generate_metadata
correct_metadata$base_path <-
  make_SubTreeFileSystem(local_prefix)$base_path

test_that("local generate_metadata",
          {
            expect_equal({
              generate_metadata(
                new_df,
                local_prefix,
                key_cols = c("a", "b"),
                diffed = TRUE,
                backup_count = 4L
              )
            },
            correct_metadata)
          })


# test bad df
test_that("bad df",
          {
            expect_error({
              generate_metadata(
                "bad",
                local_prefix,
                key_cols = c("a", "b"),
                diffed = TRUE,
                backup_count = 4L
              )
            },
            "parameter df is not a dataframe.")
          })


# test non diffable df
test_that("non diffable df",
          {
            expect_error({
              generate_metadata(
                iris,
                local_prefix,
                key_cols = NA,
                diffed = TRUE,
                backup_count = 4L
              )
            },
            "The new_df key columns do not contain unique rows.")
          })


# test bad key cols
test_that("bad key cols",
          {
            expect_error({
              generate_metadata(
                new_df,
                local_prefix,
                key_cols = c("a", "c"),
                diffed = TRUE,
                backup_count = 4L
              )
            },
            "key_cols are not present")
          })


# test NA key cols
test_that("NA keu cols",
          {
            expect_equal({
              generate_metadata(
                new_df,
                local_prefix,
                key_cols = NA,
                diffed = TRUE,
                backup_count = 4L
              )
            },
            correct_metadata)
          })


# test bad diffed
test_that("bad diffed param",
          {
            expect_error({
              generate_metadata(
                new_df,
                local_prefix,
                key_cols = c("a", "b"),
                diffed = "TRUE",
                backup_count = 4L
              )
            },
            "parameter diffed must be TRUE/FALSE.")
          })



# test bad backup_count
test_that("bad diffed param",
          {
            expect_error({
              generate_metadata(
                new_df,
                local_prefix,
                key_cols = c("a", "b"),
                diffed = TRUE,
                backup_count = "4L"
              )
            },
            "parameter backup_count must be an integer")
          })

# put_metadata s3
if (Sys.getenv("TEST_S3") == "TRUE") {
  s3meta <- generate_metadata(
    new_df,
    s3dir,
    key_cols = c("a", "b"),
    diffed = TRUE,
    backup_count = 4L
  )

  test_that("put_metadata s3",
            {
              expect_true({
                put_metadata(s3meta, s3dir, verbose = TRUE)
              })
            })
}

# put_metadata local
local_meta <- generate_metadata(
  new_df,
  local_prefix,
  key_cols = c("a", "b"),
  diffed = TRUE,
  backup_count = 4L
)

test_that("put_metadata local",
          {
            expect_true({
              put_metadata(local_meta, local_prefix, verbose = TRUE)
            })
          })

# get metadata s3
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("get_metadata s3",
            {
              expect_equal({
                get_metadata(s3dir, verbose = TRUE)
              },
              s3meta)
            })
}

# get metadata local
test_that("get_metadata local",
          {
            expect_equal({
              get_metadata(local_prefix, verbose = TRUE)
            },
            local_meta)
          })


# teardown ---------------------------------------------------------------------
withr::defer({
  unlink(local_prefix, recursive = TRUE)

  if (Sys.getenv("TEST_S3") == "TRUE") {
    s3$DeleteDirContents("dataversionr-tests/")
  }
})
