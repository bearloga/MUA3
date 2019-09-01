library(shiny)
library(magrittr)

source("utils.R")
heroes <- readRDS("data/heroes.rds")
tidy_affiliations <- readRDS("data/tidy_affiliations.rds")
affiliation_bonuses <- readRDS("data/affiliation_bonuses.rds")

ui <- fluidPage(
    titlePanel("Marvel Ultimate Alliance 3 team optimizer"),
    sidebarLayout(
        sidebarPanel(
            helpText("Pick 3"),
            checkboxGroupInput("heroes", "Heroes", choices = heroes),
            width = 2
        ),
        mainPanel(
            h2("Recommended 4th"),
            fluidRow(
                column(DT::dataTableOutput("stat_maximizations"), width = 6),
                column(
                    includeHTML("includes/stats.html"),
                    tableOutput("recommendations"),
                    width = 6
                )
            ),
            includeMarkdown("includes/footer.md"),
            width = 10
        )
    ),
    theme = shinythemes::shinytheme("cosmo")
)

server <- function(input, output) {

    recs <- reactiveVal()

    observeEvent(input$heroes, {
        if (length(input$heroes) == 3) {
            recs(produce_recommendations(input$heroes))
        } else {
            recs(NULL)
        }
    })

    output$stat_maximizations <- DT::renderDataTable({
        req(recs())
        DT::datatable(recs()$maximizations)
    })
    output$recommendations <- renderTable({
        req(recs())
        recs()$table
    })
}
shinyApp(ui = ui, server = server)
