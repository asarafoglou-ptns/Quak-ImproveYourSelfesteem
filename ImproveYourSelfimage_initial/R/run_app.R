#' @title run app
#' 
#' @description Run the ImproveYourSelfesteem app 
#' 
#' @export
run_app <- function(){
  shiny::shinyApp(ui = ui, server = server)
}