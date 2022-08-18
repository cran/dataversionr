#' Make prefix
#'
#' Create the necessary subdirectories to make sure that SubTreeFileSystem methods will work.
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#'
#' @return silent
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' make_prefix(temp_dir)
#'
make_prefix <- function(destination) {
  destination <- make_SubTreeFileSystem(destination)
  if (destination$base_fs$type_name == "local") {
    destination$CreateDir("/", recursive = TRUE)
  }
}
