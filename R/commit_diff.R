#' Commit diff
#'
#' Write a diff to a versioned dataset destination. Check that it was written correctly, otherwise return an error.
#'
#' @param diff_df a data frame. Output off diffdfs::diffdfs.
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param verbose TRUE /FALSE should the function be chatty?
#'
#' @return TRUE
#' @importFrom lubridate now
#' @importFrom dplyr select everything as_tibble
#' @importFrom arrow write_parquet Table read_parquet
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' new_df <- data.frame(a = 2:5, b = letters[2:5])
#' diff <- diffdfs::diffdfs(new_df, df)
#'
#' commit_diff(diff, temp_dir)
#'
#' unlink(temp_dir)
#'
commit_diff <- function(diff_df,
                        destination,
                        verbose = FALSE) {
  destination <- make_SubTreeFileSystem(destination)

  timestamp <- lubridate::now(tzone = "UTC")

  diff_path <- paste0("diff/", as.numeric(timestamp), ".parquet")

  diff_df$diff_timestamp <- timestamp
  diff_df <-
    dplyr::select(diff_df, .data$diff_timestamp, dplyr::everything())


  if (verbose) {
    message("Committing diff to dataset...")
  }
  if ("LocalFileSystem" %in% class(destination$base_fs)) {
    make_prefix(destination$base_fs$cd(paste0(destination$base_path, "diff")))
  }

  put_location <- fix_path(diff_path, destination)

  arrow::write_parquet(diff_df,
                       put_location)

  if (verbose) {
    message("Verifying diff can be retrieved from dataset...")
  }

  retrieved_df <- arrow::read_parquet(put_location)

  if (verbose) {
    message("A parquet file can be read from the target path...")
  }

  # Table$() method is WORKAROUND FOR https://issues.apache.org/jira/browse/ARROW-16010
  read_check <-
    identical(dplyr::as_tibble(retrieved_df),
              arrow::Table$create(diff_df)$to_data_frame())
  if (verbose & read_check) {
    message("Remote diff is identical to local diff.")
  }

  if (!read_check) {
    stop(
      "Remote diff is not identical to local diff. \n
             You should make sure the dataset hasn't been corrupted."
    )
  }
  return(TRUE)
}
