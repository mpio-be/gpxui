
# ==========================================================================
# UI for fetching, visualising and exporting GPS data
#' shiny::runApp('./inst/UI/csv_download', launch.browser =  TRUE)
# ==========================================================================

#! Settings
  sapply(c(
    "gpxui",
    "leaflet",
    "shinyWidgets",
    "gridlayout",
    "bslib"
  ), require, character.only = TRUE, quietly = TRUE)
  tags <- shiny::tags
