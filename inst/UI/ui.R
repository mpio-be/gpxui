export = "csv"
export = "database"

grid_page(

  # includeCSS('~/github/mpio-be/gpxui/inst/style.css'), 
  includeCSS(system.file(package = "gpxui", "style.css")),

  theme = bs_theme(
    version = 5, bg = "#06262e", fg = "#e7debd",
  ),
  layout = c(
    "IO        map feedback",
    "explore   map summary",
    "explore   map summary"
  ),
  col_sizes = c("1fr", "3fr", "1fr"),
  row_sizes = c("2fr", "2fr", "2fr"),
  gap_size = "0px",


#* Upload
  grid_card(area = "IO",

  card_header( p(icon("location"), "Garmin GPS manager") |> h4()),
  div("TODO: open md help"), 
  
  dirInput("upload_GPX", label = NULL, placeholder = "./GARMIN/Garmin/GPX"), 


  pickerInput(
    inputId = "export_object",
    label = "Pick to export:",
    choices = EXPORT_TABLES,
    multiple = FALSE,
    options = list(size = 3)
  ),

  pickerInput(
    inputId = "export_class",
    label = "Export as:",
    choices = c("gpx", "csv"),
    multiple = FALSE
  ),

  downloadButton("download_points", "Export"),


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

  pickerInput(
    inputId = "gps_id",
    label = "Select GPSs:",
    choices = GPS_IDS,
    multiple = TRUE,
    options = list(size = 3)
  )
  
  ,

  airDatepickerInput(inputId = "show_after",
    label = "Pick start time:",
    timepicker = TRUE
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