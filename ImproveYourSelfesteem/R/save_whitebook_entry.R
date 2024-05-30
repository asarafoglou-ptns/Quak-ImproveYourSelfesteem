#' Save Whitebook Entry
#'
#' This function saves an entry to the whitebook and updates the data frame.
#'
#' @param whitebook_file A character string with the name of the CSV file
#' of the whitebook data
#' @param event A character string with the positive event.
#' @param feeling A character string with the feeling associated with the event.
#' @param pers_trait A character string with the positive personality trait that
#' can be associated with the positive event
#' @param wordcloud_file A character string with the name of the CSV file
#' of the wordcloud data
#' @return A list containing the updated whitebook data frame and wordcloud data frame.
#' @export
#' @examples
#' # Example usage:
#' updated_data <- save_whitebook_entry("whitebook_data.csv", "Did the dishes", "Proud", "Determined", "wordcloud_data.csv")
#' print(updated_data)

save_whitebook_entry <- function(whitebook_file, event, feeling, pers_trait, wordcloud_file) {
  # Read existing whitebook data
  if (file.exists(whitebook_file)) {
    whitebook_data <- readr::read_csv(whitebook_file,
                                      show_col_types = FALSE,
                                      col_types = readr::cols(
                                        Date = readr::col_character(),
                                        Event = readr::col_character(),
                                        Feeling = readr::col_character(),
                                        Pers_trait = readr::col_character()
                                      ))
  } else {
    whitebook_data <- data.frame(Date = character(),
                                 Event = character(),
                                 Feeling = character(),
                                 Pers_trait = character(),
                                 stringsAsFactors = FALSE)
  }

  # Read existing wordcloud data
  if (file.exists(wordcloud_file)) {
    wordcloud_data <- readr::read_csv(wordcloud_file, show_col_types = FALSE)
  } else {
    wordcloud_data <- data.frame(word = character(0),
                                 freq = numeric(0),
                                 stringsAsFactors = FALSE)
  }

  # Check if all three questions are answered
  if (nchar(event) > 0 & nchar(feeling) > 0 & nchar(pers_trait) > 0) {
    # Add submission to data
    row <- data.frame(Date = as.character(Sys.Date()),
                      Event = event,
                      Feeling = feeling,
                      Pers_trait = pers_trait,
                      stringsAsFactors = FALSE)

    # Append the new row to the existing whitebook data
    whitebook_data <- dplyr::bind_rows(whitebook_data, row)

    # Write updated whitebook data to CSV
    readr::write_csv(whitebook_data, whitebook_file)

    # Update wordcloud data based on whitebook data
    word_counts <- dplyr::count(whitebook_data, Pers_trait)
    wordcloud_data <- as.data.frame(word_counts)
    colnames(wordcloud_data) <- c("word", "freq")
    readr::write_csv(wordcloud_data, wordcloud_file)

    # Return updated whitebook and wordcloud data frames with success flag
    list(success = TRUE, whitebook_data = whitebook_data,
         wordcloud_data = wordcloud_data)
  } else {
    # Return error message if not all three questions are answered
    list(success = FALSE, message = "Answer all three questions.")
  }
}
