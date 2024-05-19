# Function
dataloading <- function(filename, default_data) {
  if (!file.exists(filename)) {
    showModal(modalDialog(h2("Introduction"), "Try Harder"))
    write.csv(default_data, filename, row.names = FALSE)
  } else {
    data <- tryCatch(
      read.csv(filename, stringsAsFactors = FALSE)
    )
    return(data)
  }
}
