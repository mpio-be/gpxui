


test_that("read_waypoints() returns a dt", {
  read_waypoints(gpxfile) |> expect_s3_class("data.table")
})

test_that("read_tracks() returns a dt", {

  read_tracks(gpxfile) |> expect_s3_class("data.table")


})

test_that("deviceID() works on an as_dirInput_output() return", {
  deviceID(dirout) |> expect_identical(1)
})

test_that("read_all_waypoints() returns a proper dt", {
  z = read_all_waypoints(dirout)

  expect_s3_class(z, "data.table")

  nams = c("gps_id", "gps_point", "datetime_", "ele", "lon", "lat")

  expect_equal(names(z), nams)
})

test_that("read_all_waypoints() returns NULL on zero rows input", {
  head(dirout, 0) |>
    read_all_waypoints() |>
    expect_null()
})

test_that("read_all_tracks() returns a proper dt", {
  z = read_all_tracks(dirout)

  expect_s3_class(z, "data.table")

  nams = c("gps_id", "seg_id", "seg_point_id", "datetime_", "ele", "lon","lat")

  expect_equal(names(z), nams)
})

test_that("read_all_tracks() returns NULL on zero rows input", {
  head(dirout, 0) |>
    read_all_tracks() |>
    expect_null()
})

test_that("DT2gpx writes a gpx file", {
  

  outf = tempfile(fileext = ".gpx")
  z = suppressWarnings({
    read_all_waypoints(dirout)
  })


  DT2gpx(z, nam = "gps_point", dest = outf) |> expect_true()

  o = suppressWarnings({
    o = sf::st_read(outf, layer = "waypoints", quiet = TRUE)
  })
  
  expect_s3_class(o, "sf")
  
})
