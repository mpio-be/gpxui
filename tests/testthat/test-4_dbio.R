
require(dbo)
x = as_dirInput_output(system.file(package = "gpxui", "Garmin65s", "GPX"))

con = dbcon(server = "localhost", db = "tests")
DBI::dbExecute(con, "TRUNCATE GPS_POINTS")
DBI::dbExecute(con, "TRUNCATE GPS_TRACKS")

test_that("writing to db works as expected", {


  pp = read_all_waypoints(x)
  tt = read_all_tracks(x)

  # POINTS
  o = gpx_to_database(con, pp, tab = "GPS_POINTS")
  expect_s3_class(o, "data.frame")
  expect_true(o$rows_in_db_after_update == 10)
  
  # subsequent update
  o = gpx_to_database(con, pp, tab = "GPS_POINTS")
  expect_s3_class(o, "data.frame")
  expect_true(o$rows_in_db_after_update == 0)

  # TRACKS
  o = gpx_to_database(con, tt, tab = "GPS_TRACKS")
  expect_s3_class(o, "data.frame")
  expect_true(o$rows_in_db_after_update == 32)
  
  # subsequent update
  o = gpx_to_database(con, tt, tab = "GPS_TRACKS")
  expect_s3_class(o, "data.frame")
  expect_true(o$rows_in_db_after_update == 0)

})

test_that("reading from db works as expected", {

  read_GPX_table(con, "GPS_POINTS") |>
    expect_s3_class("data.frame")
  o = read_GPX_table(con, "GPS_POINTS", dt = "2023-04-20 10:10")
  expect_true( all(o$datetime_ > as.POSIXct("2023-04-20 10:10")) )
  read_GPX_table(con, "GPS_POINTS", sf = TRUE) |>
      expect_s3_class("sf")


  read_GPX_table(con, "GPS_TRACKS") |>
    expect_s3_class("data.frame")
  x = read_GPX_table(con, "GPS_TRACKS", dt = "2023-04-20 10:10")
  expect_true( all(o$datetime_ > as.POSIXct("2023-04-20 10:10")) )
  read_GPX_table(con, "GPS_TRACKS", sf = TRUE) |>
    expect_s3_class("sf")
  

})

DBI::dbExecute(con, "TRUNCATE GPS_POINTS")
DBI::dbExecute(con, "TRUNCATE GPS_TRACKS")
DBI::dbDisconnect(con)