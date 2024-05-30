#' @title Run App
#'
#' @description Starts up the shiny ImproveYourSelfesteem app. An R shiny app
#' for users with low self-esteem based on the
#' treatment for negative self-image by Manja de Neef (2022;
#' negatiefzelfbeeldbehandelen.nl). To improve self-esteem, users are asked
#' to log their positive experiences/things they did well that day in a
#' whitebook as well as define the positive self-image they want to strive
#' for and give weekly ratings about how likely they think their defined
#' positive self-image is to be true.
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
