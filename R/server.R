
#' @export
gpx_server <- function() {

function(input, output, session) {
  observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))

  #+ Read gpx, update db, update UI
  
  run_update <- reactive({
    # read gpx
    pts <- read_all_waypoints(input$upload_GPX)
    trk <- read_all_tracks(input$upload_GPX)

    # update new data to db
    updated_pts <- gpx_to_database(server = SERVER, db = DB, pts, tab = "GPS_POINTS")
    updated_trk <- gpx_to_database(server = SERVER, db = DB, trk, tab = "GPS_TRACKS")

    rbindlist(list(updated_pts, updated_trk))
  
  })

  observeEvent(input$upload_GPX, {
    x <- run_update()

    updateTextInput(session, "last_pts_dt", value = x[tab == "GPS_POINTS", last_entry_before_update |> as.character()])
    updateTextInput(session, "last_trk_dt", value = x[tab == "GPS_TRACKS", last_entry_before_update |> as.character()])
    updateNumericInput(session, "gps_id", value = na.omit(x$gps_id)[1])
  })


  #* MAP: base map
  output$MAP <- renderLeaflet({
    basemap()
  })

  #* MAP: update map
  # on upload
  observeEvent(input$upload_GPX, {
    pts <- read_GPX_table(SERVER, DB, "GPS_POINTS", input$last_pts_dt, sf = TRUE)
    trk <- read_GPX_table(SERVER, DB, "GPS_TRACKS", input$last_trk_dt, sf = TRUE)
    bbox <- st_bbox_all(list(pts, trk))

    leafletProxy("MAP") |>
      gpxmap(bbox, pts, trk)
  })

  # on explore
  observeEvent(input$go_explore, {
    pts <- read_GPX_table(SERVER, DB, "GPS_POINTS", input$show_after, input$gps_id, sf = TRUE)
    trk <- read_GPX_table(SERVER, DB, "GPS_TRACKS", input$show_after, input$gps_id, sf = TRUE)
    bbox <- st_bbox_all(list(pts, trk))

    leafletProxy("MAP") |>
      gpxmap(bbox, pts, trk)
  })






  #* Feedback

  get_feedback <- reactive({
    e1 <- includeMarkdown(system.file(package = "gpxui", "www", "help.md"))
    if (!is.null(input$upload_GPX)) {
      e1 <- gpx_file_upload_check(input$upload_GPX)
    }

    e2 <- ""

    if (nchar(input$last_trk_dt) > 0 || nchar(input$last_pts_dt) > 0) {
      e2 <- gpx_summary(
        read_GPX_table(SERVER, DB, "GPS_POINTS", input$last_pts_dt, input$gps_id, sf = TRUE),
        read_GPX_table(SERVER, DB, "GPS_TRACKS", input$last_trk_dt, input$gps_id, sf = TRUE)
      )
    }

    div(e1, e2)
  })


  output$feedback <- renderUI({
    get_feedback()
  })





  #* EXPORT

  output$download_points <- downloadHandler(
    filename = function() {
      glue("{input$export_object}.{input$export_class}")
    },
    content = function(file) {
      gpx_export(server = SERVER, db = DB, input$export_object, file)
    }
  )
}



}