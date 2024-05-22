# server_functions.R
save_whitebook_entry <- function(input, output, session, whitebook_data) {
  observeEvent(input$save_button, {
    # Retrieve input values from text inputs
    q1 <- input$q1_input
    q2 <- input$q2_input
    q3 <- input$q3_input
    
    # Check if all required fields are filled
    if (nchar(q1) > 0 & nchar(q2) > 0 & nchar(q3) > 0) {
      # Perform any necessary data processing or validation
      
      # Update the whitebook data with the submitted values
      row <- data.frame(Event = q1, Feeling = q2, Pers_trait = q3,
                        stringsAsFactors = FALSE)
      # Append the new row to the existing whitebook data
      whitebook_data <<- dplyr::bind_rows(whitebook_data, row)
      
      # Write the updated whitebook data to a CSV file
      readr::write_csv(whitebook_data, "whitebook_data.csv")
      
      # Optionally, perform additional actions such as updating plots or UI elements
      
      # Show a modal dialog to indicate successful submission
      showModal(modalDialog(
        title = "Submission Successful",
        "Your entry has been saved successfully.",
        footer = actionButton("ok_submit", "OK")
      ))
      
    } else {
      # Show a modal dialog to prompt the user to fill in all required fields
      showModal(modalDialog(
        title = "Error",
        "Please fill in all required fields.",
        footer = actionButton("ok_error", "OK")
      ))
    }
  })
}
