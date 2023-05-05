

#' DT2gpx
#' @export
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

# TODO: export function w. filetype = c("csv", "gpx")