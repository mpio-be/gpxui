
#' as_dirInput_output
#' @export
#' @examples
#' system.file(package = "gpxui", "Garmin65s") |>
#'   as_dirInput_output()
as_dirInput_output <- function(dr) {
  ff <- list.files(dr, full.names = TRUE, recursive = TRUE)

  data.frame(name = basename(ff), datapath = ff)
}

#' @export
dt2lines <- function(x, grp) {
  x |>
    dplyr::group_by(.data[[grp]]) |>
    dplyr::summarise(
      do_union = FALSE, 
      .groups = "keep", 
      mean_ele = mean(ele),
      max_ele = max(ele),
      min_ele = min(ele),
      max_dt = max(datetime_),
      min_dt = min(datetime_),
      n = dplyr::n()
      
      ) |>
    st_cast("MULTILINESTRING")
}

#' @export
st_bbox_all = function(x) {

  # at least one sf
  ok = sapply(x, inherits, what = "sf") |> any()
  # and at least one valid sf
  if(ok)
  ok = sapply(x, function(x) nrow(x) > 0) |> any()



  if(ok) {
  x = x[sapply(x, inherits, what = "sf") & sapply(x, function(x) nrow(x) > 0)]
 
  o <- lapply(x, st_bbox) |>
    lapply(st_as_sfc)

  o <- do.call(st_union, o) |>
    st_as_sf() |>
    st_bbox()
  
  
  } else 
    o <- st_sfc(NULL, crs = 4326) |> st_as_sf() |> st_bbox()

  o

}


#' DT2gpx
#' @export
DT2gpx <- function(x, nam, longit = "lon", latit = "lat", symbol = "Flag, Red", dest = tempfile(fileext = ".gpx")) {
  o <- x[, c(nam, longit, latit), with = FALSE]
  setnames(o, c("name", "lon", "lat"))

  o[, gpx := glue_data(
    .SD,
    '<wpt lat="{lat}" lon="{lon}">
    <name>{name} </name>
    <sym>{symbol}</sym>
  </wpt>'
  )]

  o <- paste("<gpx>", paste(o$gpx, collapse = " "), "</gpx>")


  cat(o, file = dest)

  file.exists(dest)
}
