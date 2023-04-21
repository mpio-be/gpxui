

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
    ) ),

   sidebarLayout(
     sidebarPanel(
       dirInput("garmin_dir", "Choose dir")
     ),
     mainPanel(

       leafletOutput(outputId = "gps_files"), 

       uiOutput("contents")
     )
   )
 )
