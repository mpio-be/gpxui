
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
#' @param  x  a list of sf objects, any non-sf objects or z in the list are silently ignored.
#' @return  a st_bbox object or NULL when it fails. 
#' @export
#' @examples
#' ff <- list.files(system.file(package = "gpxui", "Garmin65s"), full.names = TRUE, recursive = TRUE)
#' pts = read_all_waypoints(ff, sf = TRUE)
#' trk = read_all_tracks(ff, sf = TRUE)
#' st_bbox_all(list(pts, trk))
#' st_bbox_all(list(pts, NULL))
#' st_bbox_all(list(1, NULL))
#' st_bbox_all(list(NULL, NULL))
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


#' @export
track_summary <- function(x) {

  if (is.null(x)) o = data.frame(Info = "No GPX track files found")
  
  if(!is.null(x)) {
    o = sf::st_drop_geometry(x) |> setDT()
    o[, dist := sf::st_length(x) |> units::set_units("km")]
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

#' @export
points_summary <- function(x) {

  if (is.null(x)) o = data.frame(Info = "No GPX waypoints files found")
  
  if (!is.null(x)) {
    h =
      sf::st_union(x) |>
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