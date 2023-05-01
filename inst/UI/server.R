

function(input, output, session, export = "database") {
observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))

#* Feedback on dir upload before db upload
  output$file_upload_feedback <- renderUI({
    gpx_file_upload_check(input$upload_GPX)
  }) |>
    bindEvent(input$upload_GPX, ignoreNULL = TRUE)


#+ Read gpx, update db, update UI
  run_update = reactive({

    # read gpx
    pts <- read_all_waypoints(input$upload_GPX)
    trk <- read_all_tracks(input$upload_GPX)

    # update new data to db
    con = dbcon(server = SERVER, db = DB)
    updated_pts = gpx_to_database(con, pts, tab = "GPS_POINTS")
    updated_trk = gpx_to_database(con, trk, tab = "GPS_TRACKS")
    DBI::dbDisconnect(con)

    rbindlist(list(updated_pts, updated_trk))

  }) 
  
  observeEvent(input$upload_GPX, {
    x <<- run_update()

    updateTextInput(session, "last_pts_dt", value = x[tab == "GPS_POINTS", last_entry_before_update |> as.character()] )
    updateTextInput(session, "last_trk_dt", value = x[tab == "GPS_TRACKS", last_entry_before_update |> as.character()])
  })

#+ read uploaded data to db
  get_newly_updated = function(...) {
    con <- dbcon(server = SERVER, db = DB)
    on.exit(DBI::dbDisconnect(con))

    pts <- read_GPX_table(con, input$last_trk_dt, tab = "GPS_POINTS",...)
    trk <- read_GPX_table(con, input$last_trk_dt, tab = "GPS_TRACKS",...)
    
    list(pts = pts, trk = trk)


  }




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
    req(input$last_trk_dt)

    x = get_newly_updated(sf = TRUE)

    pts <- x$pts
    trk <- x$trk
   

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
    req(input$last_trk_dt)

    x = get_newly_updated(sf = TRUE)

    trk_tab <- x$trk |>
      track_summary() |>
      knitr::kable(
        caption = "Track",
        digits = 2,
        table.attr = "class = 'table table-striped table-sm'",
        format = "html"
      ) |>
      HTML()

    trk_pts <- x$pts |>
      points_summary() |>
      knitr::kable(
        caption = "Points",
        digits = 2,
        table.attr = "class = 'table table-striped table-sm'",
        format = "html"
      ) |>
      HTML()



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
  




}
