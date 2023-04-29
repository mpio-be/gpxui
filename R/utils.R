
dt2lines <- function(x, grp, CRS = 4326) {
  x |>
    st_as_sf(coords = c("lon", "lat"), crs = CRS) |>
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

#' st_bbox_all
#' st_bbox on a list
#' @param  x  a list of sf objects, any non-sf objects in the list are silently ignored.
#' @return  a st_bbox object or NULL when it fails. 
#' @export

st_bbox_all = function(x) {

  if(!is.null(unique(x)[[1]])) {
  x = x[sapply(x, inherits, what = "sf")]
  x <- x[sapply(x, function(x) nrow(x) > 0)]

  if (length(x) > 0) {
    o <- lapply(x, st_bbox) |>
      lapply(st_as_sfc)

    o <- do.call(st_union, o) |>
      st_as_sf() |>
      st_bbox()
  } else {
    o <- NULL
  }

  } else o = NULL


  
  o

}

#' track_summary
#' @export
#' @examples 
#' ff <- list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' read_all_tracks(ff, gpsid = 1) |> track_summary()
track_summary <- function(x) {

  if (is.null(x)) o = data.frame(Info = "No GPX track files found")
  
  if(!is.null(x)) {
    xs = dt2lines(x, "seg_id")

    o = sf::st_drop_geometry(xs) |> setDT()
    o[, dist := sf::st_length(xs) |> units::set_units("km")]
    o[, deltat := difftime(max_dt, min_dt, units = "hours")]

    o = o[, .(
      `N track points` = nrow(o) |> as.character(), 
      `mean elevation` = weighted.mean(mean_ele, w = n) |> round(2) |> as.character(),
      `max elevation` = max(max_ele) |> round(2) |> as.character(),
      `min elevation` = min(max_ele) |> round(2) |> as.character(),
      `start hour` = min(min_dt) |> format("%H:%M"),
      `stop hour` = max(max_dt) |> format("%H:%M"),
      `avg speed (km/hour)` = weighted.mean(as.numeric(dist) / as.numeric(deltat), w = n) |>
        round(2) |>
        as.character()
    )]

    o[, i := 1]
    o = melt(o, id.vars = "i")[, i := NULL]

    if (nrow(x) == 0) {
      o = o[1, ]
    }
  }
  
  o

}

#' points_summary
#' @export
#' @examples
#' ff <- list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' read_all_waypoints(ff, gpsid = 1) |> points_summary()
points_summary <- function(x) {

  if (is.null(x)) o = data.frame(Info = "No GPX waypoints files found")
  
  if (!is.null(x)) {
    h =
      sf:: st_as_sf(x, coords = c("lon", "lat"), crs = 4326) |>
      sf::st_union() |>
      sf::st_convex_hull() |>
      sf::st_area() |>
      units::set_units("km^2")

    o = data.table(
      `N waypoints` = nrow(x) |> as.character(),
      `first point` = x$gps_point[1] |> as.character(), 
      `last point` = x$gps_point[nrow(x)] |> as.character(), 
      `Area covered (km²)` = round(h, 2) |> as.character()
    )
    
    o[, i := 1]
    o = melt(o, id.vars = "i")[, i := NULL]

    if(nrow(x)  == 0)
      o = o[1, ]
  }


  o




}

#' deviceID
#' @param x path to where the device ID is stored
#' @export
#' @examples
#' p <- system.file(package = "gpxui", "Garmin65s", "GPX", "DEVICE_ID.txt")
#' deviceID(p)
deviceID <- function(p) {
  
  o = try(readLines(p)[1] |> as.numeric(), silent = TRUE)
  if (inherits(o, "try-error")) o = NA

  o

}
