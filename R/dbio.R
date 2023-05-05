

#' gpx_to_database
#' saves new entries to database
#' @param con a connection to db
#' @param x a data.table; output of read_all_waypoints() or read_all_tracks().
#' @param tab database table (GPS_TRACKS, GPS_POINTS)
#' @return a data.frame containing last entry in db prior to database update and the number of updated entries. 
#' @export
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

#' read_GPX_table
#' Fetch database tables
#' @param con a connection to db
#' @param tab database table   (GPS_TRACKS, GPS_POINTS)
#' @param dt  database valid datetime. Only entries after this are returned. Detault to "1900-01-01"
#' @param sf when TRUE returns a sf df. default to FALSE
#' @export
read_GPX_table <- function(con, tab, dt = "1900-01-01", sf = FALSE) {

  o = dbq(con, glue("SELECT * FROM {tab} where datetime_ > {shQuote(dt)}"))
  
  if(sf) {
    o = st_as_sf(o, coords = c("lon", "lat"), crs = 4326)

    if(tab == "GPS_TRACKS")
      o = dt2lines(o, "seg_id")
  }

  o

}