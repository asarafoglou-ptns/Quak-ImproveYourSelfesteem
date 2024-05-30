#' @title Save Self-Image Likelihood Rating
#'
#' @description This function saves the daily likelihood rating of the user's
#' desired positive self-image to a CSV file and updates the data frame.
#'
#' @param likelihood A numeric value between 0 and 100 that indicates how
#' likely the user thinks their desired positive self-image is to be true.
#' @param file_name A character string representing the name of the csv file
#' where the data should be saved.
#' @return The updated data frame with the new likelihood rating added.
#' @examples
#' # Example usage:
#' updated_data <- save_likelihood_selfimage(75, "selfimage_data.csv")
#' print(updated_data)
#' @export

save_likelihood_selfimage <- function(likelihood,
                                      file_name) {
  # Load existing data if the file exists
  if (file.exists(file_name)) {
    selfimage_data <- readr::read_csv(file_name, show_col_types = FALSE)
  } else {
    selfimage_data <- data.frame(date = as.Date(character()),
                            likelihood_selfimage = numeric(0),
                            stringsAsFactors = FALSE)
  }

  # Ensure the date and likelihood columns are of the correct type
  selfimage_data$date <- as.Date(selfimage_data$date)
  selfimage_data$likelihood_selfimage <- as.numeric(selfimage_data$likelihood_selfimage)

  # Get the current date
  date <- Sys.Date()

  # Check if an entry already exists for the current date
  entry_exists <- nrow(selfimage_data[selfimage_data$date == date, ]) > 0

  if (!entry_exists) {
    # Add submission to data
    row <- data.frame(date = date, likelihood_selfimage = likelihood)

    # Append the new row to the existing selfimage data
    selfimage_data <- dplyr::bind_rows(selfimage_data, row)

    # Write updated data to CSV
    readr::write_csv(selfimage_data, file_name)

    return(list(success = TRUE, data = selfimage_data))
  } else {
    return(list(success = FALSE, message = "You have already submitted an entry
                for today. You can only rate the likeliness of your positive
                self-image once daily."))
  }
}
