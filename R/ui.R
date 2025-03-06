
#' @export
gpx_ui <- function() {

bs4Dash::dashboardPage(
  help = NULL,
    dark = TRUE,
    title = "GPS manager"
  ,
  header = dashboardHeader(
    title = "GPS manager",
    border = FALSE,
    controlbarIcon = NULL,    
    sidebarIcon = NULL,       
    rightUi = tagList()  
   )
  ,
  sidebar = dashboardSidebar(
    collapsed = FALSE,
    sidebarMenu(
        
        ctrl_title("1. Upload", "cloud-upload"),
        
        dirInput("upload_GPX", label = NULL, placeholder = "./GARMIN/Garmin/GPX"),
        
        ctrl_title("2. Export", "cloud-download"),

        selectInput(
          inputId = "export_object",
          label = NULL,
          choices = EXPORT_TABLES,
          multiple = FALSE
          ),
        selectInput(
          inputId = "export_class",
          label = "export as:",
          choices = c("gpx", "csv"),
          multiple = FALSE
          ),
        
        ctrl_title("3. Explore", "map"),
        selectInput(
          inputId = "gps_id",
          label = "Select GPS ID:",
          choices = GPS_IDS,
          multiple = TRUE
        ),
        dateInput(
          inputId = "show_after",
          label = "Pick a start date:"
        ),
        actionButton(
          "go_explore",
          "Push to explore",
          style = "color: #103c47; background-color: #e7debd; border-color: #2e6da4;"
        ), 

        # Hidden inputs
        div(class = "invisible",style = "display: none;",
          textInput("last_pts_dt", "Last points"),
          textInput("last_trk_dt", "Last tracks")
        )


    )
  )
  , 
  body = dashboardBody(
    tags$head(includeCSS(system.file(package = "gpxui", "www", "style.css"))),
    

      leafletOutput(outputId = "MAP", width = "100%", height = "calc(99vh - 1px)")


    )
    ,
  
  controlbar = dashboardControlbar(
    collapsed = FALSE,
    pinned = TRUE,
    overlay = FALSE,
  
   shinycssloaders::withSpinner(

    id = "spinner",
    
    uiOutput("feedback"), 
    
      type = 1,       
      color = "#e7debd", 
      size = 1
    )
  
  )  

)

}