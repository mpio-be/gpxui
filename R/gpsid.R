
#' read_gpsID
#' @param p path to startup.txt
#' @export
#' @examples
#' p <- system.file(package = "gpxui", "Garmin65s", "Garmin", "startup.txt")

garminID <- function(p) {

  o = readLines(p)
  o = o[str_detect(toupper(o), "GPS")]

  eval(parse(text = o))

}
