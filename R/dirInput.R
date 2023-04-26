#' dirInput
#' @export
#' @examples
#' require(shiny)
#' # options(shiny.maxRequestSize = 10 * 1024^2)
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
    # onchange        = "directorySelected(event)",
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
