
#' @export
gpx_ui <- function() {
grid_page(

  includeCSS(system.file(package = "gpxui", "www", "style.css")),
  theme = bs_theme(
    version = 5,
    bg = "#103c47", fg = "#e7debd"
  ),
  layout = c("controls  map feedback_bar"),
  col_sizes = c("1fr", "3fr", "1fr"),
  gap_size = "0px",

  #* Left (controls)
  grid_card(
    area = "controls",
    card_header(span(icon("location"), "Garmin GPS manager") |> h4()),
    ctrl_title("1. Upload", "cloud-upload"), br(),
    dirInput("upload_GPX", label = NULL, placeholder = "./GARMIN/Garmin/GPX"),
    hr(), ctrl_title("2. Export", "cloud-download"), br(),
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
      div(),


    # invisible input container for last datetime in db
    div(
      class = "invisible",
      style = "display: none",
      textInput("last_pts_dt", "Last points"),
      textInput("last_trk_dt", "Last tracks")
    ),
    hr(), ctrl_title("3. Explore", "map"), br(),
    selectInput(
      inputId = "gps_id",
      label = "Select GPS ID:",
      choices = GPS_IDS,
      multiple = TRUE
    ),
    dateInput(
      inputId = "show_after",
      label = "Pick a start date:"
    ),
    actionButton("go_explore", "Refresh!", 
      style="color: #103c47; background-color: #e7debd; border-color: #2e6da4") |> div()
  ),

  #* Map
  grid_card(
    area = "map",
    card_body(
      leafletOutput(outputId = "MAP")
    )
  ),




  #* Feedback: upload and save
  grid_card(
    area = "feedback_bar",
    card_header(icon("commenting")),
    uiOutput("feedback")
  )
)

}