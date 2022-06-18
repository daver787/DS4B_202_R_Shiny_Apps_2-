# CRUD WORKFLOW ----

library(tidyverse)

# 1.0 WORKFLOW FOR CRUD OPERATIONS USING BASE R ---- 
user_base_tbl[user_base_tbl$user == "user1", ][["last_symbol"]] <- "MA"

user_base_tbl

user_base_tbl[user_base_tbl$user == "user1", ][["favorites"]] <- list (c("APPL", "GOOG", "NFLX", "MA"))


user_base_tbl[user_base_tbl$user == "user1", ][["user_settings"]] 

user_settings <- tibble(
    mavg_short  = 15,
    mavg_long   = 50,
    time_window = 365
)

user_settings

user_base_tbl[user_base_tbl$user == "user1", ][["user_settings"]] <- list(user_settings)

write_rds(user_base_tbl, file =  "00_data_local/user_base_tbl.rds")

read_rds(file = "00_data_local/user_base_tbl.rds") %>%
    filter(user ==  "user1") %>%
    pull(user_settings)

# 2.0 MODULARIZE CODE FOR LOCAL STORAGE ----

read_user_base <- function(){
    user_base_tbl <<- read_rds(file =  "00_data_local/user_base_tbl.rds")
}

read_user_base()

user_base_tbl


update_user_base <- function(user_name, column_name, assign_input){
    
    user_base_tbl[user_base_tbl$user == user_name, ][[column_name]] <<- assign_input
}

update_user_base("user2", "last_symbol", "NFLX")

user_base_tbl

write_user_base <- function(){
    write_rds(user_base_tbl, file =  "00_data_local/user_base_tbl.rds")
}

write_user_base

read_user_base()

user_base_tbl


update_and_write_user_base <- function(user_name, column_name, assign_input){
    user_base_tbl[user_base_tbl$user == user_name, ][[column_name]] <<- assign_input
    write_rds(user_base_tbl, file =  "00_data_local/user_base_tbl.rds")
}

# 3.0 CHECK WORKFLOW ----

read_user_base()

user_base_tbl

update_and_write_user_base("user1", "last_symbol", "MA")

rm(user_base_tbl)

read_user_base()

user_base_tbl

# 4.0 SAVE FUNCTIONS ----

dump(c("read_user_base","update_and_write_user_base"), file = "00_scripts/crud_operations.R")
