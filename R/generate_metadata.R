#' Generate metadata
#'
#' Generate a conformant metadata structure for a versioned dataset
#'
#' @param df a data frame to create a dv from
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param key_cols a character vector of column names that constitute a unique key
#' @param diffed should we store diffs between each dv version?
#' @param backup_count how many backups should we store?
#'
#' @return a list

#' @importFrom diffdfs diffdfs
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#'
#' generate_metadata(df, temp_dir)
#'
#' unlink(temp_dir)
#'
generate_metadata <- function(df,
                              destination,
                              key_cols = NA,
                              diffed = TRUE,
                              backup_count = 0L) {
  # versioning
  schema_ver = "20220727"

  # tests
  destination <- make_SubTreeFileSystem(destination)

  if (!is.data.frame(df)) {
    stop("parameter df is not a dataframe.")
  }

  if (all(is.na(key_cols))) {
    key_cols <- colnames(df)
  }

  if (!(all(key_cols %in% colnames(df)))) {
    stop("key_cols are not present in colnames(df)")
  }

  if (!(is.integer(backup_count))) {
    stop(
      "parameter backup_count must be an integer. You can set it to 1L to just keep the latest version."
    )
  }

  if (!(is.logical(diffed))) {
    stop("parameter diffed must be TRUE/FALSE.")
  }

  if (diffed) {
    message("Checking that new_df can be diffed...")
    if (is.data.frame(diffdfs::diffdfs(df, key_cols = key_cols))) {
      message("Diff test passed.")
    } else {
      stop("Diff test failed. Make sure your dataframe can be diffed or set diffed = FALSE")
    }
  }

  # metadata builder
  base_path = destination$base_path

  metadata <- list()
  metadata$schema_ver = schema_ver
  metadata$base_path = base_path
  metadata$key_cols = sort(key_cols)
  metadata$diffed = diffed
  metadata$backup_count = backup_count
  return(metadata)
}
