
#' read_waypoints
#' @export
#' @examples
#' f = system.file(package = "gpxui", "Garmin65s", "GPX", "Waypoints_20-APR-23.gpx")
#' read_waypoints(f)
read_waypoints <- function(x) {
  w <- st_read(x, layer = "waypoints", quiet = TRUE)
  xy <- st_coordinates(w) |> data.table()
  setnames(xy, c("lon", "lat"))
  d <- st_drop_geometry(w) |> setDT()
  d <- d[, .(gps_point = name, datetime_ = time, ele)]
  cbind(d, xy)

}

#' read_tracks
#' @export
#' @examples
#' f = system.file(package = "gpxui", "Garmin65s", "GPX", "Current", "Current.gpx")
#' read_tracks(f)
read_tracks <- function(x) {
  w <- st_read(x, layer = "track_points", quiet = TRUE)
  xy <- st_coordinates(w) |> data.table()
  setnames(xy, c("lon", "lat"))
  d <- st_drop_geometry(w) |> setDT()
  d <- d[, .(seg_id = track_seg_id, seg_point_id = track_seg_point_id, datetime_ = time, ele)]
  cbind(d, xy)
}


#' deviceID
#' @param x a data.frame  uploaded to the server by dirInput
#' @export
#' @examples
#' x <- system.file(package = "gpxui", "Garmin65s", "GPX") |> as_dirInput_output()
#' deviceID(x)
deviceID <- function(x) {

  path_to_id = subset(x, name == "DEVICE_ID.txt")$datapath

  o = try(
    readLines(path_to_id)[1] |> 
      as.numeric(),
    silent = TRUE
  )


  if (inherits(o, "try-error")) o <- NA

  o
}


#' read_all_waypoints
#' @description  read all waypoints from the GPX directory and the gps id from DEVICE_ID.txt when it exists
#' @param  ff  a data.frame  uploaded to the server by dirInput
#' @param int_names_only keep only numeric names
#' @export
#' @examples 
#' system.file(package = "gpxui", "Garmin65s") |> 
#' as_dirInput_output() |>
#' read_all_waypoints()
read_all_waypoints <- function(ff,int_names_only = TRUE) {

  gid = deviceID(ff)

  ff = ff$datapath

  ff = ff[basename(ff) |> str_detect("gpx$")]

  if (length(ff) > 0) {
    o = lapply(ff, read_waypoints) |>
      rbindlist()
    o[, gps_id := gid]

    if (int_names_only) {
      o[, gps_point := as.integer(gps_point)]
      o = o[!is.na(gps_point)]
    }

    setcolorder(o, "gps_id")

  } else {
    o = NULL
  }

  o

}

#' read_all_tracks
#' @description  read all tracks from the GPX directory and the gps id from DEVICE_ID.txt when it exists
#' @param  ff  a data.frame  uploaded to the server by dirInput
#' @export
#' @examples
#' system.file(package = "gpxui", "Garmin65s") |>
#' as_dirInput_output() |>
#' read_all_tracks()
read_all_tracks <- function(ff) {

  gid = deviceID(ff)
  ff = ff$datapath

  ff = ff[basename(ff) |> str_detect("gpx$")]

  if (length(ff) > 0) {
  o = lapply(ff, read_tracks) |>
    rbindlist()
  o[, gps_id := gid]

  setcolorder(o, "gps_id")

    } else  {
      o = NULL
  }

  o

}
