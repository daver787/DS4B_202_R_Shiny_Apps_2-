read_user_base <-
function(){
    user_base_tbl <<- read_rds(file =  "00_data_local/user_base_tbl.rds")
}
update_and_write_user_base <-
function(user_name, column_name, assign_input){
    user_base_tbl[user_base_tbl$user == user_name, ][[column_name]] <<- assign_input
    write_rds(user_base_tbl, file =  "00_data_local/user_base_tbl.rds")
}
