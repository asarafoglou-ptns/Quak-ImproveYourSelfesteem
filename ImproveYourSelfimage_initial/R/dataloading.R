# Function to check for existing data, otherwise it loads default data
dataloading <- function(filename, default_data) {
  if (file.exists(filename)) {
    data <- readr::read_csv(filename, col_types = cols(
      Date = col_character(),
      Event = col_character(),
      Feeling = col_character(),
      Pers_trait = col_character()
    ))
  } else {
    data <- default_data
  }
  return(data)
}

