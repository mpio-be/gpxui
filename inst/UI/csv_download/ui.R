
# options(shiny.maxRequestSize = 10 * 1024^3)

fluidPage(

  useShinyjs(), 

  tags$head(
    tags$style(
      HTML(
        ".leaflet-tooltip {
            background-color: transparent;
            border: none;
          }
          "
      )
    )
  ),

# garmin_dir_progress

   sidebarLayout(




     sidebarPanel(
       dirInput("garmin_dir", "Choose dir")
     ),
     mainPanel(

       leafletOutput(outputId = "gps_files"), 

       uiOutput("track_summary")
     )
   )


 )
