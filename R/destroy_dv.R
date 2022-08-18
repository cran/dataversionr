


#' Destroy dv
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param prompt should we ask for manual confirmation?
#'
#' @return TRUE
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#'
#' create_dv(df, temp_dir)
#' destroy_dv(temp_dir, prompt = FALSE)
#'
#' unlink(temp_dir)
#'
destroy_dv <- function(destination, prompt = TRUE) {
  destination <- make_SubTreeFileSystem(destination)
  metadata <- get_metadata(destination)
  metadata_check <- is.list(metadata) && length(metadata) == 5
  if (metadata_check) {
    remove_prefix(destination, prompt = prompt)
  } else {
    stop(
      "metadata check failed. Are you sure this is a dv? You'll have to manually destroy it via another method."
    )
  }
}
