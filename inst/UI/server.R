

function(input, output, session, export = "database") {
observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))

#+ Read gpx, update db, update UI
  run_update = reactive({

    # read gpx
    pts <- read_all_waypoints(input$upload_GPX)
    trk <- read_all_tracks(input$upload_GPX)

    # update new data to db
    updated_pts = gpx_to_database(server = SERVER, db = DB, pts, tab = "GPS_POINTS")
    updated_trk = gpx_to_database(server = SERVER, db = DB, trk, tab = "GPS_TRACKS")

    rbindlist(list(updated_pts, updated_trk))

  }) 
  
  observeEvent(input$upload_GPX, {
    x = run_update()


    updateTextInput(session, "last_pts_dt", value = x[tab == "GPS_POINTS", last_entry_before_update |> as.character()] )
    updateTextInput(session, "last_trk_dt", value = x[tab == "GPS_TRACKS", last_entry_before_update |> as.character()] )
    updateNumericInput(session, "gps_id", value = na.omit(o$gps_id)[1] )
  
  })

#* Feedback on dir upload to server (before db upload)
  output$file_upload_feedback <- renderUI({
    gpx_file_upload_check(input$upload_GPX)
  }) |>
    bindEvent(input$upload_GPX, ignoreNULL = TRUE)

#* MAP
  output$MAP <- renderLeaflet({
    basemap()
  })

  # Last points and tracks after GPS upload
  observe({
    req(input$last_trk_dt)

    pts <- read_GPX_table(SERVER, DB, "GPS_POINTS", input$last_trk_dt, sf = TRUE)
    trk <- read_GPX_table(SERVER, DB, "GPS_TRACKS", input$last_trk_dt, sf = TRUE)
    bbox <- st_bbox_all(list(pts, trk))

    leafletProxy("MAP") |>
      gpxmap(bbox, pts, trk)
  })
  

#* Feedback post upload or  on explore

  # summary
  output$track_summary <- renderUI({

    gpx_summary(
      read_GPX_table(SERVER, DB,  "GPS_POINTS", input$last_trk_dt, input$gps_id, sf = TRUE), 
      read_GPX_table(SERVER, DB, "GPS_TRACKS",  input$last_trk_dt, input$gps_id, sf = TRUE)
    )

  }) |> bindEvent(input$go_explore, ignoreNULL = TRUE)

  # map
  observeEvent(input$go_explore, {
    pts <- read_GPX_table(SERVER, DB, "GPS_POINTS", input$show_after, sf = TRUE)
    trk <- read_GPX_table(SERVER, DB, "GPS_TRACKS", input$show_after, sf = TRUE)
    bbox <- st_bbox_all(list(pts, trk))

    leafletProxy("MAP") |>
      gpxmap(bbox, pts, trk)
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
