export = "csv"
export = "database"

grid_page(
  useShinyjs(), 

  tags$head(
    tags$style(
      HTML(
        ".leaflet-tooltip {
            background-color: transparent;
            border: none;
          }
          "
      )
    )
  ),
  theme = bs_theme(
    version = 5, bg = "#06262e", fg = "#e7debd",
  ),
  layout = c(
    "upload    map summary",
    "download  map summary",
    "feedback  map summary"
  ),
  col_sizes = c("1fr", "3fr", "0.5fr"),
  row_sizes = c("3fr", "2fr", "2fr"),
  gap_size = "0px",

  #* Upload
  grid_card(area = "upload",
    
    card_header("Garmin GPS manager" |> h3()),
    div("open md help"), 
    dirInput("upload_GPX"), 
    
    textInput("last_pts_dt", "Last points")|> disabled(),
    textInput("last_trk_dt", "Last tracks")|> disabled()


  ),

#* Download
  grid_card(area = "download",
  
    downloadButton("download_points", "Export")

  ),


#* Feedback: upload and save
  grid_card(area = "feedback",  {

    uiOutput("file_upload_feedback")


    })
   ,

#* Map
  grid_card(area = "map",
    card_body_fill(
      leafletOutput(outputId = "MAP")
    )
  )
  ,

#* Feedback: track and points
   grid_card(area = "summary",
    card_header("NEw data"), 
    uiOutput("track_summary")
  )




)