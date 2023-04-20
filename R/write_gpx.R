

#' DT2gpx
#' @export
#' @examples
#' x = read_all_waypoints(system.file(package = "gpxui", "Garmin65s"))
#' outf = tempfile(fileext = ".gpx")
#' DT2gpx(x, nam = "gps_point", dest = outf)
DT2gpx <- function(x, longit = "lon", latit=  "lat", nam, symbol = "Bird", dest = tempfile(fileext = ".gpx") ) {

  o = x[, c(nam, longit, latit), with = FALSE]
  setnames(o, c("name", "lon", "lat"))

  o[, gpx := glue_data(.SD, 
  '<wpt lat="{lat}" lon="{lon}"> 
    <name>{name} </name> 
    <sym>{symbol}</sym>
  </wpt>')]

  o = paste('<gpx>', paste(o$gpx, collapse = ' '), '</gpx>')


  cat(o, file = dest)

  file.exists(dest)

}
