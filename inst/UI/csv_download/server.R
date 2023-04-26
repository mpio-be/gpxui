
function(input, output, session) {

  observe(on.exit(assign("input", reactiveValuesToList(input), envir = .GlobalEnv)))
  
  output$MAP <- renderLeaflet({

    leaflet(options = leafletOptions(zoomControl = FALSE)) |>
      addTiles() |>
      addProviderTiles(provider = "OpenStreetMap.HOT") |>
      addControlGPS(
        options = gpsOptions(
          position   = "topleft",
          activate   = TRUE,
          autoCenter = TRUE,
          setView    = TRUE,
          maxZoom    = 12
        )
      ) |>
      activateGPS()

  })

  df <- reactive({
    
      gpsid <- 1 # TODO deviceID(allff[grep("startup.txt$", name)]$datapath)
      pts <- read_all_waypoints(input$garmin_dir$datapath, sf = TRUE)
      trk <- read_all_tracks(input$garmin_dir$datapath, sf = TRUE)


      list(gpsid=gpsid, pts=pts, trk=trk)
  
  })

  observe({

    req(input$garmin_dir)

    pts = df()$pts
    trk = df()$trk

    bbox = st_bbox_all(list(pts, trk)) |>as.numeric()

    map = leafletProxy("MAP") |>
      clearShapes() |>
      clearMarkers()
    
    if(!is.null(bbox))
     map = map |>
      fitBounds(lng1=bbox[1], lat1=bbox[2], lng2=bbox[3], lat2=bbox[4])

    if(!is.null(pts) && nrow(pts)>0 ) {
        map = map |>
        addCircleMarkers(
          data = pts ,
          fillOpacity = 0.5,
          opacity = 0.5,
          radius = 3,
          label = ~ gps_point ,
          labelOptions = labelOptions(
              noHide = TRUE,    
              direction = "auto", 
              background = "transparent",
              offset = c(2,0)
            )
        )
    }

    if(!is.null(trk) && nrow(trk)>0 )  {
      map = map |>
      addPolylines(
        data = trk,
        color = "#da3503"
      )
    }
      
    map  

 

  })

   output$track_summary <- renderUI({
    req(input$garmin_dir)

    # assign("X", df(), .GlobalEnv); df = function() {X}
    
    trk_tab <-
      df()$trk |>
      track_summary() |>
      kbl(caption = "Track", digits = 2) |>
      kable_material(lightable_options = "striped")

    trk_pts <-
      df()$pts |>
      points_summary() |>
      kbl(caption = "Points", digits = 2) |>
      kable_material(lightable_options = "striped")


    HTML(trk_tab, trk_pts)


   })


   file_upload_output <- reactive({


    "#TODO: function on input$garmin_dir used for feedback"

   })


  output$file_upload_feedback <- renderUI({
      file_upload_output()
  }) |>
    bindEvent(input$garmin_dir, ignoreNULL = FALSE, ignoreInit = FALSE)



  
 }
