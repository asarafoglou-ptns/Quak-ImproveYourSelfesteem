# Function to check for existing data, otherwise it loads default data
dataloading <- function(filename, default_data) {
  if (file.exists(filename)) {
    data <- readr::read_csv(filename, col_types = readr::cols(
      Date = readr::col_character(),
      Event = readr::col_character(),
      Feeling = readr::col_character(),
      Pers_trait = readr::col_character()
    ))
  } else {
    data <- default_data
  }
  return(data)
}

