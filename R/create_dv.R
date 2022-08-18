


#' Create dv
#'
#' Create a versioned dataset
#'
#' @param df a data frame
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param key_cols a character vector of column names that constitute a unique key
#' @param diffed should we store diffs between each dv version?
#' @param backup_count how many backups should we store?
#'
#' @return TRUE
#' @importFrom diffdfs diffdfs
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#'
#' create_dv(df, temp_dir)
#'
#' unlink(temp_dir)
#'
create_dv <-
  function(df,
           destination,
           key_cols = NA,
           diffed = TRUE,
           backup_count = 0L) {
    destination <- make_SubTreeFileSystem(destination)
    make_prefix(destination)
    if (length(destination$ls()) != 0) {
      stop("destination is not empty.")
    }

    if (all(is.na(key_cols))) {
      key_cols <- colnames(df)
    }

    metadata <- generate_metadata(
      df,
      destination,
      key_cols = key_cols,
      diffed = diffed,
      backup_count = backup_count
    )

    put_metadata(metadata, destination)

    if (diffed) {
      diff <- diffdfs::diffdfs(df, NA, key_cols = key_cols)
      commit_diff(diff, destination)
    }

    put_latest(df, destination)

    if (backup_count > 0L) {
      put_backup(df, destination)
    }

  }
