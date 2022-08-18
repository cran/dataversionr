


#' Read dv diff
#'
#' Read a version of a versioned dataset into a data frame using just the stored diffs.
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#' @param as_of the valid date at which you'd like to read the dv
#' @param key_cols a character vector of column names that constitute a unique key
#'
#' @return a data frame
#' @importFrom lubridate now with_tz
#' @importFrom dplyr filter collect arrange across everything last all_of group_by summarise ungroup select
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' create_dv(df, temp_dir, diffed = TRUE)
#'
#' read_dv_diff(temp_dir,
#'              as_of = lubridate::now(),
#'              key_cols = get_metadata(temp_dir)$key_cols)
#'
#' unlink(temp_dir)
#'
read_dv_diff <- function(destination, as_of, key_cols) {
  if (is.na(as_of)) {
    as_of <- lubridate::now()
  }

  as_of <- lubridate::with_tz(as_of, tzone = "UTC")

  if (!("POSIXct" %in% class(as_of))) {
    stop(
      "parameter as_of must be of class POSIXct. An easy way to create such an object is with lubridate::as_datetime()"
    )
  }

  diff_ds <- get_diffs(destination, collect = FALSE)
  diff_ds_filtered <-
    dplyr::filter(diff_ds, .data$diff_timestamp <= as_of) %>%
    dplyr::arrange(.data$diff_timestamp) %>% dplyr::collect()

  if (nrow(diff_ds_filtered) == 0) {
    stop("No diffs older than the specified as_of date found.")
  }


  dv <- diff_ds_filtered %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(c(key_cols)))) %>%
    dplyr::summarise(dplyr::across(dplyr::everything(), dplyr::last), .groups = "keep") %>%
    dplyr::ungroup() %>%
    dplyr::filter(.data$operation != "deleted") %>%
    dplyr::select(-.data$diff_timestamp, -.data$operation) %>%
    as.data.frame

  return(dv)

}
