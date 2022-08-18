#' Put diff stats
#'
#' Write diff statistics to a versioned dataset
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#'
#' @return TRUE
#' @importFrom arrow write_csv_arrow
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
#' put_diff_stats(temp_dir)
#'
#' unlink(temp_dir)
#'
put_diff_stats <- function(destination) {
  destination <- make_SubTreeFileSystem(destination)

  diff_counts_df <- summarise_diffs(destination)

  put_location <- fix_path("diff_stats.csv", destination)

  arrow::write_csv_arrow(diff_counts_df, put_location)
  return(TRUE)
}
