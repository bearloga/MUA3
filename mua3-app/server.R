library(shiny)
library(magrittr)

source("utils.R", local = TRUE)
heroes <- readRDS("data/heroes.rds")
tidy_affiliations <- readRDS("data/tidy_affiliations.rds")
affiliation_bonuses <- readRDS("data/affiliation_bonuses.rds")

server <- function(input, output) {

  recommendations <- reactiveVal()

  observeEvent(input$heroes, {
    if (length(input$heroes) == 3) {
      recommendations(produce_recommendations(input$heroes))
    } else {
      recommendations(NULL)
    }
  })

  output$stat_maximizations <- DT::renderDataTable({
    req(recommendations)
    recs <- recommendations()$maximizations
    recs %>%
      dplyr::mutate_if(is.numeric, ~ ifelse(.x == 0, "", paste0("+", .x, "%"))) %>%
      DT::datatable(
        options = list(
          pageLength = 5,
          lengthMenu = c(5, 10, 15)
        )
      )
  })
  output$recommendations <- renderTable({
    req(recommendations)
    recommendations()$table
  })
}
