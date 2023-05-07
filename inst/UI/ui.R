
grid_page(

  includeCSS(system.file(package = "gpxui", "www", "style.css")),

  theme = bs_theme(
    version = 5, 
    bg = "#103c47", fg = "#e7debd"
  ),
  layout = c(
    "help      map feedback",
    "export    map summary",
    "explore   map summary"
  ),
  col_sizes = c("1fr", "2.5fr", "1fr"),
  row_sizes = c("1.5fr", "3fr", "3fr"),
  gap_size = "0px",

#* Help & Upload 
  grid_card(
    area = "help",
    card_header(span(icon("location"), "Garmin GPS manager") |> h4()), 

    bs5modal("help", "Help",
      includeMarkdown(system.file(package = "gpxui", "www", "help.md"))
      ), 
    hr(), 

    span(icon("cloud-upload"), "1. Upload",class="text-danger") |> strong(), 
    br(),
    dirInput("upload_GPX", label = NULL, placeholder = "./GARMIN/Garmin/GPX")

  ), 

#* Download
  grid_card(area = "export",

  card_header( span(icon("cloud-download"), "2. Export", class="text-danger") |> strong() ),


  selectInput(
    inputId = "export_object",
    label = "Pick to export:",
    choices = EXPORT_TABLES,
    multiple = FALSE
  ) |> div(),


  selectInput(
    inputId = "export_class",
    label = "Export as:",
    choices = c("gpx", "csv"),
    multiple = FALSE
  ), 

  downloadButton("download_points", "Export", class = "btn-secondary") |> 
  div() ,



  # invisible input container for last datetime in db
  div(
    class = "invisible",
    style = "display: none",
    textInput("last_pts_dt", "Last points"),
    textInput("last_trk_dt", "Last tracks")
  )



  ),

#* Explore
  grid_card(area = "explore",
  
  card_header( span(icon("map"), "3. Explore", class="text-danger")  |> strong() ),

  selectInput(
    inputId = "gps_id",
    label = "Select GPS ID:",
    choices = GPS_IDS,
    multiple = TRUE
  ),

  dateInput(inputId = "show_after",
    label = "Pick a start date:"
    ), 

  actionButton("go_explore", "Refresh!") |> div()


  ),


#* Feedback: upload and save
  grid_card(area = "feedback",  
    
    card_header(icon("commenting")), 

    uiOutput("file_upload_feedback")

    )
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
    card_header( icon("commenting") ), 
    
    uiOutput("track_summary")

    )




)