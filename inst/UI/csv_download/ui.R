
# options(shiny.maxRequestSize = 10 * 1024^3)

fluidPage(


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
       dirInput("garmin_dir", "Choose dir"), 

       uiOutput("file_upload_feedback"), 

       downloadButton("download_points", "Download"),

     ),
     mainPanel(

       leafletOutput(outputId = "MAP"), 

       uiOutput("track_summary")
       
       


     )
   )


 )
