#' Get diffs
#'
#' Read in all the diffs in a versioned dataset to a data frame or arrow dataset
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param collect should we collect the underlying arrow dataset or return just the connection?
#'
#' @return a data frame or an arrow dataset connection
#' @importFrom arrow open_dataset
#' @importFrom dplyr collect
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' new_df <- data.frame(a = 2:5, b = letters[2:5])
#' diff <- diffdfs::diffdfs(new_df, df)
#' commit_diff(diff, temp_dir)
#'
#' get_diffs(temp_dir)
#'
#' unlink(temp_dir)
#'

get_diffs <- function(destination, collect = TRUE) {
  destination <- make_SubTreeFileSystem(destination)
  ds <- arrow::open_dataset(destination$path("diff"))
  if (collect) {
    dplyr::collect(ds)
  } else {
    ds
  }
}
