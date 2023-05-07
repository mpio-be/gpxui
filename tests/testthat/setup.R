require(dbo)

gpxdir <- system.file(package = "gpxui", "Garmin65s", "GPX")

dirout <- as_dirInput_output(gpxdir)

gpxfile <- system.file(package = "gpxui", "Garmin65s", "GPX", "Waypoints_20-APR-23.gpx")


cleandb <- function() {

  con <- dbcon(server = "localhost", db = "tests")
  DBI::dbExecute(con, "TRUNCATE GPS_POINTS")
  DBI::dbExecute(con, "TRUNCATE GPS_TRACKS")
  DBI::dbDisconnect(con)

}
