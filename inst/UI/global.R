
# ==========================================================================
# UI for fetching, visualising and exporting GPS data
#     /home/mihai/github/mpio-be/gpxui/inst/Garmin65s
#' shiny::runApp('./inst/UI/', launch.browser =  TRUE)
# ==========================================================================

#! Settings
  sapply(c(
    "gpxui",
    "shinyjs",
    "leaflet",
    "gridlayout",
    "bslib", 
    "sf",
    "dbo"
  ), require, character.only = TRUE, quietly = TRUE)
  tags <- shiny::tags

options(shiny.autoreload = TRUE)
options(shiny.maxRequestSize = 10 * 1024*2)
options(dbo.tz = "Europe/Berlin")

SERVER = "localhost"
DB = "tests"
