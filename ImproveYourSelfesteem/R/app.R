library(shiny)
library(wordcloud)
library(dplyr)
library(markdown)
library(readr)
library(DT)
library(bslib)
library(ggplot2)
library(RColorBrewer)

ui <- shiny::navbarPage(
  "Improve your selfesteem",
  theme = bslib::bs_theme(
    bootswatch = "lux",
    navbar_color = "#3498db",
    text_color = "#00008B",
    primary = "#3498db",
    secondary = "#3498db",
    success = "#3498db",
    info = "#3498db",
    warning = "#ffc107",
    danger = "#dc3545"
  ),
  fluid = TRUE,
  # Tab showing the introduction message of the app
  shiny::tabPanel("Introduction",
    shiny::uiOutput("introduction"),
    shiny::imageOutput("selflove")
  ),

  # Whitebook tab
  shiny::navbarMenu("Whitebook",

    # Entry whitebook
    shiny::tabPanel("New entry",
      # Explanation whitebook
      shiny::p("Welcome to your Whitebook! This is where you jot down the
        positive moments of your day, how they made you feel, and what they
        reveal about your character/personality traits. For instance, you might
        write completing a task like doing the dishes. Perhaps it left you
        feeling proud. This event could suggest personality traits like
        determination or helpfulness. Share as many positive experiences,
        emotions, and traits as you can. Don't hesitate to repeat!"),
      # Input user whitebook
      shiny::textInput("q1_input", "Describe a positive event from today.
        It can be anything, big or small. E.g., 'I did the dishes.'"),
      shiny::textInput("q2_input", "How did it make you feel? For example, happy,
        excited, proud, or neutral?"),
      shiny::textInput("q3_input", "What does this event say about you?
        Which positive personality trait is evident? E.g., determined, helpful,
        creative. Enter one trait at a time and submit."),
      # Submit input
      shiny::actionButton("save_button", "Submit")
      ),

    # Table of whitebook data
    shiny::tabPanel("View entries",
      shiny::p("Here, you can review all the entries you've submitted to your
        whitebook. You'll see the positive events you've described,how they
        made you feel, and the personality traits you've associated with
        them."),
      DT::dataTableOutput("whitebook_table")
    ),

    # Wordcloud of positive traits tab
    shiny::tabPanel("Wordcloud",
      # Explanation wordcloud
      shiny::p("This wordcloud displays all the positive traits you've recorded
        in your whitebook. The size of each word reflects how frequently you've
        mentioned that trait—the more often you've entered it, the larger it
        appears. Do you think these traits might describe you?"),
      # Show wordcloud
      shiny::plotOutput("wordcloud"),
      shiny::downloadButton("download_wordcloud", "Save Wordcloud as Image")
    )
  ),

  # Likelihood positive self-image
  shiny::navbarMenu("Positive self-image",

    # New entries rating likelihood positive self-image
    shiny::tabPanel("New entry",
      shiny::uiOutput("self_image_text"),
      shiny::sliderInput("slider1", label = "Right
        now, how likely do you think it is that that sentence is true?",
        min = 0, max = 100, value = 50),
      shiny::actionButton("save_button2", "Submit")
    ),

    # Graphing belief in positive self-image
    shiny::tabPanel("Progress graph",
      shiny::p("Down below there is a graph showing how your belief in your
        desired positive self-image has changed over time."),
      shiny::plotOutput("plot"),
      shiny::downloadButton("download_plot", "Save Plot as Image")
    )
  )
)

server <- function(input, output, session) {
  # Load background wordcloud function
  source("R/generate_wordcloud.R")
  source("R/dataloading.R")
  source("R/save_whitebook_entry.R")
  source("R/first_use_app.R")
  source("R/save_likelihood_selfimage.R")
  source("R/generate_likelihood_plot.R")

  # Load the content of the introduction text file
  introduction_text <- readr::read_file("inst/introduction.md")

  # Load user-defined positive self-image
  pos_selfimage <- if (file.exists("pos_selfimage.txt")) {
    readr::read_file("pos_selfimage.txt")
  } else {
    "Not defined yet"
  }

  # Show introduction if first using app
  first_use_app(input, output, introduction_text)

  # Render the introduction text
  output$introduction <- shiny::renderUI({
    shiny::HTML(markdown::markdownToHTML(introduction_text, template = FALSE))
  })

  # Render image
  output$selflove <- renderImage({

    list(src = "R/www/selflove.png", width = "50%")

  }, deleteFile = FALSE)

  # Render the positive self-image text
  output$self_image_text <- renderUI({
    p(paste("When you first started up this app
      you defined your desired self-image to be:", pos_selfimage, "."))
  })

  # Create empty data frames for if data does not exist
  default_whitebook_data <- data.frame(Date = character(0),
                                       Event = character(0),
                                       Feeling = character(0),
                                       Pers_trait = character(0),
                                       stringsAsFactors = FALSE)

  default_wordcloud_data <- data.frame(word = character(0),
                                       freq = numeric(0),
                                       stringsAsFactors = FALSE)

  default_selfimage_data <- data.frame(date = as.Date(character(0)),
                                       likelihood_selfimage = numeric(0))

  # Load data if it exists, otherwise load default data
  whitebook_data <- dataloading("whitebook_data.csv", default_whitebook_data)
  wordcloud_data <- dataloading("wordcloud_data.csv", default_wordcloud_data)
  selfimage_data <- dataloading("selfimage_data.csv", default_selfimage_data)

  # Ensure date column is character type
  whitebook_data$Date <- as.character(whitebook_data$Date)

  # Render wordcloud
  output$wordcloud <- shiny::renderPlot({
    if (nrow(wordcloud_data) > 0) {
      generate_wordcloud(wordcloud_data)
    }
  })

  # Download wordcloud
  output$download_wordcloud <- shiny::downloadHandler(
    filename = function() {
      paste("positive_traits_wordcloud", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      png(file, width = 800, height = 600)
      generate_wordcloud(wordcloud_data)
      dev.off()
    }
  )

  # Render likelihood plot
  output$plot <- shiny::renderPlot({
    generate_likelihood_plot(selfimage_data, pos_selfimage)
  })
  # Download plot
  output$download_plot <- shiny::downloadHandler(
    filename = function() {
      paste("likelihood_positive_self_image", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      ggplot2::ggsave(file,
                      plot = ggplot2::last_plot(),
                      device = "png",
                      width = 8,
                      height = 6)
    }
  )

  # Render whitebook data table
  output$whitebook_table <- DT::renderDataTable({
    DT::datatable(whitebook_data)
  })

  # Handle submitted input whitebook
  save_whitebook_entry(input, output, whitebook_data)

  # Handle submitted input likelihood positive self-image
  shiny::observeEvent(input$save_button2, {
    # Get submitted input slider
    likelihood <- shiny::isolate(input$slider1)

    # Save likelihood positive self-image
    result <- save_likelihood_selfimage(selfimage_data,
                                        likelihood,
                                        "selfimage_data.csv")

    if (result$success) {
      selfimage_data <<- result$data

      # Update plot
      output$plot <- shiny::renderPlot({
        generate_likelihood_plot(selfimage_data, pos_selfimage)
      })

      # Show message that answers have been submitted
      shiny::showModal(shiny::modalDialog(
        title = "Submitted",
        "Your rating has been submitted successfully.",
        easyClose = TRUE,
        footer = shiny::actionButton("ok_submit2", "ok")
      ))

      # Close modal when ok button is pressed
      shiny::observeEvent(input$ok_submit2, {
        shiny::removeModal()
      })
    } else {
      # Show message when daily entry already submitted
      shiny::showModal(shiny::modalDialog(
        title = "Already Submitted",
        result$message,
        easyClose = TRUE,
        footer = shiny::actionButton("ok_submit3", "ok")
      ))

      # Close modal when ok button is pressed
      shiny::observeEvent(input$ok_submit3, {
        shiny::removeModal()
      })
    }
  })
}
