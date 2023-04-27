#' gpx_file_upload_check
#' @export 
#' @param  x a data.frame returned by UI after dir upload
#' 
gpx_file_upload_check <- function(x) {

  d = data.table(x)

  did = deviceID(d[name == "DEVICE_ID.txt", datapath])

  if (is.na(did)) 
    o1 = "GPS ID not found!" else 
    o1 = glue("GPS {did} detected.")

  ngpx = nrow(d[str_detect(name, "\\.gpx$")])

  if (ngpx == 0) o2 = glue("Files uploaded OK but the folder has no {tags$code('gpx')} files. Did you upload the correct folder?") else 
  o2 = glue("{ngpx} files uploaded.") 
  

   tagList(h4(o1 |> HTML()), h4(o2 |> HTML()))
  


}