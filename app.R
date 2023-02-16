library(tidyverse)
library(plotly)
library(shiny)
library(dotenv)
library(DBI)
library(htmlwidgets)

javascript <- "
function(el, x){
  el.on('plotly_click', function(data) {
    var colors = [];
    // check if color is a string or array
    if(typeof data.points[0].data.marker.color == 'string'){
      for (var i = 0; i < data.points[0].data.marker.color.length; i++) {
        colors.push(data.points[0].data.marker.color);
      }
    } else {
      colors = data.points[0].data.marker.color;
    }
    // some debugging
    //console.log(data.points[0].data.marker.color)
    //console.log(colors)

    // set color of selected point
    colors[data.points[0].pointNumber] = '#fcdd14';
    Plotly.restyle(el,
      {'marker':{color: colors, size: 17, alpha: 0.7}},
      [data.points[0].curveNumber]
    );
  });
}
"

load_dot_env(file = ".env")

con <- dbConnect(RPostgres::Postgres(),
                 host = Sys.getenv("POSTGRESQL_ADDON_HOST"),
                 dbname = Sys.getenv("POSTGRESQL_ADDON_DB"),
                 port = 5432,
                 user = Sys.getenv("POSTGRESQL_ADDON_USER"),
                 password = Sys.getenv("POSTGRESQL_ADDON_PASSWORD"))

d <- dbGetQuery(con, "SELECT * FROM questions_db")

dbDisconnect(con)

d$index <- as.numeric(d$index)
d$strength <- as.numeric(d$strength)
d$opportunity <- as.numeric(d$opportunity)
d$votes <- as.numeric(d$votes)


# UI  ----
ui <- fluidPage(
  includeCSS("www/custom.css"),
  includeCSS("https://fonts.googleapis.com/css2?family=Raleway:wght@400&display=swap"),
  titlePanel(div(a(href='https://services.jms.rocks',
                                 img(src='https://services.jms.rocks/img/logo.png',
                               style="width: 50px;")), 
                           "Narratives Selector App"),
             windowTitle = "Narratives Selector App"),
  h3("Valitse mielestäsi tärkeimpiä vastauksia klikkaamalla pisteitä kuvaajasta!"),
  p("Kun viet kursorin pisteen ylle, näet sen sisältämän vastauksen. Kun klikkaat pistettä,
    valintasi rekisteröityy ja piste vaihtaa väriä."),
  plotlyOutput("plot"),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
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
    
    p <- ggplot(d,
                aes(x = strength,
                    y = opportunity,
                    key = key,
                    text = paste(narrativeTitle,
                                 "<br><br>", narrative))) +
      geom_point(size = 4, alpha = 0.7) +
      labs(x = "&#8592; Heikkouksia | Vahvuuksia &#8594;",
           y = "&#8592; Uhkia | Mahdollisuuksia &#8594;") +
      theme(plot.title = element_text(hjust = 0.5, color="white"),
            axis.title.x = element_text(size = 14, color="white"),
            axis.title.y = element_text(size = 14, color="white"),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            plot.tag.position = c(0.15, 0.02),
            panel.background = element_rect(fill = "#333333"),
            plot.background = element_rect(fill = "#333333"),
            panel.grid.major = element_line(color = "grey30", size = 0.2),
            legend.background = element_blank(),
            legend.text = element_text(color="white"),
            legend.title = element_text(color="white")
      )
    
    ggplotly(p, height=650, tooltip = "text") %>% 
      event_register("plotly_click") %>% 
      layout(margin = list(l = 100,
                           r = 100,
                           b = 100,
                           t = 50,
                           pad = 1)) %>% 
    onRender(javascript)
  })
  

  
  output$click <- renderTable({
    point <- event_data(event = "plotly_click", priority = "event")
    selected_value <- d[d$index==as.numeric(point$key), "votes"]
    update_value <- if (is.null(point)) selected_value else selected_value + 1
    insert_statement <- paste0("UPDATE questions_db SET votes = ",
                               update_value,
                               " WHERE index = ", point$key, ";")
    print(insert_statement)
    ## Update value in a row
    con <- dbConnect(RPostgres::Postgres(),
                     host = Sys.getenv("POSTGRESQL_ADDON_HOST"),
                     dbname = Sys.getenv("POSTGRESQL_ADDON_DB"),
                     port = 5432,
                     user = Sys.getenv("POSTGRESQL_ADDON_USER"),
                     password = Sys.getenv("POSTGRESQL_ADDON_PASSWORD"))
    
    if (is.null(point)) "don't execute" else dbExecute(con, insert_statement)
    
    dbDisconnect(con)

    req(point) # to avoid error if no point is clicked
    filter(d[, c("index", "votes", "narrativeTitle", "narrative")], index == point$key) # use the key to find selected point
  })
  

}


# app ----
shinyApp(ui = ui, server = server)