
x <- as_dirInput_output(system.file(package = "gpxui", "Garmin65s", "GPX"))


test_that("dirInput is shiny", {

  dirInput("id") |> expect_s3_class("shiny.tag")

})


test_that("gpx_file_upload_check() works for both full and empty outputs", {

  o = gpx_file_upload_check(x)
  expect_s3_class(o, "shiny.tag.list")

  o = gpx_file_upload_check( head(x, 0))
  expect_s3_class(o, "shiny.tag.list")




})
