library(tidyverse)
library(plotly)
library(shiny)

# d <-  mtcars %>% 
#   rownames_to_column("car")

d <- read.csv("data/questions.csv", row.names="X")


# UI  ----
ui <- fluidPage(plotlyOutput("plot"),
                tableOutput("click"))

# server  ----
server <- function(input, output) {
  output$plot <- renderPlotly({
    
    key <- d$index
    
    p <- d %>% 
      ggplot(aes(x = question, y = question_importance, color=factor(question_type),
                 key = key)) +
      geom_point(size = 4, alpha = 0.7)
    
    ggplotly(p) %>% 
      event_register("plotly_click")
  })
  
  output$click <- renderTable({
    point <- event_data(event = "plotly_click", priority = "event")
    req(point) # to avoid error if no point is clicked
    filter(d, index == point$key) # use the key to find selected point
  })
}

# app ----
shinyApp(ui = ui, server = server)