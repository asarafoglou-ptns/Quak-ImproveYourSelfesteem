dataloading <- function(file_path, default_data) {
  if (file.exists(file_path)) {
    readr::read_csv(file_path, show_col_types = FALSE)
  } else {
    default_data
  }
}
