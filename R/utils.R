
dt2lines <- function(x, grp, CRS = 4326) {
  x |>
    st_as_sf(coords = c("lon", "lat"), crs = CRS) |>
    dplyr::group_by(.data[[grp]]) |>
    dplyr::summarise(
      do_union = FALSE, 
      .groups = "keep", 
      mean_ele = mean(ele),
      max_ele = max(ele),
      min_ele = min(ele),
      max_dt = max(datetime_),
      min_dt = min(datetime_),
      n = dplyr::n()
      
      ) |>
    st_cast("MULTILINESTRING")
}


#' dirInput
#' @export
#' @examples
#' require(shiny)
#' options(shiny.maxRequestSize = 10 * 1024^2)
#' 
#' ui <- fluidPage(
#'
#'
#'   sidebarLayout(
#'     sidebarPanel(
#'       dirInput("fileIn", "Choose dir")
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

dirInput <- function(inputId, label = "choose dir", width = NULL, buttonLabel = "Browse...", placeholder = "No files selected.") {

  
  inputTag <- tags$input(
    id              = inputId, 
    name            = inputId, 
    type            = "file", 
    webkitdirectory = TRUE, 
    onchange        = "pressed()",
    style           = "display: none;"
  )


  div(
    class = "form-group shiny-input-container", 
    style = htmltools::css(width = validateCssUnit(width)),
    shiny:::shinyInputLabel(inputId, label), 
      
      div(
        class = "input-group",
        tags$label(
          class = "input-group-btn input-group-prepend",
          span(
            class = "btn btn-default bttn-unite btn-danger btn-large", 
            buttonLabel,
            inputTag
          )
        ),
        tags$input(
          type = "text", 
          class = "form-control",
          placeholder = placeholder, 
          readonly = "readonly"
        )
      )

      ,
      tags$div(
        id = paste(inputId, "_progress", sep = ""),
        class = "progress active shiny-file-input-progress",
        tags$div(class = "progress-bar")
      )
  )


}

#' @export
track_summary <- function(x) {
  o = sf::st_drop_geometry(x) |> setDT()
  o[, dist := sf::st_length(x) |> units::set_units("km")]
  o[, deltat := difftime(max_dt, min_dt, units = "hours")]

  o = o[, .(
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
  o = melt(o, id.vars = "i")[, i := NULL]

  o

}

#' @export
points_summary <- function(x) {

  h =
    sf::st_union(x) |>
    sf::st_convex_hull() |>
    sf::st_area() |>
    units::set_units("km^2")

  o = data.table(
    `N_points` = nrow(x) |> as.character(),
    `first point` = x$gps_point[1] |> as.character(), 
    `last point` = x$gps_point[nrow(x)] |> as.character(), 
    `Area covered (km²)` = round(h, 2) |> as.character()
  )
  
  o[, i := 1]
  o = melt(o, id.vars = "i")[, i := NULL]

  o




}