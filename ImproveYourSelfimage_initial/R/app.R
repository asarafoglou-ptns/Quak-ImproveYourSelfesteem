library(shiny)
library(wordcloud)
library(dplyr)
library(markdown)
library(readr)
library(DT)
library(bslib)
library(ggplot2)

ui <- shiny::navbarPage(
  "Improve your self-image",
  theme = bslib::bs_theme(version = 5, bootswatch = "lux"),
  includeCSS("styles.css"),
  fluid = TRUE,
  # Tab showing the introduction message of the app
  shiny::tabPanel("Introduction",
    shiny::uiOutput("introduction")
  ),

  # Whitebook tab
  shiny::tabPanel("Whitebook",
    # Explanation whitebook
    shiny::p("Describe what went well today, how it made you feel, and what
      these events tell you about yourself. It's okay to repeat positive events,
      feelings, or positive traits."),
    # Input user whitebook
    shiny::textInput("q1_input", "Describe something that went well/you did
      well today. Anything goes, big or small."),
    shiny::textInput("q2_input", "How did the event make you feel?"),
    shiny::textInput("q3_input", "What does the event say about you?
      which positive trait is evident from this event? If there is more
      than one positive trait that you can think of, enter the first trait,
      click submit, fill in the second trait, submit, and
      so on."),
    # Submit input
    shiny::actionButton("save_button", "Submit"),
    DT::dataTableOutput("whitebook_table")),

  # Wordcloud of positive traits tab
  shiny::tabPanel("Positive trait wordcloud",
    # Explanation wordcloud
    shiny::p("This is a wordcloud of all the positive traits you have entered in
      your whitebook. Bigger words indicate that you have entered the positive
      trait more often. Do you think these traits might describe you?"),
    # Show wordcloud
    shiny::plotOutput("wordcloud")
    ),

  # Likelihood positive self-image
  shiny::navbarMenu("Positive self-image",
    shiny::tabPanel("Entry",
      shiny::uiOutput("self_image_text"),
      shiny::sliderInput("slider1", label = "Right
        now, how likely do you think it is that that sentence is true?", min = 0,
        max = 100, value = 50),
      shiny::actionButton("save_button2", "Submit"),
    ),
    shiny::tabPanel("Graph",
      shiny::plotOutput("plot")
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

  # Load the content of the introduction text file
  introduction_text <- readr::read_file("R/introduction.md")

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
  likelihood_data <- dataloading("selfimage_data.csv", default_wordcloud_data)

  # Ensure Date column is character
  whitebook_data$Date <- as.character(whitebook_data$Date)

  # Render wordcloud
  output$wordcloud <- shiny::renderPlot({
    if (nrow(wordcloud_data) > 0) {
      generate_wordcloud(wordcloud_data)
    }
  })

  # Render likelihood graph
  output$plot <- shiny::renderPlot({
    # Create the line and point graph with date on the x-axis
    ggplot2::ggplot(likelihood_data, ggplot2::aes(x = date, y = likelihood_selfimage)) +
      ggplot2::geom_line(color = "blue", size = 1) +
      ggplot2::geom_point(color = "red", size = 3) +
      ggplot2::labs(title = paste("Likelihood '", pos_selfimage, "'"),
                    x = "Date",
                    y = "Likelihood") +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold")
      )
  })

  # Render whitebook data table
  output$whitebook_table <- DT::renderDataTable({
    DT::datatable(whitebook_data)
  })

  # Handle submitted input whitebook
  save_whitebook_entry(input, output, whitebook_data)

  # Handle submitted input likelihood positive self-image
  save_likelihood_selfimage(input, output, likelihood_data)

}
