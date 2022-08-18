#' Fix path
#'
#' Take a prefix and a local file path or SubTreeFileSystem and return the correct SubTreeFileSystem. A bit like file.path for arrow SubTreeFileSystems.
#'
#' @param path a sub prefix of the destination
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param verbose TRUE /FALSE should the function be chatty?
#'
#' @return an arrow SubTreeFileSystem
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#'
#' fix_path("backup", temp_dir)
#'
fix_path <- function(path,
                     destination,
                     verbose = FALSE) {
  destination <-
    make_SubTreeFileSystem(destination, verbose = verbose)

  base_fs <- destination$base_fs
  base_path <- destination$base_path
  put_path <- file.path(base_path, path, fsep =)
  put_path <- gsub("//", "/", put_path)

  if ("LocalFileSystem" %in% class(destination$base_fs)) {
    put_location <- put_path
  } else {
    put_location <- base_fs$path(put_path)
  }
  return(put_location)
}
