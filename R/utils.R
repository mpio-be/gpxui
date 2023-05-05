
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
