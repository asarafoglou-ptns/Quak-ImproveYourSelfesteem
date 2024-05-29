#' @title run app
#' 
#' @description Run the ImproveYourSelfesteem app 
#' 
#' @examples run_app()
#' 
#' @references De Neef, M. (2022). Negatief zelfbeeld (Revised). Boom. 
#' @references De Neef, M. (z.d.). https://www.negatiefzelfbeeldbehandelen.nl/ 
#' 
#' @export
run_app <- function(){
  shiny::shinyApp(ui = ui, server = server)
}