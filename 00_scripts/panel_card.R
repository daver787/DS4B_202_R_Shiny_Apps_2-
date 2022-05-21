

panel_card <- function(title,...,footer =NULL){ tabPanel(
    title = x,
    div(
        class = "panel",
        div(
            class = "panel-header",
            h4(x)
        ),
        div(
            class = "panel-body",
            x %>%
                get_stock_data(
                    from       = today() - days(180),
                    to         = today(),
                    mavg_short = mavg_short(),
                    mavg_long  = mavg_long()
                ) %>%
                plot_stock_data()
        )
    )
)
}