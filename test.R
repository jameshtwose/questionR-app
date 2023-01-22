library(shiny)
library(plotly)
library(htmlwidgets)

ui <- fluidPage(
  plotlyOutput("plot")
)


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
      {'marker':{color: colors}},
      [data.points[0].curveNumber]
    );
  });
}
"

server <- function(input, output, session) {
  
  nms <- row.names(mtcars)
  
  output$plot <- renderPlotly({
    p <- ggplot(mtcars, aes(x = mpg, y = wt, key = nms)) + 
      geom_point()
    ggplotly(p) %>% onRender(javascript)
    
  })
}

shinyApp(ui, server)