#' dirInput
#' @export
#' @examples
#' require(shiny)
#' options(shiny.maxRequestSize = 10 * 1024^3)
#'
#' ui <- fluidPage(
#'   sidebarLayout(
#'     sidebarPanel(
#'       dirInput("fileIn")
#'     ),
#'     mainPanel(
#'       tableOutput("contents")
#'     )
#'   )
#' )

#' server <- function(input, output) {
#'   output$contents <- renderTable({
#' print(input$fileIn)
#' if(!is.null(input$fileIn))
#' data.table(input$fileIn)[, file.size(datapath), by = name]
#'   })
#' }

#' shinyApp(ui, server)

dirInput <- function(inputId, label = NULL, placeholder = "No dir selected.") {

  div(
    class = "form-group shiny-input-container",
    shiny:::shinyInputLabel(inputId, NULL),
    div(
      class = "input-group",
      tags$label(
        class = "input-group-btn input-group-prepend",
        span(
          class = paste("btn btn-default", "btn-secondary"), a(icon("folder-open"), "Browse"),
          tags$input(
            id = inputId,
            name = inputId,
            type = "file",
            webkitdirectory = TRUE,
            onchange = "pressed()",
            style = "display: none;"
          )
        )
      ),
      tags$input(
        type = "text",
        class = "form-control",
        placeholder = placeholder,
        readonly = "readonly"
      )
    ),
    tags$div(
      id = paste(inputId, "_progress", sep = ""),
      class = "progress active shiny-file-input-progress",
      tags$div(class = "progress-bar bg-success")
    )
  )




}

#' bs5modal
#' @export
bs5modal <- function(inputId, label = inputId, ...) {

  div(
    p(
      type = "button",
      `data-bs-toggle` = "modal",
      `data-bs-target` = paste0("#", inputId),
      span(
        icon("info-circle"),
        label,
        class = "badge rounded-pill bg-secondary"
      )
    ) |>
      h5(),
    div(
      class = "modal", id = inputId,
      div(
        class = "modal-dialog modal-xl",
        div(
          class = "modal-content",
          div(
            class = "modal-header",
            label,
            tags$button(
              class = "btn-close",
              `data-bs-dismiss` = "modal",
              `aria-label` = "Close"
            )
          ),
          div(
            class = "modal-body",
            ...
          )
        )
      )
    )
  )

}




#' gpx_file_upload_check
#' @export 
#' @param  x a data.frame returned by UI after dir upload. See [gpxui::dirInput()]
#' 
gpx_file_upload_check <- function(x) { 

  did = deviceID(x)

  d = data.table(x)


  if (is.na(did)) 
    o1 = "GPS ID not found!" else 
    o1 = glue("<span class='badge rounded-pill bg-success'>GPS {did}</span>  detected.") |> HTML()

  ngpx = nrow(d[str_detect(name, "\\.gpx$")])

  if (ngpx == 0) 
  o2 = glue("Files uploaded OK but the selected folder contains no {tags$code('gpx')} files. Did you select the correct folder?") |> HTML() else 
  o2 = glue("Found {ngpx} files.") 
  

  tagList(
    o1 |>tags$li() |>tags$b() , 
    o2 |>tags$li() |>tags$b() 
    )



}


#' track_summary
#' @export
track_summary <- function(x) {
  if (nrow(x) == 0) o <- data.table(Info = "No GPX track files found")

  if (nrow(x) > 0) {
    o <- sf::st_drop_geometry(x) |> setDT()
    o[, dist := sf::st_length(x) |> units::set_units("km")]
    o[, deltat := difftime(max_dt, min_dt, units = "hours")]

    o <- o[, .(
      `N track points` = nrow(o) |> as.character(),
      `mean elevation` = weighted.mean(mean_ele, w = n) |> round(2) |> as.character(),
      `max elevation` = max(max_ele) |> round(2) |> as.character(),
      `min elevation` = min(max_ele) |> round(2) |> as.character(),
      `start hour` = min(min_dt) |> format("%H:%M"),
      `stop hour` = max(max_dt) |> format("%H:%M"),
      `avg speed (km/hour)` = weighted.mean(as.numeric(dist) / as.numeric(deltat), w = n) |>
        round(2) |>
        as.character()
    )]

    o[, i := 1]
    o <- melt(o, id.vars = "i")[, i := NULL]

    if (nrow(x) == 0) {
      o <- o[1, ]
    }
  }

  o
}

#' points_summary
#' @export
points_summary <- function(x) {
  if (nrow(x) == 0) o <- data.table(Info = "No GPX waypoints files found")

  if (nrow(x) > 0) {
    h <-
      x |>
      sf::st_union() |>
      sf::st_convex_hull() |>
      sf::st_area() |>
      units::set_units("km^2")

    o <- data.table(
      `N waypoints` = nrow(x) |> as.character(),
      `first point` = x$gps_point[1] |> as.character(),
      `last point` = x$gps_point[nrow(x)] |> as.character(),
      `Area covered (km²)` = round(h, 2) |> as.character()
    )

    o[, i := 1]
    o <- melt(o, id.vars = "i")[, i := NULL]

    if (nrow(x) == 0) {
      o <- o[1, ]
    }
  }


  o
}

#' gpx_summary
#' @export
gpx_summary <- function(pts, trk) {
    
  trk_smr = track_summary(trk)  
  pst_smr = points_summary(pts)


  trk_tab <-
  knitr::kable(trk_smr, 
    caption = "Track",
    digits = 2,
    table.attr = "class = 'table table-striped table-sm'",
    format = "html"
  ) |>
  HTML()

  trk_pts <-
  knitr::kable(pst_smr,
    caption = "Points",
    digits = 2,
    table.attr = "class = 'table table-striped table-sm'",
    format = "html"
  ) |>
  HTML()



  div(
  trk_tab,
  trk_pts
  )



}
