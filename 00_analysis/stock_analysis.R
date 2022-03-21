# BUSINESS SCIENCE ----
# DS4B 202-R ----
# STOCK ANALYZER APP - DATA ANALYSIS -----
# Version 1

# APPLICATION DESCRIPTION ----
# - The user will select 1 stock from the SP 500 stock index
# - The functionality is designed to pull the past 180 days of stock data
# - We will implement 2 moving averages - short (fast) and long (slow)
# - We will produce a timeseries visualization
# - We will produce automated commentary based on the moving averages

# REPRODUCIBILITY REQUIREMENTS
# - The functionality is designed to pull the past 180 days of stock data from today's date
# - Because of this, your analysis may differ from mine
# - To reproduce my analysis, replace today() with ymd("2019-08-19")

# LIBRARIES ----
library(plotly)
library(tidyquant)
library(tidyverse)
library(fs)



# 1.0 GET STOCK LIST ----
stock_list_tbl <- tq_index("SP500") %>%
    select(symbol, company) %>%
    arrange(symbol) %>%
    mutate(label = str_c(symbol,company, sep = ", ")) %>%
    select(label)

stock_list_tbl

get_stock_list <- function(stock_index = "SP500"){
    
    tq_index(stock_index) %>%
        select(symbol, company) %>%
        arrange(symbol) %>%
        mutate(label = str_c(symbol,company, sep = ", ")) %>%
        select(label)
    
}


tq_index_options()

get_stock_list("DOW")
get_stock_list("SP500")

# 2.0 EXTRACT SYMBOL BASED ON USER INPUT ----

user_input <- "AAPL, Apple Inc."

user_input %>% str_split(pattern = ", ") %>% pluck(1,1)

get_symbol_from_user_input <- function(user_input){
    user_input %>% str_split(pattern = ", ") %>% pluck(1,1)
    
}

"A, Agilent Technologies Inc." %>% get_symbol_from_user_input()

"AAPL, Apple Inc." %>% get_symbol_from_user_input()

# 3.0 GET STOCK DATA ----
from <- ymd("2019-08-20")- days(180)
to <- ymd("2019-08-20") 

"AAPL" %>% tq_get("stock.prices", from = "2018-01-01", to = "2019-01-01")

"AAPL" %>% tq_get("stock.prices", from = from, to = to) %>% 
    select(date, adjusted) %>%
    mutate(mavg_short = rollmean(adjusted, k = 5, na.pad = TRUE, align = "right")) %>%
    mutate(mavg_long = rollmean(adjusted, k = 50, na.pad = TRUE, align = "right"))


get_stock_data <- function(stock_symbol,
                           from       = today() -days(180),
                           to         = today(),
                           mavg_short = 20,
                           mavg_long  = 50){
    
    stock_symbol %>% tq_get("stock.prices", from = from, to = to) %>% 
        select(date, adjusted) %>%
        mutate(mavg_short = rollmean(adjusted, k = mavg_short, na.pad = TRUE, align = "right")) %>%
        mutate(mavg_long = rollmean(adjusted, k = mavg_long, na.pad = TRUE, align = "right"))
    
}

stock_data_tbl <- get_stock_data("AAPL", from = "2018-01-01", to = "2018-06-30", mavg_short = 5, mavg_long = 8)

# 4.0 PLOT STOCK DATA ----
g <- stock_data_tbl %>%
    gather(key = "legend", value = "value", adjusted:mavg_long, factor_key =TRUE) %>%
    ggplot(aes(date, value, color = legend, group = legend)) +
    geom_line(aes(linetype = legend)) +
    theme_tq() +
    scale_y_continuous(labels = scales::dollar_format(largest_with_cents = 10)) +
    scale_color_tq() +
    labs(x = "", y = "Adjusted Share Price")

ggplotly(g)

plot_stock_data <- function(data){
    g <- data%>%
        gather(key = "legend", value = "value", adjusted:mavg_long, factor_key = TRUE) %>%
        ggplot(aes(date, value, color = legend, group = legend)) +
        geom_line(aes(linetype = legend)) +
        theme_tq() +
        scale_y_continuous(labels = scales::dollar_format(largest_with_cents = 10)) +
        scale_color_tq() +
        labs(x = "", y = "Adjusted Share Price")
    
    ggplotly(g)
}


plot_stock_data(stock_data_tbl)

"AAPL" %>%
    get_stock_data(from = "2018-01-01", to = "2018-06-30", mavg_short = 5, mavg_long = 8) %>%
    plot_stock_data()

# 5.0 GENERATE COMMENTARY ----
warning_signal <- stock_data_tbl %>%
    tail(1) %>%
    mutate(mavg_warning_flag = mavg_short < mavg_long) %>%
    pull(mavg_warning_flag)


n_short <- stock_data_tbl %>% pull(mavg_short) %>% is.na() %>% sum() +1
n_long <- stock_data_tbl %>% pull(mavg_long) %>% is.na() %>% sum() +1

if(warning_signal){
    str_glue("In reviewing the stock prices of {user_input}, the {n_short}-day moving average is below the {n_long}-day moving average, indicating negative trends")
    
}else{
    str_glue("In reviewing the stock prices of {user_input}, the {n_short}-day moving average is above the {n_long}-day moving average, indicating positive trends")
    
}


generate_commentary <- function(data, user_input){
   
     warning_signal <- data %>%
        tail(1) %>%
        mutate(mavg_warning_flag = mavg_short < mavg_long) %>%
        pull(mavg_warning_flag)
    
    
    n_short <- data %>% pull(mavg_short) %>% is.na() %>% sum() +1
    n_long <- data %>% pull(mavg_long) %>% is.na() %>% sum() +1
    
    if(warning_signal){
        str_glue("In reviewing the stock prices of {user_input}, the {n_short}-day moving average is below the {n_long}-day moving average, indicating negative trends")
        
    }else{
        str_glue("In reviewing the stock prices of {user_input}, the {n_short}-day moving average is above the {n_long}-day moving average, indicating positive trends")
        
    }
    
}

generate_commentary(stock_data_tbl, user_input = user_input)


# 6.0 TEST WORKFLOW ----
get_stock_list("SP500")

"ABT, Abbott Laboratories" %>%
    get_symbol_from_user_input() %>%
    get_stock_data(from = "2018-01-01", to = "2019-01-01") %>%
    #plot_stock_data()
    generate_commentary(user_input = "ABT, Abbott Laboratories")

# 7.0 SAVE SCRIPTS ----

fs::dir_create("00_scripts")

dump(
    list   = c("get_stock_list", "get_symbol_from_user_input", "get_stock_data", "plot_stock_data", "generate_commentary"),
    file   = "00_scripts/stock_analysis_functions.R",
    append = FALSE)




