# BUSINESS SCIENCE ----
# DS4B 202-R ----
# STOCK ANALYZER APP - FAVORITE CARD ANALYSIS -----
# Version 1

# APPLICATION DESCRIPTION ----
# - The user will select 1 stock from the SP 500 stock index
# - [DONE] The functionality is designed to pull the past 180 days of stock data 
# - We will conver the historic data to 2 moving averages - short (fast) and long (slow)
# - We will make a function to generate the moving average cards

# SETUP ----
library(tidyquant)
library(tidyverse)
library(shiny)

source("00_scripts/stock_analysis_functions.R")
source("00_scripts/info_card.R")


stock_list_tbl <- get_stock_list("SP500")

favorite_list_on_start <- c("AAPL", "GOOG", "NFLX")

# 1.0 Get Stock Data for Each Favorite ----
stock_data_favorites_tbl <- favorite_list_on_start %>%
    map(get_stock_data) %>%
    set_names(favorite_list_on_start)

# 2.0 Get Moving Average Data for Each Stock History ----

get_stock_mavg_info <- function(data){
    
    n_short <- data %>% pull(mavg_short) %>% is.na() %>% sum() +1
    n_long <- data %>% pull(mavg_long) %>% is.na() %>% sum() +1
    
    data %>%
        tail(1) %>%
        mutate(mavg_warning_flag = mavg_short < mavg_long) %>%
        mutate(
            n_short = n_short,
            n_long  = n_long,
            pct_chg = (mavg_short - mavg_long) / mavg_long
        ) 
}

stock_data_favorites_tbl %>%
    map_df(get_stock_mavg_info, .id = "stock")


# 3.0 Generate Favorite Card ----
favorites <- favorite_list_on_start


generate_favorite_card <- function(data) {
    column(
        width = 3,
        info_card(
            title          = as.character(data$stock),
            value          = str_glue("{data$n_short}  Day <small>vs {data$n_long} Day </small>") %>% HTML(),
            sub_value      = data$pct_chg %>% scales::percent(),
            sub_text_color = ifelse(data$mavg_warning_flag, "danger", "success"),
            sub_icon       = ifelse(data$mavg_warning_flag, "arrow-down", "arrow-up")
            
        )
    )
}

# 4.0 Generate All Favorite Cards in a TagList ----

generate_favorite_cards <- function(favorites,
                                    from       = today() - days(180),
                                    to         = today(),
                                    mavg_short = 20,
                                    mavg_long  = 50){
    favorites %>%
        # Step 1
        map(.f = function(x) {
            x %>%
                get_stock_data(
                    from       = from,
                    to         = to,
                    mavg_short = mavg_short,
                    mavg_long  = mavg_long
                )
        }) %>%
        set_names(favorites) %>%
        
        #Step 2
        map_df(.f = function(data){
            data %>%
                get_stock_mavg_info()
            
        }, .id = "stock") %>%
        
        #Step 3
        mutate(stock = as_factor(stock)) %>%
        split(.$stock) %>%
        
        #Step 4
        map(.f = generate_favorite_card )%>%
        
        # Step 5
        tagList()
}

generate_favorite_cards(favorites = c("NVDA", "AAPL"), from = "2018-01-01", to = "2019-01-01",
                        mavg_short = 30, mavg_long = 90)


# 5.0 Save Functions ----
dump(c("get_stock_mavg_info", "generate_favorite_card", 'generate_favorite_cards'), 
     file = "00_scripts/generate_favorite_cards.R", append = FALSE)
