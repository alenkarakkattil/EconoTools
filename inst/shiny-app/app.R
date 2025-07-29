library(shiny)
library(plotly)
library(ggplot2)
library(EconoTools) # Our package!

# Define UI
ui <- fluidPage(
    theme = bslib::bs_theme(version = 4, bootswatch = "flatly"),
    titlePanel("EconoTools: Interactive Economic Data Explorer"),

    sidebarLayout(
        sidebarPanel(
            h4("Controls"),
            textInput("series", "Enter FRED Series ID:", "GDP"),
            hr(),
            sliderInput("sma_n", "Simple Moving Average (SMA) Window:", min = 2, max = 80, value = 40),
            hr(),
            p("Enter a valid FRED API key. It's recommended to set this as a system environment variable named FRED_API_KEY."),
            passwordInput("api_key_input", "Enter FRED API Key:", value = Sys.getenv("FRED_API_KEY")),
            hr(),
            actionButton("run", "Fetch & Plot Data", class = "btn-primary"),
            hr(),
            helpText("Examples: GDP (US GDP), CPIAUCSL (Inflation), UNRATE (Unemployment Rate). Find more at the FRED website.")
        ),
        mainPanel(
            h3(textOutput("plot_title")),
            plotlyOutput("distPlot", height = "600px")
        )
    )
)

# Define Server
server <- function(input, output, session) {

    data_reactive <- eventReactive(input$run, {
        req(input$series, input$api_key_input)
        
        # Show a notification that we're fetching data
        id <- showNotification("Fetching data from FRED API...", duration = NULL, closeButton = FALSE, type = "message")
        on.exit(removeNotification(id), add = TRUE)

        tryCatch({
            raw_data <- fetch_fred_data(input$series, api_key = input$api_key_input)
            calculate_sma(raw_data, n = input$sma_n)
        }, error = function(e) {
            showNotification(paste("Error:", e$message), type = "error", duration = 10)
            return(NULL)
        })
    })

    output$plot_title <- renderText({
        req(data_reactive())
        paste("Analysis for Series:", toupper(isolate(input$series)))
    })

    output$distPlot <- renderPlotly({
        plot_data <- data_reactive()
        req(plot_data)

        p <- ggplot(plot_data, aes(x = date)) +
            geom_line(aes(y = value, text = paste("Date:", date, "Value:", value)), color = "#2c3e50") +
            geom_line(aes(y = sma, text = paste("Date:", date, "SMA:", round(sma, 2))), color = "#e74c3c", size = 1) +
            labs(
                title = paste(isolate(input$series), "and", isolate(input$sma_n), "-Period SMA"),
                y = "Value",
                x = "Date",
                caption = "Data Source: Federal Reserve Economic Data (FRED)"
            ) +
            theme_minimal(base_size = 14)

        ggplotly(p, tooltip = "text")
    })
}

# Run the application
shinyApp(ui = ui, server = server)