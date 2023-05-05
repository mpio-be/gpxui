
f = system.file(package = "gpxui", "Garmin65s", "GPX")

test_that("as_dirInput_output returns a df", {

  as_dirInput_output(f)  |> expect_s3_class("data.frame")

})
