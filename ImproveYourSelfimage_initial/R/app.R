library(shiny)
library(wordcloud)
library(dplyr)
library(markdown)
library(readr)

ui <- shiny::navbarPage("Improve your self-image",
  shiny::tabPanel("Introduction",
    shiny::uiOutput("introduction")
  ),
  shiny::tabPanel("Whitebook",
    shiny::p("Describe what went well today, how it made you feel, and what 
      these events tell you about yourself. It's okay to repeat positive events,
      feelings, or positive traits."),
    shiny::textInput("q1_input", "Describe something that went well/you did
      well today. Anything goes, big or small."),
    shiny::textInput("q2_input", "How did the event make you feel?"),
    shiny::textInput("q3_input", "What does the event say about you?
      which positive trait is evident from this event? If there is more
      than one positive trait that you can think of, enter the first trait,
      click submit, fill in the second trait, submit, and
      so on."),
    shiny::actionButton("save_button", "Submit")
    ),
    shiny::tabPanel("Positive trait wordcloud",
    shiny::p("This is a wordcloud of all the positive traits you have entered in
      your whitebook. Bigger words indicate that you have entered the positive
      trait more often. Do you think these traits might describe you?"),
                                        shiny::plotOutput("wordcloud")
    )
)

server <- function(input, output, session) {
  source("R/generate_wordcloud.R")
  first_time <- shiny::reactiveValues(loaded = TRUE)
  
  # Show welcome screen only during first loading app
  shiny::observe({
    if (first_time$loaded) {
      shiny::showModal(shiny::modalDialog(
        title = "Welcome!",
        shiny::textInput("neg_selfimage", "Describe your negative self-image"),
        easyClose = TRUE,
        footer = shiny::actionButton("ok", "ok")
      ))
      first_time$loaded <- FALSE
    }
  })
  
  # Read the content of the introduction file
  introduction_text <- readr::read_file("R/introduction.md")
  
  # Render the introduction text using Markdown
  output$introduction <- shiny::renderUI({
    shiny::HTML(markdown::markdownToHTML(introduction_text))
  })
  
  # Check if data files exist (i.e. if first time starting app)
  if (!file.exists("whitebook_data.csv")) {
    whitebook_data <- data.frame(Event = character(0),
                                 Pers_trait = character(0),
                                 stringsAsFactors = FALSE)
    readr::write_csv(whitebook_data, "whitebook_data.csv")
  }
  
  if (!file.exists("wordcloud_data.csv")) {
    wordcloud_data <- data.frame(word = character(0),
                                 freq = numeric(0),
                                 stringsAsFactors = FALSE)
    readr::write_csv(wordcloud_data, "wordcloud_data.csv")
  }
  
  # Load existing text data from CSV file
  whitebook_data <- readr::read_csv("whitebook_data.csv", col_types = readr::cols())
  wordcloud_data <- readr::read_csv("wordcloud_data.csv", col_types = readr::cols())
  
  # Render wordcloud
  output$wordcloud <- shiny::renderPlot({
    if (nrow(wordcloud_data) > 0) {
      generate_wordcloud(wordcloud_data)
    }
  })
  
  # Get submitted input whitebook
  shiny::observeEvent(input$save_button, {
    q1 <- shiny::isolate(input$q1_input)
    q2 <- shiny::isolate(input$q2_input)
    q3 <- shiny::isolate(input$q3_input)
    
    # Add submission to whitebook data
    if (nchar(q1) > 0 | nchar(q2) > 0 | nchar(q3) > 0) {
      row <- data.frame(Event = q1, Feeling = q2, Pers_trait = q3,
                        stringsAsFactors = FALSE)
      whitebook_data <<- dplyr::bind_rows(whitebook_data, row)
      readr::write_csv(whitebook_data, "whitebook_data.csv")
      
      # Update wordcloud data based on whitebook data
      word_counts <- dplyr::count(whitebook_data, Pers_trait)
      wordcloud_data <<- as.data.frame(word_counts)
      colnames(wordcloud_data) <- c("word", "freq")
      readr::write_csv(wordcloud_data, "wordcloud_data.csv")
      
      # Render updated wordcloud
      output$wordcloud <- shiny::renderPlot({
        generate_wordcloud(wordcloud_data)
      })
    }
  })
}

shiny::shinyApp(ui = ui, server = server)
