
function(input, output, session) {
observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))

#* Uplod feedback
  output$file_upload_feedback <- renderUI({
    gpx_file_upload_check(input$garmin_dir)
  }) |>
    bindEvent(input$garmin_dir, ignoreNULL = TRUE)


#* Read gpx
  df <- reactive({
    gpsid <- deviceID(subset(input$garmin_dir, name == "DEVICE_ID.txt")$datapath)
    pts <- read_all_waypoints(input$garmin_dir$datapath, sf = TRUE)
    trk <- read_all_tracks(input$garmin_dir$datapath, sf = TRUE)


    list(gpsid = gpsid, pts = pts, trk = trk)
  })


#* MAP
  output$MAP <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = TRUE)) |>
      addTiles(group = "OSM") |>
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topo") |>
      addProviderTiles(providers$Esri.WorldImagery, group = "Sat_Image") |>
      addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Grey") |>
      addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") |>
      addLayersControl(
        baseGroups = c("Topo", "OSM", "Sat_Image", "Grey", "Terrain"),
        overlayGroups = c("Tracks", "Points"),
        options = layersControlOptions(collapsed = FALSE)
      ) |>
      setView(sample(-150:150, 1), sample(-60:60, 1), zoom = 2)
  })



  observe({
    req(input$garmin_dir)

    pts <- df()$pts
    trk <- df()$trk

    bbox <- st_bbox_all(list(pts, trk)) |> as.numeric()

    map <- leafletProxy("MAP") |>
      clearShapes() |>
      clearMarkers()

    if (!is.null(bbox)) {
      map <- map |>
        fitBounds(lng1 = bbox[1], lat1 = bbox[2], lng2 = bbox[3], lat2 = bbox[4])
    }

    if (!is.null(pts) && nrow(pts) > 0) {
      map <- map |>
        addCircleMarkers(
          data = pts,
          group = "Points",
          fillOpacity = 0.5,
          opacity = 0.5,
          radius = 3,
          label = ~gps_point,
          labelOptions = labelOptions(
            noHide = TRUE,
            direction = "auto",
            background = "transparent",
            offset = c(2, 0)
          )
        )
    }

    if (!is.null(trk) && nrow(trk) > 0) {
      map <- map |>
        addPolylines(
          data = trk,
          group = "Tracks",
          color = "#da3503"
        )
    }

    map
  })

#* Summary output

  output$track_summary <- renderUI({
    req(input$garmin_dir)

    trk_tab <-
      df()$trk |>
      track_summary() |>
      knitr::kable(
        caption = "Track",
        digits = 2,
        table.attr = "class = 'table table-striped table-sm'",
        format = "html"
      ) |>
      HTML()

    trk_pts <-
      df()$pts |>
      points_summary() |>
      knitr::kable(
        caption = "Points",
        digits = 2,
        table.attr = "class = 'table table-striped table-sm'",
        format = "html"
      ) |>
      HTML()


    card_body(
      min_height = 200,
      layout_column_wrap(
        width = 1 / 2,
        trk_tab,
        trk_pts
      )
    )
  })



#* EXPORT
  if (export == "csv") {
    output$download_points <- downloadHandler(
      filename = function() {
        glue("waipoints_{Sys.Date()}.csv")
      },
      content = function(file) {
        write.csv(
          read_all_waypoints(input$garmin_dir$datapath), file,
          row.names = FALSE
        )
      }
    )
  }

}
