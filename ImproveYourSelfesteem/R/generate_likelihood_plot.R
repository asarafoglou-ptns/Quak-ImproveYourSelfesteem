#' @title Generate Likelihood Plot
#'
#' @description This function generates a plot charting how the belief in/
#' perceived likeliness of a user's desired positive self-image has changed
#' over time.
#'
#' @param selfimage_data A data frame containing the self-image data with
#' columns 'date' and 'likelihood_selfimage'.
#' @param pos_selfimage A character string representing the positive self-image
#' description.
#' @return A ggplot.
#' @examples
#' # Example data
#' selfimage_data <- data.frame(
#'   date = as.Date(c('2024-01-01', '2024-01-02', '2024-01-03')),
#'   likelihood_selfimage = c(50, 75, 95)
#' )
#' pos_selfimage <- "I am confident"
#'
#' # Generate and print the plot
#' plot <- generate_likelihood_plot(selfimage_data, pos_selfimage)
#' print(plot)
#' @export
generate_likelihood_plot <- function(selfimage_data, pos_selfimage) {
  ggplot2::ggplot(selfimage_data,
                  ggplot2::aes(x = date, y = likelihood_selfimage)) +
  ggplot2::geom_line(color = "#00008B", linewidth = 1) +
  ggplot2::geom_point(color = "#00008B", size = 3) +
  ggplot2::labs(title = paste("Likelihood '", pos_selfimage, "'"),
                x = "Date",
                y = "Likelihood") +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      hjust = 0.5,
      size = 14,
      face = "bold")
  )
}
