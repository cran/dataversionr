#' Get latest
#'
#' Read in the latest version of a versioned dataset to a data frame
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param collect should we return a data frame (TRUE) or an arrow dataset connection (FALSE)
#'
#' @return a data frame or an arrow dataset
#' @importFrom arrow open_dataset
#' @importFrom dplyr collect
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' put_latest(df, temp_dir)
#'
#' get_latest(temp_dir)
#'
#' unlink(temp_dir)
#'
get_latest <- function(destination, collect = TRUE) {
  latest_prefix <- fix_path("latest", destination)


  ds <- arrow::open_dataset(latest_prefix)

  if (collect) {
    ds <- dplyr::collect(ds)
  }

  return(ds)
}
