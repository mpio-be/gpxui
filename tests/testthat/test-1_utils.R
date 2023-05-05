
require(dbo)

f = system.file(package = "gpxui", "Garmin65s", "GPX")
x   = as_dirInput_output(f)

# populate db tables in case they are empty
gpx_to_database(server = "localhost", db = "tests", read_all_waypoints(x), tab = "GPS_POINTS")
gpx_to_database(server = "localhost", db = "tests", read_all_tracks(x), tab = "GPS_TRACKS")



test_that("as_dirInput_output returns a df", {

  as_dirInput_output(f)  |> expect_s3_class("data.frame")

})


test_that("st_bbox_all works in all cases", {

  pts = read_GPX_table(server = "localhost", db = "tests", "GPS_POINTS", sf = TRUE)
  trk = read_GPX_table(server = "localhost", db = "tests", "GPS_TRACKS", sf = TRUE)
  
  st_bbox_all(list(pts, trk)) |> expect_s3_class("bbox")
  
  st_bbox_all(list(pts, head(trk, 0))) |> expect_s3_class("bbox")
  
  st_bbox_all(list(head(pts, 0), head(trk, 0))) |> expect_null()

})


con <- dbcon(server = "localhost", db = "tests")
DBI::dbExecute(con, "TRUNCATE GPS_POINTS")
DBI::dbExecute(con, "TRUNCATE GPS_TRACKS")
DBI::dbDisconnect(con)