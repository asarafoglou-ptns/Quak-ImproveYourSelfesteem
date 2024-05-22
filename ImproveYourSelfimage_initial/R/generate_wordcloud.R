# Function to generate a wordcloud plot
generate_wordcloud <- function(wordcloud_data) {
  wordcloud::wordcloud(wordcloud_data$word, freq = wordcloud_data$freq,
            random.order=FALSE, colors=RColorBrewer::brewer.pal(8, "Dark2"))
}
