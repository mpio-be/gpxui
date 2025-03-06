

#' @export
basemap <- function() {
  leaflet::leaflet(options = leaflet::leafletOptions(zoomControl = TRUE)) |>
    leaflet::addTiles(group = "OSM") |>
    leaflet::addLayersControl(
      overlayGroups = c("Tracks", "Points"),
      position = "topleft",
      options = leaflet::layersControlOptions(collapsed = FALSE)
    ) |>
    leaflet::setView(sample(-150:150, 1), sample(-60:60, 1), zoom = 2)
}

#' @export
gpxmap <- function(MAP, bbox, pts, trk) {

  bbox = as.numeric(bbox)

  MAP = MAP |>
  leaflet::clearShapes() |>
  leaflet::clearMarkers()

  if (!is.null(bbox)) {
    MAP <- MAP |>
      leaflet::fitBounds(lng1 = bbox[1], lat1 = bbox[2], lng2 = bbox[3], lat2 = bbox[4])
  }

  if (!is.null(pts) && nrow(pts) > 0) {
    MAP <- MAP |>
      leaflet::addCircleMarkers(
        data = pts,
        group = "Points",
        fillOpacity = 0.5,
        opacity = 0.5,
        radius = 3,
        label = ~gps_point,
        labelOptions = leaflet::labelOptions(
          noHide = TRUE,
          direction = "auto",
          background = "transparent",
          offset = c(2, 0)
        )
      )
  }

  if ( !is.null(trk) && nrow(trk) > 0 ) {
    MAP <- MAP |>
      leaflet::addPolylines(
        data = trk,
        group = "Tracks",
        color = "#da3503"
      )
  }

  MAP


}