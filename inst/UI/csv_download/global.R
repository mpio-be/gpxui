
# ==========================================================================
# UI for fetching, visualising and exporting GPS data
#     /home/mihai/github/mpio-be/gpxui/inst/Garmin65s
#' shiny::runApp('./inst/UI/csv_download', launch.browser =  TRUE)
# ==========================================================================

#! Settings
  sapply(c(
    "gpxui",
    "leaflet",
    "shinyWidgets",
    "gridlayout",
    "bslib", 
    "kableExtra", 
    "shinyjs"
  ), require, character.only = TRUE, quietly = TRUE)
  tags <- shiny::tags
