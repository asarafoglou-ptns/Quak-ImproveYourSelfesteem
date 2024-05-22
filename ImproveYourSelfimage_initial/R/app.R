library(shiny)
library(wordcloud)
library(dplyr)
library(markdown)
library(readr)
library(RColorBrewer)
library(DT)
library(shinythemes)

ui <- shiny::fluidPage(theme = bs_theme(version = 5, bootswatch = "morph"),
  shiny::titlePanel("Improve your self-image"),
  includeCSS("styles.css"),
  tabsetPanel(
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
    DT::dataTableOutput("whitebook_table")
    ),
  
  # Wordcloud of positive traits tab
  shiny::tabPanel("Positive trait wordcloud",
    # Explanation wordcloud
    shiny::p("This is a wordcloud of all the positive traits you have entered in
      your whitebook. Bigger words indicate that you have entered the positive
      trait more often. Do you think these traits might describe you?"),
    # Show wordcloud
    shiny::plotOutput("wordcloud"))
  )
)

server <- function(input, output, session) {
  # Load background wordcloud function
  source("R/generate_wordcloud.R")
  source("R/dataloading.R")
  
  # Read the content of the introduction text file
  introduction_text <- readr::read_file("R/introduction.md")
  
  # Check if first loading app
  shiny::observe({
    if (!file.exists("pos_selfimage.txt")) {
      
      # Show welcome screen to first time users
      shiny::showModal(shiny::modalDialog(
        title = "Welcome!",
        HTML(markdown::markdownToHTML(introduction_text, template = FALSE)),
        easyClose = FALSE,
        footer = shiny::actionButton("ok", "ok")
      ))
    }
  })
  
  # Ask first time user for negative self-image
  shiny::observeEvent(input$ok, {
    shiny::showModal(shiny::modalDialog(
      title = "Welcome!",
      shiny::textInput("neg_selfimage", 
                       "The first step is to describe your current negative 
                       self-image. A negative self-image is a general, 
                       negative statement about yourself starting with I, 
                       for example 'I am not good enough'. How would you 
                       describe your current negative self-image?"),
      easyClose = FALSE,
      footer = shiny::actionButton("ok2", "ok")
    ))
  })
  
  # Trigger next pop up window
  shiny::observeEvent(input$ok2, {
    neg_selfimage <- shiny::isolate(input$neg_selfimage)
    
    # Add negative self-image to txt file
    if (nchar(neg_selfimage) > 0){
      readr::write_lines(neg_selfimage, "neg_selfimage.txt")
      
      # Ask first time user to define desired positive self-image
      shiny::showModal(shiny::modalDialog(
        title = "Welcome!",
        shiny::textInput("pos_selfimage", 
                         "The next step is to define the positive self-image
                         you want to strive towards. This is a positive general
                         statement about yourself. It's easiest to think about
                         the negative self-image you just formulated and rewrite
                         it to a positive statment. For example, 'I am 
                         worthless' becomes 'I am worthwhile'."),
        easyClose = FALSE,
        footer = shiny::actionButton("ok3", "ok")
      ))
    }
  })
  
  # Handle the submission of the positive self-image
  shiny::observeEvent(input$ok3, {
    pos_selfimage <- isolate(input$pos_selfimage)
    if (nchar(pos_selfimage) > 0) {
      readr::write_lines(pos_selfimage, "pos_selfimage.txt")
      removeModal()
    }
  })
  
  # Render the introduction text
  output$introduction <- shiny::renderUI({
    shiny::HTML(markdown::markdownToHTML(introduction_text, template = FALSE))
  })
  
  # Create empty data frames for if data does not exist
  default_whitebook_data <- data.frame(Event = character(0),
                                       Pers_trait = character(0),
                                       stringsAsFactors = FALSE)
  
  default_wordcloud_data <- data.frame(word = character(0),
                                       freq = numeric(0),
                                       stringsAsFactors = FALSE)
  
  # Load data if it exists, otherwise load default data
  whitebook_data <- dataloading("whitebook_data.csv", default_whitebook_data)
  wordcloud_data <- dataloading("wordcloud_data.csv", default_wordcloud_data)
  
  # Render wordcloud
  output$wordcloud <- shiny::renderPlot({
    if (nrow(wordcloud_data) > 0) {
      generate_wordcloud(wordcloud_data)
    }
  })
  
  # Render whitebook data table
  output$whitebook_table <- DT::renderDataTable({
    DT::datatable(whitebook_data)
  })
  
  # Get submitted input whitebook
  shiny::observeEvent(input$save_button, {
    q1 <- shiny::isolate(input$q1_input)
    q2 <- shiny::isolate(input$q2_input)
    q3 <- shiny::isolate(input$q3_input)
    
    # Check if all three questions are answered
    if (nchar(q1) > 0 & nchar(q2) > 0 & nchar(q3) > 0) {
      
      # Add submission to whitebook
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
      
      # Render whitebook data table
      output$whitebook_table <- DT::renderDataTable({
        DT::datatable(whitebook_data)
      })
      
      # Show message that answers have been submitted
      shiny::showModal(shiny::modalDialog(
        title = "Submitted",
        easyClose = TRUE,
        footer = shiny::actionButton("ok_submit", "ok")
      ))
      
      # Close modal when ok button is pressed
      shiny::observeEvent(input$ok_submit, {
        shiny::removeModal()
      })
      
    } else {
      # Show message when not all three questions have been answered
      shiny::showModal(shiny::modalDialog(
        title = "Answer all three questions",
        easyClose = TRUE,
        footer = shiny::actionButton("ok4", "ok")
      ))
      
      # Close modal when the ok button is pressed
      shiny::observeEvent(input$ok4, {
        shiny::removeModal()
      })
    }
  })
}
