# Function to save self-image likelihood rating and update graph
save_likelihood_selfimage <- function(input, output, selfimage_data) {
  
  # Get date
  date <- Sys.Date()
  
  # Get submitted input slider
  shiny::observeEvent(input$save_button2, {
    likelihood <- shiny::isolate(input$slider1)
    
    # Add submission to data
    row <- data.frame(date = date, likelihood_selfimage = likelihood)
    
    # Append the new row to the existing selfimage data
    selfimage_data <<- dplyr::bind_rows(selfimage_data, row)
    
    # Write updated data to CSV
    readr::write_csv(selfimage_data, "selfimage_data.csv")
    
    # Render updated graph
    output$plot <- shiny::renderPlot({
      ggplot2::ggplot(selfimage_data, ggplot2::aes(x = date, y = likelihood_selfimage)) +
        ggplot2::geom_line(color = "blue", size = 1) +  # Customize line color and size
        ggplot2::geom_point(color = "red", size = 3) +  # Customize point color and size
        ggplot2::labs(title = paste("Likelihood ", pos_selfimage),
                      x = "Date",
                      y = "Likelihood") +
        ggplot2::theme_minimal() +  # Use a minimal theme for a clean look
        ggplot2::theme(
          plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold")  # Center and bold title
        )
    })
    
    # Show message that answers have been submitted
    shiny::showModal(shiny::modalDialog(
      title = "Submitted",
      easyClose = TRUE,
      footer = shiny::actionButton("ok_submit2", "ok")
    ))
    
    # Close modal when ok button is pressed
    shiny::observeEvent(input$ok_submit2, {
      shiny::removeModal()
    })
  })
}
