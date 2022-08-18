# setup ------------------------------------------------------------------------
# Create a fairly varied dataframe
all_df <- lubridate::lakers
rownames(all_df) <- c()
all_df$dttm <- lubridate::as_datetime(as.character(all_df$date))
all_df$dt <- lubridate::as_datetime(as.character(all_df$date))
all_df$fct <- as.factor(all_df$game_type)
all_df$key1 <- seq(1:nrow(all_df))
all_df$key2 <- all_df$fct

old_df <- all_df[1:5, ]
rownames(old_df) <- c()

new_df <- all_df[5:10, ]
new_df[5, 2] <- "g"
rownames(new_df) <- c()

newer_df <- all_df[10:15, ]
rownames(newer_df) <- c()

local_prefix <- tempfile()

# tests ------------------------------------------------------------------------
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3dir create_dv",
            {
              expect_true({
                create_dv(
                  old_df,
                  s3dir,
                  key_cols = c("key1", "key2"),
                  diffed = TRUE,
                  backup_count = 4L
                )
              })
            })
}

test_that("local create_dv",
          {
            expect_true({
              create_dv(
                old_df,
                local_prefix,
                key_cols = c("key1", "key2"),
                diffed = TRUE,
                backup_count = 4L
              )
            })
          })

test_that("overwrite create_dv fails",
          {
            expect_error({
              create_dv(
                old_df,
                local_prefix,
                key_cols = c("key1", "key2"),
                diffed = TRUE,
                backup_count = 4L
              )
            },
            "destination is not empty.")
          })

old_ts <- lubridate::now()

if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 update_dv",
            {
              expect_true({
                update_dv(new_df, s3dir)
              })
            })
}

test_that("local update_dv",
          {
            expect_true({
              update_dv(new_df, local_prefix)
            })
          })


new_ts <- lubridate::now()

if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 update_dv again",
            {
              expect_true({
                update_dv(newer_df, s3dir)
              })
            })
}

test_that("local update_dv again",
          {
            expect_true({
              update_dv(newer_df, local_prefix)
            })
          })

newer_ts <- lubridate::now()

test_that("local read_dv",
          {
            expect_equal({
              read_dv(local_prefix)
            },
            newer_df)
          })


test_that("local read_dv via diff",
          {
            expect_equal({
              read_dv(local_prefix, as_of = old_ts, source = "diffs") %>% select(sort(colnames(.)))
            },
            old_df %>% select(sort(colnames(.))))
          })

test_that("local read_dv via backup",
          {
            expect_equal({
              read_dv(local_prefix, as_of = new_ts, source = "backup") %>% select(sort(colnames(.)))
            },
            new_df %>% select(sort(colnames(.))))
          })

test_that("local read_dv latest timestmap error",
          {
            expect_error({
              read_dv(local_prefix, as_of = newer_ts, source = "latest")
            },
            "parameter latest only works with parameter as_of set to NA.")
          })

# Adding to handle https://issues.apache.org/jira/browse/ARROW-16421 ##
gc()
#######################################################################

test_that("local destroy_dv",
          {
            expect_true({
              destroy_dv(local_prefix, prompt = FALSE)
            })
          })

if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 destroy_dv",
            {
              expect_true({
                destroy_dv(s3dir, prompt = FALSE)
              })
            })
}

test_that("local destroy_dv worked",
          {
            expect_equal({
              list.files(local_prefix)
            },
            character(0))
          })

if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 destroy_dv worked",
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
