#' Get diff stats
#'
#' Read a versioned dataset's diff statistics to a data frame
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#'
#' @return a data frame
#' @importFrom arrow read_csv_arrow
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' new_df <- data.frame(a = 2:5, b = letters[2:5])
#' diff <- diffdfs::diffdfs(new_df, df)
#' commit_diff(diff, temp_dir)
#' put_diff_stats(temp_dir)
#'
#' get_diff_stats(temp_dir)
#'
#' unlink(temp_dir)
#'
get_diff_stats <- function(destination) {
  destination <- make_SubTreeFileSystem(destination)

  get_location <- fix_path("diff_stats.csv", destination)

  as.data.frame(arrow::read_csv_arrow(get_location))

}
