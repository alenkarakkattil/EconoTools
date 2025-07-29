#' Fetch Time Series Data from FRED API
#'
#' Fetches a specified economic time series from the Federal Reserve Economic
#' Data (FRED) API. You must have a FRED API key.
#'
#' @param series_id The unique identifier for the FRED series (e.g., "GDP").
#' @param api_key Your personal FRED API key. It's recommended to store this
#'   as an environment variable.
#'
#' @return A tibble with 'date' and 'value' columns.
#' @export
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr as_tibble select mutate
#' @examples
#' \dontrun{
#'   # You need to set your API key first
#'   # Sys.setenv(FRED_API_KEY = "your_key_here")
#'   api_key <- Sys.getenv("FRED_API_KEY")
#'   gdp_data <- fetch_fred_data("GDP", api_key = api_key)
#' }
fetch_fred_data <- function(series_id, api_key) {
  if (missing(api_key) || api_key == "") {
    stop("A FRED API key is required. Please provide one.", call. = FALSE)
  }

  url <- paste0("https://api.stlouisfed.org/fred/series/observations?series_id=",
                series_id, "&api_key=", api_key, "&file_type=json")

  response <- httr::GET(url)
  httr::stop_for_status(response, task = "fetch data from FRED API")

  parsed <- jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"))

  if (!is.null(parsed$error_message)) {
      stop("FRED API Error: ", parsed$error_message, call. = FALSE)
  }

  df <- dplyr::as_tibble(parsed$observations) |>
    dplyr::select(date, value) |>
    dplyr::mutate(
      date = as.Date(date),
      # FRED sometimes returns '.' for missing values
      value = as.numeric(ifelse(value == ".", NA, value))
    ) |>
    na.omit()

  return(df)
}