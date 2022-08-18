# setup ------------------------------------------------------------------------
# Create sample dataframe
old_df <- data.frame(a = 1:5, b = letters[1:5])
new_df <- data.frame(a = 2:6, b = letters[2:6])
new_df[3, 2] <- "g"
newer_df <- old_df
first_diff <- diffdfs::diffdfs(old_df, key_cols = c("a", "b"))
diff_df <- diffdfs::diffdfs(new_df, old_df, key_cols = c("a", "b"))
newer_diff_df <-
  diffdfs::diffdfs(newer_df, new_df, key_cols = c("a", "b"))

# Clean out prefixes
local_prefix <- tempfile()
unlink(local_prefix, recursive = TRUE)
if (Sys.getenv("TEST_S3") == "TRUE") {
  s3$DeleteDirContents("dataversionr-tests/")
}


# tests ------------------------------------------------------------------------
# commit_diff diff 1
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 commit diff works",
            {
              expect_true(commit_diff(first_diff,
                                      s3dir,
                                      verbose = TRUE))
            })
}

test_that("local commit diff works",
          {
            expect_true(commit_diff(first_diff,
                                    local_prefix,
                                    verbose = TRUE))
          })

# commit_diff diff 2
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 commit diff works",
            {
              expect_true(commit_diff(diff_df,
                                      s3dir,
                                      verbose = TRUE))
            })
}

test_that("local commit diff works",
          {
            expect_true(commit_diff(diff_df,
                                    local_prefix,
                                    verbose = TRUE))
          })


# get_diffs
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 retrieve diff works", {
    expect_equal(
      get_diffs(s3dir) %>% filter(diff_timestamp == max(diff_timestamp)) %>% select(-diff_timestamp),
      diff_df
    )
  })
}

test_that("local retrieve diff works", {
  expect_equal(
    get_diffs(local_prefix)  %>% filter(diff_timestamp == max(diff_timestamp)) %>% select(-diff_timestamp),
    diff_df
  )
})


# summarise_diffs
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 summarise_diffs ", {
    expect_equal(
      summarise_diffs(s3dir)  %>% select(-diff_timestamp) %>% arrange(new),
      data.frame(
        new = c(2L, 5L),
        deleted = c(2L, NA),
        modified = c(0L, 0L)
      )
    )
  })
}

test_that("local summarise_diffs ", {
  expect_equal(
    summarise_diffs(local_prefix) %>% select(-diff_timestamp) %>% arrange(new),
    data.frame(
      new = c(2L, 5L),
      deleted = c(2L, NA),
      modified = c(0L, 0L)
    )
  )
})

# put_diff_stats
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 put_diff_stats ", {
    expect_true(put_diff_stats(s3dir))
  })
}

test_that("local put_diff_stats ", {
  expect_true(put_diff_stats(local_prefix))
})

# get_diff_stats
if (Sys.getenv("TEST_S3") == "TRUE") {
  test_that("s3 get_diff_stats", {
    expect_equal(
      get_diff_stats(s3dir) %>% select(-diff_timestamp) %>% arrange(new),
      data.frame(
        new = c(2L, 5L),
        deleted = c(2L, NA),
        modified = c(0L, 0L)
      )
    )
  })
}

test_that("local get_diff_stats", {
  expect_equal(
    get_diff_stats(local_prefix) %>% select(-diff_timestamp) %>% arrange(new),
    data.frame(
      new = c(2L, 5L),
      deleted = c(2L, NA),
      modified = c(0L, 0L)
    )
  )
})

# read_dv_diff
# let some time elapse
Sys.sleep(60)

# read_dv_diff s3
if (Sys.getenv("TEST_S3") == "TRUE") {
  as_of <- lubridate::now() - seconds(30)
  commit_diff(newer_diff_df,
              s3dir)

  test_that("s3 retrieve_dv_backup",
            {
              expect_equal({
                read_dv_diff(s3dir, as_of = as_of, key_cols = c("a", "b")) %>% arrange(a)
              },
              new_df)
            })

  test_that("retrieve_dv_backup too far back",
            {
              expect_error({
                read_dv_diff(s3dir, as_of = lubridate::now() - hours(30))
              },
              "No diffs older")
            })
}

# read_dv_diff local
as_of <- lubridate::now() - seconds(30)
commit_diff(newer_diff_df,
            local_prefix)

test_that("local retrieve_dv_backup",
          {
            expect_equal({
              read_dv_diff(local_prefix,
                           as_of = as_of,
                           key_cols = c("a", "b")) %>% arrange(a)
            },
            new_df)
          })

test_that("retrieve_dv_backup too far back",
          {
            expect_error({
              read_dv_diff(local_prefix, as_of = lubridate::now() - hours(30))
            },
            "No diffs older")
          })



# teardown ---------------------------------------------------------------------
withr::defer({
  unlink(local_prefix, recursive = TRUE)

  if (Sys.getenv("TEST_S3") == "TRUE") {
    s3$DeleteDirContents("dataversionr-tests/")
  }
})
