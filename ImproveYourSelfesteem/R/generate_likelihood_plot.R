# Function to generate likelihood plot
generate_likelihood_plot <- function(selfimage_data, pos_selfimage) {
  shiny::renderPlot({
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
  })
}
