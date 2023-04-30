
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