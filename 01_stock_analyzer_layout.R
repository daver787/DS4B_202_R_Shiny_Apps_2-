# BUSINESS SCIENCE ----
# DS4B 202-R ----
# STOCK ANALYZER APP - LAYOUT -----
# Version 1

# APPLICATION DESCRIPTION ----
# - Create a basic layout in shiny showing the stock dropdown, interactive plot and commentary


# LIBRARIES ----
library(shiny)
library(shinyWidgets)

library(plotly)
library(tidyquant)
library(tidyverse)

source(file = "00_scripts/stock_analysis_functions.R")
stock_list_tbl <- get_stock_list("SP500")





# UI ----
ui <- fluidPage(
    title = "Stock Analyzer",
    
    #1.0 HEADER ----
    div(
        h1("Stock Analyzer", "by Business Science"),
        p("This is the first mini-project completed in our", "Expert Shiny Application Course (DS4B 202-R)")
    ),
    
    # 2.0 APPLICATION UI ----
    div(
       column(
           width = 4,
           wellPanel(
               pickerInput(inputId  = "stock_selection",
                           label    = "Stock List (Pick One to Analyze)", 
                           choices  = stock_list_tbl$label,
                           multiple = FALSE,
                           selected = stock_list_tbl %>% filter(label %>% str_detect("AAPL")) %>% pull(label),
                           options  = pickerOptions(
                               actionsBox = FALSE,
                               liveSearch = TRUE,
                               size       = 10 
                           ) 
                           ),
               actionButton(inputId = "analyze", label = "Analyze", icon = icon("download"))
           )
          
          ),
       
       column(width = 8, "Plot")
    )
    
    )

# SERVER ----
server <- function(input, output, session){
    
}
# RUN APP ----
shinyApp(ui = ui, server = server)
