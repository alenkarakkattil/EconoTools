#' Calculate Simple Moving Average (SMA)
#'
#' Calculates the simple moving average for a time series.
#'
#' @param data A data frame or tibble with a numeric 'value' column.
#' @param n The window size for the moving average (an integer). Defaults to 20.
#' @return The original data frame with an added 'sma' column.
#' @export
#' @importFrom zoo rollmean
#' @importFrom dplyr mutate
#' @examples
#' df <- data.frame(value = 1:50)
#' calculate_sma(df, n = 10)
calculate_sma <- function(data, n = 20) {
  # Input validation checks for data type and column existence
  if (!is.data.frame(data) || !"value" %in% names(data)) {
    stop("'data' must be a data frame with a 'value' column.", call. = FALSE)
  }
  # Input validation check for sufficient observations
  if (nrow(data) < n) {
    stop("Not enough observations to calculate a moving average of size n.", call. = FALSE)
  }
  
  # Calculate the SMA using a more direct and efficient approach
  data <- data |>
    dplyr::mutate(
      sma = zoo::rollmean(value, k = n, fill = NA, align = "right")
    )
  
  return(data)
}
