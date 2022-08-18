#' Put latest
#'
#' Write a new latest version to a versioned dataset. Does not update diffs or backups.
#'
#' @param new_df a dataframe
#' @param destination a local directory path or an arrow SubTreeFileSystem
#'
#' @return TRUE
#' @importFrom arrow write_parquet
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#'
#' put_latest(df, temp_dir)
#'
#' unlink(temp_dir)
#'
put_latest <- function(new_df, destination) {
  latest_prefix <- fix_path("latest", destination)

  make_prefix(latest_prefix)

  put_location <- fix_path("data.parquet", latest_prefix)

  arrow::write_parquet(new_df,
                       put_location)
  return(TRUE)
}
