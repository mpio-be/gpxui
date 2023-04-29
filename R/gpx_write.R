

#' DT2gpx
#' @export
#' @examples
#' x = list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE) |>
#'   read_all_waypoints()
#' outf = tempfile(fileext = ".gpx")
#' DT2gpx(x, nam = "gps_point", dest = outf)
DT2gpx <- function(x, longit = "lon", latit = "lat", nam, symbol = "Bird", dest = tempfile(fileext = ".gpx")) {
  o = x[, c(nam, longit, latit), with = FALSE]
  setnames(o, c("name", "lon", "lat"))

  o[, gpx := glue_data(
    .SD,
    '<wpt lat="{lat}" lon="{lon}">
    <name>{name} </name>
    <sym>{symbol}</sym>
  </wpt>'
  )]

  o = paste("<gpx>", paste(o$gpx, collapse = " "), "</gpx>")


  cat(o, file = dest)

  file.exists(dest)
}


#' waypoints_to_db
#' @param x a data.table; output of read_all_waypoints().
#' @param con a connection to db
#' @param tab database table to update
#' @export
#' @examples
#' x = list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)|>
#' read_all_waypoints()
#' con = dbcon(server = "localhost", db = "tests")
waypoints_to_db <- function(x, con, tab = "GPS_POINTS") {

  lastdt = dbq(con, glue("SELECT max(datetime_) dt from {tab}"))$dt

  if (!is.na(lastdt)) {
    x = x[datetime > lastdt]
  }
  

  o = DBI::dbAppendTable(con, tab, x)



}
