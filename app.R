## Rshiny tutorial, Caroline Cappello, Spring 2021

#### THE BASIC STEPS ####

# Create the user interface:
#ui <- fluidPage()

# Create the server function:
#server <- function(input, output) {}

# Combine them into an app:
#shinyApp(ui = ui, server = server)

#### WORKED EXAMPLE ####

# load packages
library(tidyverse); library(shiny); library(shinythemes)

# import data
hw <- read_csv("halloween_data.csv")

# Create the user interface:
ui <- fluidPage(
  theme = shinytheme("slate"),
  titlePanel("Shiny Halloween!"),
  sidebarLayout(
    sidebarPanel("put my widgets here",
                 # Add your first widget in the side panel
                 selectInput(inputId = "state_select",
                             label = "Choose a state",
                             choices = unique(hw$state)
                ),
                # Add another widget to add a graph of top costumes by region_us_census
                radioButtons(inputId = "region_select",
                             label = "Choose region:",
                             choices = unique(hw$region_us_census))
    ),
    mainPanel("put my outputs here",
              # add output table from server to UI
              p("State's top candies:"),
              tableOutput(outputId = "candy_table"),
              # add output graph from server to UI
              p("Region’s top costumes:"),
              plotOutput(outputId = "costume_graph"))
  )
)

# Create the server function:
server <- function(input, output) {
  # Build a reactive subset in the server, based on selections made in the ‘state’ widget
  state_candy <- reactive({
    hw %>%
      filter(state == input$state_select) %>%
      select(candy, pounds_candy_sold)
  })

  # Make the reactive table from state_candy subset
  output$candy_table <- renderTable({
    state_candy()
  })

  # Make the reactive subset based on the region_select input
  region_costume <- reactive({
    hw %>%
      filter(region_us_census == input$region_select) %>%
      count(costume, rank)
  })

  # Make the reactive graph from region_select subset
  output$costume_graph <- renderPlot({
    ggplot(region_costume(), aes(x = costume, y = n)) +
      geom_col(aes(fill = rank)) +
      coord_flip() +
      scale_fill_manual(values = c("black","purple","orange")) +
      theme_minimal()
  })


}

# Combine them into an app:
shinyApp(ui = ui, server = server)


