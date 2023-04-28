
  grid_page(
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
    theme = bs_theme(
      version = 5, bg = "#06262e", fg = "#e7debd"
    ),
    layout = c(
      "import map",
      "export feedback"
    ),
    col_sizes = c("1fr", "2fr"),
    row_sizes = c("3fr", "2fr"),
    gap_size = "1px",

    # Import
    grid_card(
      area = "import",
      card_header("GPS manager"),
      withTags(
        ol(
          li("Plug-in your GPS and wait until it is recognised by your PC.") |> h6(),
          li("Press", u("GPS upload"), ",select", kbd("./GARMIN/Garmin/GPX"), "and", u("Upload")) |> h6()
        )
      ),
      paste(
        icon("circle-info"),
        "If you get",
        tags$q("Maximum upload size exceeded"),
        "you probably selected the wrong folder."
      ) |> HTML() |> p(),
      hr(),
      dirInput("garmin_dir"),
      uiOutput("file_upload_feedback")
    ),
    # to csv
    grid_card(
      area = "export",
      card_header("Export waypoints"),
      downloadButton("download_points", "CSV export")
    ),
    grid_card(
      area = "map",
      card_body(
        leafletOutput(outputId = "MAP")
      )
    ),
    grid_card(
      area = "feedback",
      uiOutput("track_summary")
    )
  )
