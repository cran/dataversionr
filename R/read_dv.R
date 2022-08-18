#' Read dv
#'
#' Read a version of a versioned dataset into a data frame
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param as_of the valid date at which you'd like to read the dv
#' @param source the source of the dv. Options are 'latest', 'diffs' or 'backup'
#'
#' @return a data frame
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' create_dv(df, temp_dir, backup_count = 5L)
#'
#' read_dv(temp_dir)
#'
#' read_dv(temp_dir, source = "backup")
#'
#' read_dv(temp_dir, as_of = lubridate::now(), source = "diffs")
#'
#' unlink(temp_dir)
#'
read_dv <- function(destination,
                    as_of = NA,
                    source = "latest") {
  destination <- make_SubTreeFileSystem(destination)

  if (length(destination$ls()) == 0) {
    stop("destination is empty.")
  }

  meta <- get_metadata(destination)
  key_cols <- meta$key_cols

  if (source == "latest") {
    if (!is.na(as_of)) {
      stop("parameter latest only works with parameter as_of set to NA.")
    }
    get_latest(destination)
  } else if (source == "diffs") {
    read_dv_diff(destination,
                 as_of,
                 key_cols)
  } else if (source == "backup") {
    read_dv_backup(destination,
                   as_of)
  } else {
    stop(paste("source parameter should be one of latest, diffs, or backup."))
  }



}
