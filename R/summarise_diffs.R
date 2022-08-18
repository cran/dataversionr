#' Summarise diffs
#'
#' Create a data frame which summarises the diffs in a versioned dataset
#'
#' @param destination a local directory path or an arrow SubTreeFileSystem
#'
#' @return a data frame of diff statistics
#' @importFrom dplyr collect group_by summarise mutate ungroup
#' @importFrom tidyr pivot_wider
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' temp_dir <- tempfile()
#' dir.create(temp_dir, recursive = TRUE)
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' new_df <- data.frame(a = 2:5, b = letters[2:5])
#' diff <- diffdfs::diffdfs(new_df, df)
#' commit_diff(diff, temp_dir)
#'
#' summarise_diffs(temp_dir)
#'
#' unlink(temp_dir)
#'

summarise_diffs <- function(destination) {
  destination <- make_SubTreeFileSystem(destination)

  diff_counts <-  destination %>%
    get_diffs(collect = FALSE) %>%
    dplyr::group_by(.data$diff_timestamp, .data$operation) %>%
    dplyr::collect() %>%
    dplyr::summarise(count = dplyr::n())


  diff_stats <- diff_counts %>%
    tidyr::pivot_wider(names_from = .data$operation,
                       values_from = .data$count) %>%
    dplyr::mutate() %>% dplyr::ungroup() %>% as.data.frame()

  if (!"new" %in% names(diff_stats)) {
    diff_stats$new <- 0L
  }

  if (!"deleted" %in% names(diff_stats)) {
    diff_stats$deleted <- 0L
  }

  if (!"modified" %in% names(diff_stats)) {
    diff_stats$modified <- 0L
  }

  return(diff_stats)

}

