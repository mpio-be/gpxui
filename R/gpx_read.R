
#' read_waypoints
#' @export
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
deviceID <- function(x) {
  z = data.table(x)
  path_to_id = z[name == "DEVICE_ID.txt",datapath]

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
