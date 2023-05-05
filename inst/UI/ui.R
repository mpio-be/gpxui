export = "csv"
export = "database"

grid_page(

  # includeCSS('~/github/mpio-be/gpxui/inst/style.css'), 
  includeCSS(system.file(package = "gpxui", "style.css")),

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

  card_header( p(icon("location"), "Garmin GPS manager") |> h4()),
  div("open md help"), 
  dirInput("upload_GPX"), 


  dateInput("show_after", "Show after:"), 

  # invisible input container for last datetime in db
  div(
    class = "invisible",
    style = "display: none",
    textInput("last_pts_dt", "Last points"),
    textInput("last_trk_dt", "Last tracks")
  )



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
    card_header( icon("comment") ), 
    
   
    uiOutput("track_summary")
    
    
    
    )




)