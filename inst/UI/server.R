

function(input, output, session, export = "database") {
observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))

#* Feedback on dir upload to server (before db upload)
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
    updated_pts = gpx_to_database(server = SERVER, db = DB, pts, tab = "GPS_POINTS")
    updated_trk = gpx_to_database(server = SERVER, db = DB, trk, tab = "GPS_TRACKS")

    rbindlist(list(updated_pts, updated_trk))

  }) 
  
  observeEvent(input$upload_GPX, {
    x = run_update()

    updateTextInput(session, "last_pts_dt", value = x[tab == "GPS_POINTS", last_entry_before_update |> as.character()] )
    updateTextInput(session, "last_trk_dt", value = x[tab == "GPS_TRACKS", last_entry_before_update |> as.character()] )
  
  })



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
  
  # Show points and tracks based on selected date
  observe({
    req(input$show_after)

    pts <- read_GPX_table(SERVER,DB, "GPS_POINTS", input$show_after, sf=TRUE)
    trk <- read_GPX_table(SERVER, DB, "GPS_TRACKS", input$show_after, sf = TRUE)
    bbox <- st_bbox_all(list(pts, trk)) 

    leafletProxy("MAP") |>
      gpxmap(bbox, pts, trk)
      
  })




#* Feedback on points and tracks

  output$track_summary <- renderUI({
    req(input$last_trk_dt)

    gpx_summary(
      read_GPX_table(SERVER,DB,  "GPS_POINTS", input$last_trk_dt, sf = TRUE), 
      read_GPX_table(SERVER, DB, "GPS_TRACKS", input$last_trk_dt, sf = TRUE)
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
