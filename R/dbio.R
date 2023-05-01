

#' gpx_to_database
#' saves new entries to database
#' @param con a connection to db
#' @param x a data.table; output of read_all_waypoints() or read_all_tracks().
#' @param tab database table 
#' @return a data.frame containing last entry in db prior to database update and the number of updated entries. 
#' @export
#' @examples
#' require(dbo)
#' ff <- system.file(package = "gpxui", "Garmin65s") |> as_dirInput_output()
#' con <- dbcon(server = "localhost", db = "tests")
#'
#' x <- read_all_waypoints(ff)
#' gpx_to_database(con, x, tab = "GPS_POINTS")
#' 
#' x <- read_all_tracks(ff)
#' gpx_to_database(con, x, tab = "GPS_TRACKS")
#'
#' DBI::dbDisconnect(con)
#'
gpx_to_database <- function(con, x, tab) {

  gid = x$gps_id[1]
  stopifnot(!is.na(gid))
  
  lastdt <- dbq(con, glue("SELECT max(datetime_) dt from {tab} 
                      WHERE gps_id = {gid}")
  )$dt

  if (is.na(lastdt)) {
    # revert to the date of the first GPS ever produced
    lastdt = as.POSIXct("1989-10-01", format = "%Y-%m-%d")
  }

  x1 = x[datetime_ > lastdt]


  rows_in_db_after_update <- DBI::dbAppendTable(con, tab, x1)

  data.frame(last_entry_before_update = lastdt, rows_in_db_after_update, tab = tab)


}



read_GPX_table <- function(con, dt, tab, sf = FALSE) {

  o = dbq(con, glue("SELECT * FROM {tab} where datetime_ > {shQuote(dt)}"))
  
  if(sf) {
    o = st_as_sf(o, coords = c("lon", "lat"), crs = 4326)

    if(tab == "GPS_TRACKS")
      o = dt2lines(o, "seg_id")
  }

  o

}