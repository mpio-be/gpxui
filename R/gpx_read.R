
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

#' read_all_waypoints
#' @param  ff  a vector of file names
#' @param int_names_only keep only numeric names
#' @param gpsid the id of the gps. 
#' @export
#' @examples 
#' ff = list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' read_all_waypoints(ff, gpsid = 1)
read_all_waypoints <- function(ff,int_names_only = TRUE, gpsid) {

  ff = ff[basename(ff) |> str_detect("gpx$")]

   if (length(ff) > 0) {
     o = lapply(ff, read_waypoints) |>
       rbindlist()
     o[, gps_id := gpsid]

     if (int_names_only) {
       o[, gps_point := as.integer(gps_point)]
       o = o[!is.na(gps_point)]
     }

   } else {
     o = NULL
  }


  o

}

#' read_all_tracks
#' @param  ff  a vector of file names
#' @param gpsid the id of the gps.
#' 
#' @export
#' @examples
#' ff = list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' read_all_tracks(ff, gpsid = 1)
read_all_tracks <- function(ff, gpsid) {

  ff = ff[basename(ff) |> str_detect("gpx$")]

   if (length(ff) > 0) {
    o = lapply(ff, read_tracks) |>
      rbindlist()
    o[, gps_id := gpsid]


     } else  {
        o = NULL
    }

   o

}


#' keep_new
#' keep new entries relative to database state
#' @param con a connection to db
#' @param x a data.table; output of read_all_waypoints() or read_all_tracks().
#' @param tab database table to crosscheck against
#' @export
#' @examples
#' ff = list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' x = read_all_waypoints(ff, gpsid = 1)
#' con = dbcon(server = "localhost", db = "tests")
#' keep_new(con, x, tab = "GPS_POINTS")
#'
#' x = read_all_tracks(ff, gpsid = 1)
#' keep_new(con, x, tab = "GPS_TRACKS")
#' 
#' DBI::dbDisconnect(con)
#'
keep_new <- function(con, x, tab) {
  
  lastdt <- dbq(
    con,
    glue("SELECT max(datetime_) dt from {tab}
      WHERE gps_id = {x$gps_id[1]}")
  )$dt

  if (!is.na(lastdt)) {
    o <- x[datetime_ > lastdt]
  } else o = x

  o
}
