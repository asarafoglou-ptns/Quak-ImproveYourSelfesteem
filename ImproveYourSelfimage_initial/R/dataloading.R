# Function to check for existing data, otherwise it loads default data
dataloading <- function(filename, default_data) {
  if (!file.exists(filename)) {
    readr::write_csv(default_data, filename)
    return(default_data)
  } else {
    data <- readr::read_csv(filename, col_types = readr::cols())
    return(data)
  }
}

