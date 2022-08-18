


#' Get metadata
#'
#' Read versioned dataset metadata to a list
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param verbose TRUE /FALSE should the function be chatty?
#'
#' @return a list
#' @importFrom purrr map
#' @importFrom arrow read_csv_arrow
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' md <- generate_metadata(df, temp_dir)
#' put_metadata(md, temp_dir)
#'
#' get_metadata(temp_dir)
#'
#' unlink(temp_dir)
#'
get_metadata <- function(destination, verbose = FALSE) {
  get_path <- fix_path("metadata.csv", destination, verbose = verbose)
  df <- arrow::read_csv_arrow(
    get_path,
    col_types = "cccli",
    col_names = c(
      "schema_ver",
      "base_path",
      "key_cols",
      "diffed",
      "backup_count"
    ),
    skip = 1
  )
  metadata_concat <- as.list(df)
  metadata_map <-
    purrr::map(metadata_concat, ~ ifelse(is.character(.x), strsplit(.x, split = "[|]"), .x))
  metadata <- purrr::map(metadata_map, ~ unlist(.x))
  return(metadata)
}
