
grid_page(

  # includeCSS('~/github/mpio-be/gpxui/inst/style.css'), 
  includeCSS(system.file(package = "gpxui", "www", "style.css")),

  theme = bs_theme(
    version = 5, bg = "#06262e", fg = "#e7debd",
  ),
  layout = c(
    "IO        map feedback",
    "explore   map summary"
  ),
  col_sizes = c("1fr", "3fr", "1fr"),
  row_sizes = c("2fr", "2fr"),
  gap_size = "0px",


#* Upload
  grid_card(area = "IO",

  card_header( span(icon("location"), "Garmin GPS manager") |> h4()),

  bs5modal("help", "Help",
  
  includeMarkdown(system.file(package = "gpxui", "www", "help.md"))
  
  ),


  dirInput("upload_GPX", label = NULL, placeholder = "./GARMIN/Garmin/GPX") , 


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

#* Download
  grid_card(area = "explore",
  
  card_header("Explore database" |> tags$b()),

  selectInput(
    inputId = "gps_id",
    label = "Select GPSs:",
    choices = GPS_IDS,
    multiple = TRUE
  )
  
  ,

  dateInput(inputId = "show_after",
    label = "Pick a start date:"
    )






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
    card_header( icon("comment") ), 
    
   
    uiOutput("track_summary")
    
    
    
    )




)