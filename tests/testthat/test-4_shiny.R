
cleandb()

gpx_to_database(server = "localhost", db = "tests", read_all_waypoints(dirout), tab = "GPS_POINTS")
gpx_to_database(server = "localhost", db = "tests", read_all_tracks(dirout), tab = "GPS_TRACKS")

PTS = read_GPX_table(server = "localhost", db = "tests", "GPS_POINTS", sf = TRUE)
TRK = read_GPX_table(server = "localhost", db = "tests", "GPS_TRACKS", sf = TRUE)
BBO  = st_bbox_all(list(PTS, TRK)) 


test_that("gpx_file_upload_check() works for both full and empty input", {
  o = gpx_file_upload_check(dirout)
  expect_s3_class(o, "shiny.tag.list")

  o = gpx_file_upload_check(head(dirout, 0))
  expect_s3_class(o, "shiny.tag.list")
})

test_that("dirInput is shiny", {
  dirInput("id") |> expect_s3_class("shiny.tag")
})

test_that("basemap is leaflet", {
  basemap() |> expect_s3_class("leaflet")
})

test_that("basemap() is updated by gpxmap() with bbox, pts and trks", {
  basemap() |>
    gpxmap(BBO, PTS, TRK) |>
    expect_s3_class("leaflet")
})

test_that("track_summary() works for both full and empty input", {

  track_summary(TRK) |>
    expect_s3_class("data.table")
  
  track_summary(head(TRK, 0)) |>
    suppressWarnings() |>
    expect_s3_class("data.table")

  points_summary(PTS) |>
    expect_s3_class("data.table")
  
  points_summary(head(PTS, 0)) |>
    suppressWarnings() |>
    expect_s3_class("data.table")


})

test_that("gpx_summary() works ", {
  gpx_summary(PTS, TRK) |>
    expect_s3_class("shiny.tag")
})

test_that("gpx_summary() works on empty tables", {

  cleandb()

  PTS <- read_GPX_table(server = "localhost", db = "tests", "GPS_POINTS", sf = TRUE)
  TRK <- read_GPX_table(server = "localhost", db = "tests", "GPS_TRACKS", sf = TRUE)

  gpx_summary(PTS, TRK) |>
    expect_s3_class("shiny.tag")
  

})
