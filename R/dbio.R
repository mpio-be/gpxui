

#' gpx_to_database
#' saves new entries to database
#' @param server  pass to [dbo::dbcon()]
#' @param db pass to [dbo::dbcon()]
#' @param x output of [gpxui::read_all_waypoints()] or [gpxui::read_all_tracks()].
#' @param tab database table (GPS_TRACKS, GPS_POINTS)
#' @return a data.frame containing last entry in db prior to database update and the number of updated entries. 
#' @export
gpx_to_database <- function(server,db, x, tab) {

  if(! is.null(x) && nrow(x)>0 ) {

    con = dbcon(server = server, db = db)
    on.exit(DBI::dbDisconnect(con))

    gid = x$gps_id[1]
    
    if(!is.na(gid)) {
      lastdt <- dbq(con, glue("SELECT max(datetime_) dt from {tab} 
                          WHERE gps_id = {gid}")
      )$dt

      if (is.na(lastdt)) {
        # revert to the date of the first GPS ever produced
        lastdt = as.POSIXct("1989-10-01", format = "%Y-%m-%d")
      }

      x1 = x[datetime_ > lastdt]

      rows_in_db_after_update <- DBI::dbAppendTable(con, tab, x1)

      o = data.frame(last_entry_before_update = lastdt, rows_in_db_after_update, tab = tab, gps_id = gid)
      } else {
        o = data.frame(last_entry_before_update = as.POSIXct(NA), rows_in_db_after_update = 0, tab = tab, gps_id = as.numeric(NA))
      }

    } else {
    o = data.frame(last_entry_before_update = as.POSIXct(NA), rows_in_db_after_update = 0, tab = tab, gps_id = as.numeric(NA) )
  }


  o




}

#' read_GPX_table
#' Fetch database tables
#' @param server  pass to [dbo::dbcon()]
#' @param db pass to [dbo::dbcon()]
#' @param tab database table   (GPS_TRACKS, GPS_POINTS)
#' @param dt  database valid datetime. Only entries after this are returned. Default to "1900-01-01"
#' @param gps_id  gps id (one or more). Disregarded when missing, NA, NULL or non-numeric
#' @param sf when TRUE returns a sf df. default to FALSE
#' @export
read_GPX_table <- function(server, db, tab, dt = "1900-01-01", gps_id, sf = FALSE) {

  con = dbcon(server = server, db = db)
  on.exit(DBI::dbDisconnect(con))

  if(!missing(gps_id))
  gps_id = as.numeric(gps_id) |> unique() |> na.omit()

  sql = glue("SELECT * FROM {tab} where datetime_ > {shQuote(dt)}")

  if( !missing(gps_id) && length(gps_id) > 0 )
    sql = glue("{sql} AND gps_id IN ( {paste(gps_id, collapse = ',')} )")
  
  o = dbq(con,  sql )
  


  if(sf & nrow(o) > 0) {
    o = st_as_sf(o, coords = c("lon", "lat") , crs = 4326)

    if(tab == "GPS_TRACKS")
      o = dt2lines(o, "seg_id")
  }

  o

}


#' gpx_export
#' @export
gpx_export <- function(server, db,tab, file) {

  con = dbo::dbcon(server = server, db = db)
  on.exit(DBI::dbDisconnect(con))

  x = DBI::dbReadTable(con, tab) |> setDT()

  if(ncol(x) != 3 & !all(c('lat', 'lon') %in% names(x)) )
    stop("x has to have exactly 3 columns and col 2 & 3 are lat, lon")

  fnam = basename(file)
  ext = str_extract(fnam, "gpx$|csv$")

  if(ext == 'gpx')
    DT2gpx(x, nam = names(x)[1], dest = file)

  if(ext == 'csv')
    fwrite(x, file)


}