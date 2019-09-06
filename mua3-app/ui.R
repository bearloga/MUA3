library(shiny)
library(magrittr)

heroes <- readRDS("data/heroes.rds")

ui <- fluidPage(
  titlePanel("Marvel Ultimate Alliance 3 team optimizer"),
  sidebarLayout(
    sidebarPanel(
      helpText("Pick 3"),
      checkboxGroupInput("heroes", "Heroes", choices = heroes, selected = c("Thor", "Iron Man", "Hulk")),
      width = 2
    ),
    mainPanel(
      h2("Recommendations"),
      includeHTML("includes/intro.html"),
      fluidRow(
        column(
          h3("Stat bonus maximization"),
          DT::dataTableOutput("stat_maximizations"),
          includeHTML("includes/stats.html"),
          width = 7
        ),
        column(
          includeHTML("includes/categories.html"),
          tableOutput("recommendations"),
          width = 5
        )
      ),
      includeHTML("includes/footer.html"),
      width = 10
    )
  ),
  theme = shinythemes::shinytheme("cosmo")
)
