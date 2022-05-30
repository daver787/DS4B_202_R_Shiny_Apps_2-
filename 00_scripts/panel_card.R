

panel_card <- function(title = title,...,footer = NULL){
    
    ftr <- NULL
    if (!is.null(footer)){
        ftr <- div(
            class = "panel-footer",
            footer
        )
    }
    
    div(
        class = "panel",
        div(
            class = "panel-header",
            h4(title)
        ),
        div(
            class = "panel-body",
            ...
        ),
        ftr
    )
}

