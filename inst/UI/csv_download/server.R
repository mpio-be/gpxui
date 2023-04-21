
function(input, output, session) {

  observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))


  df <- reactive({
  
      gpsid <- 1 # read_gpsID(allff[grep("startup.txt$", name)]$datapath)
      pts <- read_all_waypoints(input$garmin_dir$datapath, sf = TRUE)
      trk <- read_all_tracks(input$garmin_dir$datapath, sf = TRUE)
    
      list(gpsid=gpsid, pts=pts, trk=trk)
  
  })

  output$gps_files <- renderLeaflet({

   req(input$garmin_dir)

   leaflet(options = leafletOptions(zoomControl = FALSE)) |>
     addTiles() |>
     addCircleMarkers(
       data = df()$pts,
       fillOpacity = 0.5,
       opacity = 0.5,
       radius = ~3,
       label = ~ gps_point,
       labelOptions = labelOptions(
          noHide = TRUE,    
          direction = "auto", 
          background = "transparent",
          offset = c(2,0)
        )
     ) |>
    addPolylines(
      data = df()$trk,
      color = "#da3503"
    )
 

  })

   output$track_summary <- renderUI({

   req(input$garmin_dir)

    o = paste(
      df()$trk |>
        track_summary() |>
        gt() |>
        fmt_number() |>
        tab_header(title = md("Tracks")) |>
        opt_interactive(use_compact_mode = TRUE) |>
        as_raw_html()
      ,
      df()$pts |>
        points_summary() |>
        gt() |>
        fmt_number() |>
        tab_header(title = md("Points")) |>
        opt_interactive(use_compact_mode = TRUE) |>
        as_raw_html()
    , collapse = "<hr>")
    
    print(o)

    HTML(o)


  })

  
 }
