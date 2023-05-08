

gpxfile <- system.file(package = "gpxui", "Garmin65s", "GPX", "Waypoints_20-APR-23.gpx")

gpxdir <- system.file(package = "gpxui", "Garmin65s", "GPX")
dirout <- as_dirInput_output(gpxdir)


gpxdir_noid <- system.file(package = "gpxui", "Garmin65s", "GPX", "Current")
dirout_noid <- as_dirInput_output(gpxdir_noid)



cleandb <- function() {

  con <- dbo::dbcon(server = "localhost", db = "tests")
  DBI::dbExecute(con, "TRUNCATE GPS_POINTS")
  DBI::dbExecute(con, "TRUNCATE GPS_TRACKS")
  DBI::dbDisconnect(con)

}
