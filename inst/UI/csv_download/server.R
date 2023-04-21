
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

   output$track_summary <- function() {

   req(input$garmin_dir)

    trk_tab = 
      df()$trk |>
      track_summary() |>
      kable(caption = "Track", digits =2)

    trk_pts =
      df()$pts |>
      points_summary() |>
      kable(caption = "Points", digits = 2)

    kables(list(trk_tab, trk_pts), format = "html") |>
    kable_styling("striped", full_width = FALSE)


  }

  
 }
