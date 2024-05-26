# Function that saves whitebook entry and updates wordcloud and table
save_whitebook_entry <- function(input, output, whitebook_data) {
  date_char <- as.character(Sys.Date())

  # Get submitted input whitebook
  shiny::observeEvent(input$save_button, {
    q1 <- shiny::isolate(input$q1_input)
    q2 <- shiny::isolate(input$q2_input)
    q3 <- shiny::isolate(input$q3_input)

    # Check if all three questions are answered
    if (nchar(q1) > 0 & nchar(q2) > 0 & nchar(q3) > 0) {

      # Add answers to new row
      row <- data.frame(Date = date_char,
                        Event = q1,
                        Feeling = q2,
                        Pers_trait = q3,
                        stringsAsFactors = FALSE)

      # Append the new row to the existing whitebook data
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

      # Render updated whitebook data table
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
