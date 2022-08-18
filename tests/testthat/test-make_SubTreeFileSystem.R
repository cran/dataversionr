# setup ------------------------------------------------------------------------

# tests ------------------------------------------------------------------------
# test correct object works
test_that("existing SubTreeFileSystem works", {
  expect_equal({
    make_SubTreeFileSystem(arrow::LocalFileSystem$create()$cd(tempdir()))$base_path
  },
  make_SubTreeFileSystem(arrow::LocalFileSystem$create()$cd(tempdir()))$base_path)
})

# test correct object works verbose
test_that("existing SubTreeFileSystem works VERBOSE", {
  expect_message({
    make_SubTreeFileSystem(arrow::LocalFileSystem$create()$cd(tempdir()), verbose = TRUE)
  },
  "destination parameter has the required class structure.")
})


# test non string fails
test_that("test non string fails",
          {
            expect_error(make_SubTreeFileSystem(iris),
                         'must be a string')
          })

# test an existing file path doesn't work
temp_file <- tempfile()
file.create(temp_file)
dir.exists(temp_file)

test_that("test an existing file path doesn't work",
          {
            expect_error(make_SubTreeFileSystem(temp_file),
                         'is an existing file')
          })


# test an existing directory path works
temp_dir <- tempfile()
dir.create(temp_dir)
test_that("test an existing directory path works",
          {
            expect_equal(
              make_SubTreeFileSystem(temp_dir)$base_path,
              arrow::LocalFileSystem$create()$cd(temp_dir)$base_path
            )
          })

# tests a non existent path works
non_dir <- tempfile()
test_that("tests a non existent path works",
          {
            expect_equal(
              make_SubTreeFileSystem(non_dir)$base_path,
              arrow::LocalFileSystem$create()$cd(non_dir)$base_path
            )
          })

# teardown ---------------------------------------------------------------------
withr::defer({
  unlink(temp_file)

  unlink(temp_dir)

  unlink(non_dir)
})
