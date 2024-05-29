# Function to save self-image likelihood rating and update graph
# Function to save self-image likelihood rating and update graph
save_likelihood_selfimage <- function(input, output, selfimage_data,
                                      pos_selfimage) {
  # Get date
  date <- Sys.Date()

  # Check if an entry already exists for the current date
  entry_exists <- nrow(selfimage_data[selfimage_data$date == date, ]) > 0

  # Get submitted input slider
  shiny::observeEvent(input$save_button2, {
    if (!entry_exists) {
      likelihood <- shiny::isolate(input$slider1)

      # Add submission to data
      row <- data.frame(date = date, likelihood_selfimage = likelihood)

      # Append the new row to the existing selfimage data
      selfimage_data <<- dplyr::bind_rows(selfimage_data, row)

      # Write updated data to CSV
      readr::write_csv(selfimage_data, "selfimage_data.csv")

      # Render updated graph
      output$plot <- shiny::renderPlot({
          ggplot2::ggplot(selfimage_data,
          ggplot2::aes(x = date, y = likelihood_selfimage)) +
          ggplot2::geom_line(color = "#00008B", linewidth = 1) +
          ggplot2::geom_point(color = "#00008B", size = 3) +
          ggplot2::labs(title = paste("Likelihood '", pos_selfimage, "'"),
                        x = "Date",
                        y = "Likelihood") +
          ggplot2::theme_minimal() +
          ggplot2::theme(
            plot.title = ggplot2::element_text(hjust = 0.5, size = 14,
              face = "bold")
          )
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
        "You have already submitted an entry for today. You can only rate the
        likeliness of your positive self-image once daily.",
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
