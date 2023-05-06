
# ==========================================================================
# UI for fetching, visualising and exporting GPS data
#     /home/mihai/github/mpio-be/gpxui/inst/Garmin65s
#' shiny::runApp('./inst/UI/', launch.browser =  TRUE)
# ==========================================================================

#! Packages, functions
  sapply(c( 
    "gpxui",
    "leaflet",
    "gridlayout",
    "bslib", 
    # "shinyWidgets",
    "sf",
    "dbo"
  ), require, character.only = TRUE, quietly = TRUE)

  cleandb <- function(db = "tests", server = "localhost") {
    if (db == "tests") {
      con <- dbcon(server = server, db = db)
      DBI::dbExecute(con, "TRUNCATE GPS_POINTS")
      DBI::dbExecute(con, "TRUNCATE GPS_TRACKS")
      DBI::dbDisconnect(con)
      message("GPS_POINTS & GPS_TRACKS tables are empty now.")
    }
  }

#! Options
  options(shiny.autoreload = TRUE)
  options(shiny.maxRequestSize = 10 * 1024^2)
  options(dbo.tz = "Europe/Berlin")

#* Variables
  SERVER = "localhost"
  DB = "tests"
  GPS_IDS = 1:10
  EXPORT_TABLES = c("GPS_POINTS", "GPS_TRACKS")
  


cleandb()