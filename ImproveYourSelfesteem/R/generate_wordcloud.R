# Function to generate a wordcloud plot
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
