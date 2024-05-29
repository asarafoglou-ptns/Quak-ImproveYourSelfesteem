# Function checks if user is first using app,
# If so, it shows an introduction and asks the user
# to define their current negative self-image and their
# desired positive self-image

first_use_app <- function(input, output, introduction_text) {
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
}