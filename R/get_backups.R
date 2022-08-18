#' Get backups
#'
#' Read the backups in a versioned dataset to a data frame or an arrow dataset
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem

#' @param collect should we collect the underlying arrow dataset or return just the connection?
#'
#' @return an arrow dataset
#' @importFrom arrow open_dataset
#' @importFrom dplyr collect
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' put_backup(df, temp_dir)
#'
#'
#' get_backups(temp_dir)
#'
get_backups <- function(destination, collect = TRUE) {
  backup_prefix <- fix_path("backup", destination)

  ds <- arrow::open_dataset(backup_prefix)

  if (collect) {
    ds <- dplyr::collect(ds)
  }

  return(ds)
}
