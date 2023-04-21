
#' read_waypoints
#' @export
#' @examples
#' f = system.file(package = "gpxui", "Garmin65s","Garmin", "GPX", "Waypoints_20-APR-23.gpx")
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
#' f = system.file(package = "gpxui", "Garmin65s","Garmin", "GPX", "Current", "Current.gpx")
#' read_tracks(f)
read_tracks <- function(x) {
  w <- st_read(x, layer = "track_points", quiet = TRUE)
  xy <- st_coordinates(w) |> data.table()
  setnames(xy, c("lon", "lat"))
  d <- st_drop_geometry(w) |> setDT()
  d <- d[, .(seg_id = track_seg_id, seg_point_id = track_seg_point_id, datetime_ = time, ele)]
  cbind(d, xy)
}

#' read_all_waypoints
#' @param  ff  a vector of file names
#' @param int_names_only keep only numeric names
#' @param sf output as a sf dataframe. 
#' @export
#' @examples 
#' ff = list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' read_all_waypoints(ff)
#' read_all_waypoints(ff, sf = TRUE)
read_all_waypoints <- function(ff,int_names_only = TRUE, sf = FALSE) {
  
  ff = ff[basename(ff) |> str_detect("gpx$")]

   if (length(ff) > 0) {
     o = lapply(ff, read_waypoints) |>
       rbindlist()
     if (int_names_only) {
       o[, gps_point := as.integer(gps_point)]
       o = o[!is.na(gps_point)]
     }

     if (sf) {
       o = st_as_sf(o, coords = c("lon", "lat"), crs = 4326)
     }
   } else {
     o = data.table()
    if(sf)
      o = st_point() |>
        st_sfc() |>
        st_sf()

  }


  o

}

#' read_all_tracks
#' @param  ff  a vector of file names
#' @param sf output as a sf dataframe.
#' @export
#' @examples 
#' ff = list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' read_all_tracks(ff)
#' read_all_tracks(ff, sf = TRUE)
read_all_tracks <- function(ff, sf = FALSE) {

  ff = ff[basename(ff) |> str_detect("gpx$")]

   if (length(ff) > 0) {
    o = lapply(ff, read_tracks) |>
     rbindlist()

     if (sf) { 
       o <- dt2lines(o, "seg_id")
     }


     } else {
      o = data.table()
      if(sf)
        o = st_line() |>
          st_sfc() |>
          st_sf()

  }

   o

}
