#' @title Function to generate a wordcloud plot
#'
#' @description This function generates a wordcloud plot based on the provided
#' word frequency data.
#'
#' @param wordcloud_data A data frame containing word frequency data
#' with the columns word' and 'freq'.
#' @examples
#' # Example usage:
#' wordcloud_data <- data.frame(
#'   word = c("happy", "joy", "success", "smile", "love"),
#'   freq = c(50, 30, 20, 25, 40)
#' )
#' generate_wordcloud(wordcloud_data)
#' @export

generate_wordcloud <- function(wordcloud_data) {
  colors <- RColorBrewer::brewer.pal(8, "Spectral")

  wordcloud::wordcloud(
    words = wordcloud_data$word,
    freq = wordcloud_data$freq,
    min.freq = 1,
    max.words = 200,
    random.order = FALSE,
    rot.per = 0.35,
    colors = colors
  )
}
