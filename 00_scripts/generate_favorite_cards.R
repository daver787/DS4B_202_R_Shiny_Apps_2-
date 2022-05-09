get_stock_mavg_info <-
function(data){
    
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
generate_favorite_card <-
function(data) {
    column(
        width = 3,
        info_card(
            title          = as.character(data$stock),
            value          = str_glue("{data$n_short} <small>vs {data$n_long}</small>") %>% HTML(),
            sub_value      = data$pct_chg %>% scales::percent(),
            sub_text_color = ifelse(data$mavg_warning_flag, "danger", "success"),
            sub_icon       = ifelse(data$mavg_warning_flag, "arrow-down", "arrow-up")
            
        )
    )
}
generate_favorite_cards <-
function(favorites,
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
