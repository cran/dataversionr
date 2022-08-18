#' Remove prefix
#'
#' Remove all the contents of a subdirectory or SubTreeFileSystem
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param prompt should we ask for user confirmation?
#'
#' @return TRUE
#' @importFrom utils askYesNo
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' make_prefix(temp_dir)
#'
#' remove_prefix(temp_dir, prompt = FALSE)
#'
remove_prefix <- function(destination, prompt = TRUE) {
  destination <- make_SubTreeFileSystem(destination)

  if (!("SubTreeFileSystem" %in% class(destination))) {
    stop(
      'class(destination) must include the type "SubTreeFileSystem". This avoids wiping entire filesystems!'
    )
  }

  prefix_depth <-
    length(strsplit(destination$base_path, split = "/")[[1]])

  if (prompt) {
    msg <- paste0("This command will delete ",
                  destination$base_path)
    message(msg)
    proceed <- utils::askYesNo("Continue?", default = FALSE,
                               prompts = gettext(c("y", "N", "cancel")))
  } else {
    proceed <- TRUE
  }

  if (proceed) {
    if (destination$base_fs$type_name == "s3" & prefix_depth == 1) {
      destination$base_fs$DeleteDirContents(destination$base_path)
    } else {
      destination$DeleteDir("/")
    }

    return(TRUE)
  } else {
    return(FALSE)
  }
}

