


#' Make SubTreeFileSystem
#'
#' Turn a local file path string or a SubTreeFileSystem into a SubTreeFileSystem
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param verbose TRUE /FALSE should the function be chatty?
#'
#' @return an arrow SubTreeFileSystem
#' @importFrom arrow LocalFileSystem
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' make_SubTreeFileSystem(temp_dir)
#'
make_SubTreeFileSystem <- function(destination,
                                   verbose = FALSE) {
  target_classes <-
    c("SubTreeFileSystem", "FileSystem", "ArrowObject", "R6")

  if ((all(class(destination) == target_classes))) {
    if (verbose) {
      message("destination parameter has the required class structure.")
    }
    return(destination)


  } else if (is.character(destination)) {
    if (verbose) {
      message("destination parameter is a string. Coercing to local FileSystem.")
    }
    destination <- normalizePath(destination, mustWork = FALSE)
    if (file.exists(destination) & !dir.exists(destination)) {
      stop(paste(
        "path",
        destination,
        "is an existing file. It should be directory."
      ))
    }

    fs <- arrow::LocalFileSystem$create()
    fsdir <- fs$cd(destination)
    return(fsdir)

  } else {
    stop("destination parameter must be a string or SubTreeFileSystem.")
  }

}
