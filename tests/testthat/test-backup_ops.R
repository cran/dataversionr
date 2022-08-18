# setup ------------------------------------------------------------------------
local_prefix <- tempfile()

old_df <- data.frame(a = 1:5, b = letters[1:5])

new_df <- data.frame(a = 2:6, b = letters[2:6])
new_df[3, 2] <- "g"

# tests ------------------------------------------------------------------------
# get and put
test_that("local get backup",
          {
            expect_error({
              get_backups(local_prefix)
            })
          })

test_that("local put backup",
          {
            expect_true({
              put_backup(old_df, local_prefix)
            })
          })

test_that("local get backup",
          {
            expect_equal({
              get_backups(local_prefix) %>% select(-backup_timestamp)
            }, old_df)
          })


if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 get backup",
            {
              expect_error({
                get_backups(s3dir)
              }, "No such file or directory")
            })


  test_that("s3 put backup",
            {
              expect_true({
                put_backup(old_df, s3dir)
              })
            })

  test_that("s3 get backup",
            {
              expect_equal({
                get_backups(s3dir) %>% select(-backup_timestamp)
              }, old_df)
            })

  # delete backups s3
  for (i in seq_along(1:10)) {
    put_backup(old_df, s3dir)
  }

  prior_backups <- s3dir$cd("backup")$ls()

  test_that("s3 delete backup",
            {
              expect_true({
                delete_backup(s3dir, after_position = 4L)
              })
            })

  s3_post_backups <- s3dir$cd("backup")$ls()

  test_that("s3 delete backup verify",
            {
              expect_equal({
                sort(prior_backups, decreasing = TRUE)[1:4]
              },
              sort(s3_post_backups, decreasing = TRUE))
            })

}
# delete backups local
for (i in seq_along(1:10)) {
  put_backup(old_df, local_prefix)
}

prefix_path <- fix_path("backup", local_prefix)
prefix_path <- make_SubTreeFileSystem(prefix_path)

prior_backups <- prefix_path$ls()

# Adding to handle https://issues.apache.org/jira/browse/ARROW-16421 ##
gc()
#######################################################################


test_that("local_prefix delete backup",
          {
            expect_true({
              delete_backup(local_prefix, after_position = 4L)
            })
          })

local_post_backups <- prefix_path$ls()

# Adding to handle https://issues.apache.org/jira/browse/ARROW-16421 ##
gc()
#######################################################################


test_that("local_prefix delete backup verify",
          {
            expect_equal({
              sort(prior_backups, decreasing = TRUE)[1:4]
            },
            sort(local_post_backups, decreasing = TRUE))
          })


# retrieve_backup
# let some time elapse
Sys.sleep(60)

# retrieve_backup s3
if (Sys.getenv("TEST_S3") == "TRUE") {
  old_backups <- s3dir$cd("backup")$ls()

  for (i in seq_along(1:10)) {
    put_backup(new_df, s3dir)
  }

  test_that("s3 read_dv_backup",
            {
              expect_equal({
                read_dv_backup(s3dir, as_of = lubridate::now() - seconds(30))
              },
              old_df)
            })

  test_that("read_dv_backup too far back",
            {
              expect_error({
                read_dv_backup(s3dir, as_of = lubridate::now() - hours(30))
              },
              "No backups older")
            })
}

# retrieve_backup local
old_backups <- prefix_path$ls()
correct_backup_ts <-
  lubridate::as_datetime(as.numeric(tools::file_path_sans_ext(sort(
    old_backups, decreasing = TRUE
  ))))[1]

for (i in seq_along(1:10)) {
  put_backup(new_df, local_prefix)
}

test_that("local read_dv_backup",
          {
            expect_equal({
              read_dv_backup(local_prefix, as_of = lubridate::now() - seconds(30))
            },
            old_df)
          })


# teardown ---------------------------------------------------------------------
withr::defer({
  unlink(local_prefix, recursive = TRUE)

  if (Sys.getenv("TEST_S3") == "TRUE") {
    s3$DeleteDirContents("dataversionr-tests/")
  }
})
