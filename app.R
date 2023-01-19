library(tidyverse)
library(plotly)
library(shiny)
library(dotenv)
library(DBI)

load_dot_env(file = ".env")

con <- dbConnect(RPostgres::Postgres(),
                 host = Sys.getenv("POSTGRESQL_ADDON_HOST"),
                 dbname = Sys.getenv("POSTGRESQL_ADDON_DB"),
                 port = 5432,
                 user = Sys.getenv("POSTGRESQL_ADDON_USER"),
                 password = Sys.getenv("POSTGRESQL_ADDON_PASSWORD"))

# d <-  mtcars %>% 
#   rownames_to_column("car")

# d <- read.csv("data/questions.csv", row.names="X")

d <- dbGetQuery(con, "SELECT * FROM questions_db")

dbDisconnect(con)

d$index <- as.numeric(d$index)
d$question_importance <- as.numeric(d$question_importance)


# UI  ----
ui <- fluidPage(
  includeCSS("www/custom.css"),
  includeCSS("https://fonts.googleapis.com/css2?family=Raleway:wght@400&display=swap"),
  titlePanel(div(a(href='https://services.jms.rocks',
                                 img(src='https://services.jms.rocks/img/logo.png',
                               style="width: 50px;")), 
                           "A Question Selector App"),
             windowTitle = "A Question Selector App"),
  plotlyOutput("plot"),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  tableOutput("click"),
  hr(),
  div(
    class = "footer",
    includeHTML("www/footer.html")
    )
  )

# server  ----
server <- function(input, output) {
  
  
  output$plot <- renderPlotly({
    
    key <- d$index
    
    p <- d %>% 
      ggplot(aes(x = question_importance, y = question, color=factor(question_type),
                 key = key)) +
      geom_point(size = 4, alpha = 0.7) +
      scale_color_manual(values=c("#999999", "#fcdd14", "#8f0fd4")) + 
      theme(plot.title = element_text(hjust = 0.5, color="white"),
            axis.title.x = element_text(size = 14, color="white"),
            axis.title.y = element_text(size = 14, color="white"),
            axis.text.x = element_text(color="white"),
            axis.text.y = element_text(color="white"),
            plot.tag.position = c(0.15, 0.02),
            panel.background = element_rect(fill = "#333333"),
            plot.background = element_rect(fill = "#333333"),
            panel.grid.major = element_line(color = "grey30", size = 0.2),
            legend.background = element_blank(),
            legend.text = element_text(color="white"),
            legend.title = element_text(color="white")
      )
    
    ggplotly(p, height=500) %>% 
      event_register("plotly_click") %>% 
      layout(margin = list(l = 100,
                           r = 100,
                           b = 100,
                           t = 50,
                           pad = 1))
  })
  
  output$click <- renderTable({
    point <- event_data(event = "plotly_click", priority = "event")
    req(point) # to avoid error if no point is clicked
    filter(d, index == point$key) # use the key to find selected point
  })
}

# app ----
shinyApp(ui = ui, server = server)