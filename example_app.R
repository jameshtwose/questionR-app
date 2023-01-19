library(tidyverse)
library(lubridate)
library(shiny)
library(DT)
library(shinythemes)

ui<-navbarPage("Planifier les cultures",
               theme = shinytheme("sandstone"),
               tabPanel(
                 "Cultures",
                 sidebarLayout(
                   sidebarPanel(width = 3,
                                inputPanel(
                                  selectInput("Species", label = "Choisir l'espèces",
                                              choices = levels(as.factor(iris$Species)))
                                )),
                   mainPanel(DTOutput("iris_datatable"),
                             hr(),
                             plotOutput("iris_plot"))
                 )
               ),
               tabPanel("Fertilisation"),
               tabPanel("Analyse de sol")
)


server <- function(input, output, session) {
  my_iris <- reactiveValues(df=iris,sub=NULL, sub1=NULL)
  
  observeEvent(input$Species, {
    my_iris$sub <- my_iris$df %>% filter(Species==input$Species)
    my_iris$sub1 <- my_iris$df %>% filter(Species!=input$Species)
  }, ignoreNULL = FALSE)
  
  output$iris_datatable <- renderDT({
    n <- length(names(my_iris$sub))
    DT::datatable(my_iris$sub,
                  options = list(pageLength = 10),
                  selection='none', editable= list(target = 'cell'), 
                  rownames= FALSE)
  })
  
  observeEvent(input$iris_datatable_cell_edit,{
    edit <- input$iris_datatable_cell_edit # just to simplify typing, can keep long form for later
    print(edit) # debugging, remove in prod
    str(edit)
    i <- edit$row
    j <- edit$col + 1
    v <- edit$value
    
    my_iris$sub[i, j] <<- DT::coerceValue(v, my_iris$sub[i, j])  ## editing changes in the displayed dataset
    
    my_iris$df <<- rbind(my_iris$sub1,my_iris$sub)  ## reflecting changes in the original dataset
  })
  
  output$iris_plot <- renderPlot({
    my_iris$sub %>%
      select(Sepal.Length, Petal.Length) %>% 
      mutate(Sepal.Length=as.numeric(Sepal.Length),
             Petal.Length=as.numeric(Petal.Length)) %>%
      pivot_longer(cols=Sepal.Length:Petal.Length, names_to = "type", values_to = "valeur") %>%
      group_by(type) %>%
      summarize(somme=sum(valeur, na.rm=TRUE))%>%
      ungroup() %>% 
      ggplot(aes(x = type, y = as.numeric(somme))) + # I'm casting to numeric here because edit$value returns as a character, so need to coerce to number otherwise plots funny.
      geom_point(size=3)
  })
}
shinyApp(ui, server)