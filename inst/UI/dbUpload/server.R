

function(input, output, session, export = "database") {
observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))

#* Feedback on dir upload
  output$file_upload_feedback <- renderUI({
    gpx_file_upload_check(input$garmin_dir)
  }) |>
    bindEvent(input$garmin_dir, ignoreNULL = TRUE)


#* Read all new gpx
  df <- reactive({
    gpsid <- deviceID(subset(input$garmin_dir, name == "DEVICE_ID.txt")$datapath)
    #TODO add toastr error when gpsid is not known
    pts <- read_all_waypoints(input$garmin_dir$datapath, gpsid = gpsid)
    trk <- read_all_tracks(input$garmin_dir$datapath,    gpsid = gpsid)

    con = dbcon(server = SERVER, db = DB)
    pts = keep_new(con, pts, tab = "GPS_POINTS")
    trk = keep_new(con, trk, tab = "GPS_TRACKS")
    DBI::dbDisconnect(con)
  

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

    pts  <- df()$pts |> st_as_sf(coords = c("lon", "lat"), crs = 4326)
    trk  <- df()$trk |> dt2lines("seg_id")
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

#* Feedback on points and tracks

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


    # card_body(
    #   min_height = 200,
    #   layout_column_wrap(
    #     width = 1/2,
    #     trk_tab,
    #     trk_pts
    #   )
    # )

    div(
      trk_tab,
      trk_pts
    )


  })



#* EXPORT
  # if (export == "csv") {
  #   output$download_points <- downloadHandler(
  #     filename = function() {
  #       glue("waypoints_{Sys.Date()}.csv")
  #     },
  #     content = function(file) {
  #       write.csv(df()$pts, file,row.names = FALSE)
  #     }
  #   )
  # }  
  

    observe({
      req(input$garmin_dir)


      con = dbcon(server = SERVER, db = DB)

      gid = deviceID(subset(input$garmin_dir, name == "DEVICE_ID.txt")$datapath)
      
      pts = read_all_waypoints(input$garmin_dir$datapath, gpsid = gid)
      pts = keep_new(con, pts, "GPS_POINTS")
      
      trk = read_all_tracks(input$garmin_dir$datapath, gpsid = gid)
      trk = keep_new(con, trk, "GPS_TRACKS")
      
      pts_dbupdate = DBI::dbAppendTable(con, "GPS_POINTS", pts)
      
      trk_dbupdate = DBI::dbAppendTable(con, "GPS_TRACKS", trk)

      DBI::dbDisconnect(con)

      # TODO writedb update
      print(pts_dbupdate)
      print(trk_dbupdate)


        
      
    })


}
