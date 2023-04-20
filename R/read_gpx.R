
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
#' @export
#' @examples 
#' read_all_waypoints(system.file(package = "gpxui", "Garmin65s"))
read_all_waypoints <- function(d,int_names_only = TRUE) {

  ff = list.files(d, pattern = ".gpx", full.names = TRUE, recursive = TRUE)

   o = lapply(ff, read_waypoints) |>
     rbindlist()
   if(int_names_only) {
    o[, gps_point := as.integer(gps_point)]
    o = o[!is.na(gps_point)]
   }

  o
}

#' read_all_tracks
#' @export
#' @examples 
#' read_all_tracks(system.file(package = "gpxui", "Garmin65s"))
read_all_tracks <- function(d) {

  ff = list.files(d, pattern = ".gpx", full.names = TRUE, recursive = TRUE)

   lapply(ff, read_tracks) |>
     rbindlist()


}
