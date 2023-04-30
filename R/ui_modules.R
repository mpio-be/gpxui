#' dirInput
#' @export
#' @examples
#' require(shiny)
#' # options(shiny.maxRequestSize = 10 * 1024^2)
#'
#' ui <- fluidPage(
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

dirInput <- function(inputId, label = NULL, width = "100%", buttonLabel = "GPS upload", placeholder = "./GARMIN/Garmin/gpx") {
  inputTag <- tags$input(
    id              = inputId,
    name            = inputId,
    type            = "file",
    webkitdirectory = TRUE,
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
          class = "btn btn-dark",
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
    ),
    tags$div(
      id = paste(inputId, "_progress", sep = ""),
      class = "progress active shiny-file-input-progress",
      tags$div(class = "progress-bar bg-danger", role = "progressbar")
    )
  )
}

#' gpx_file_upload_check
#' @export 
#' @param  x a data.frame returned by UI after dir upload
#' 
gpx_file_upload_check <- function(x) {

  d = data.table(x)

  did = deviceID(d[name == "DEVICE_ID.txt", datapath])

  if (is.na(did)) 
    o1 = "GPS ID not found!" else 
    o1 = glue("<span class='badge rounded-pill bg-success'>GPS {did}</span>  detected.") |> HTML()

  ngpx = nrow(d[str_detect(name, "\\.gpx$")])

  if (ngpx == 0) 
  o2 = glue("Files uploaded OK but the selected folder contains no {tags$code('gpx')} files. Did you select the correct folder?") |> HTML() else 
  o2 = glue("{ngpx} files uploaded.") 
  

   tagList(
     o1 |>tags$li() |>h5() , 
     o2 |>tags$li() |>h5() 
     )
  


}
