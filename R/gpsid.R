
#' deviceID
#' @param x path to where the device ID is stored
#' @export
#' @examples
#' p <- system.file(package = "gpxui", "Garmin65s", "GPX", "DEVICE_ID.txt")

deviceID <- function(p) {
  readLines(p)[1] |>
  as.numeric()
}
