# Load necessary libraries
library(shiny)
library(plotly)
library(ggplot2)
library(EconoTools) # Your package!
library(bslib)

# Define the user interface (UI)
ui <- fluidPage(
  # Set a theme for a clean look
  theme = bslib::bs_theme(version = 4, bootswatch = "flatly"),
  titlePanel("EconoTools: Interactive Economic Data Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Controls"),
      # Text input for the FRED series ID
      textInput("series", "Enter FRED Series ID:", "GDP"),
      hr(),
      # Slider to set the SMA window size
      sliderInput("sma_n", "Simple Moving Average (SMA) Window:", min = 2, max = 80, value = 40),
      hr(),
      # Instructions for the API key
      p("Enter a valid FRED API key. It's recommended to set this as a system environment variable named FRED_API_KEY."),
      # Password input for the API key (obscured text)
      passwordInput("api_key_input", "Enter FRED API Key:", value = Sys.getenv("FRED_API_KEY")),
      hr(),
      # Action button to trigger data fetching and plotting
      actionButton("run", "Fetch & Plot Data", class = "btn-primary"),
      hr(),
      # Help text with examples
      helpText("Examples: GDP (US GDP), CPIAUCSL (Inflation), UNRATE (Unemployment Rate). Find more at the FRED website.")
    ),
    mainPanel(
      # Output for the plot title
      h3(textOutput("plot_title")),
      # Output for the interactive plot
      plotlyOutput("distPlot", height = "600px")
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Reactive expression to fetch and process data when the "run" button is clicked
  data_reactive <- eventReactive(input$run, {
    # Ensure the series ID and API key are provided
    req(input$series, input$api_key_input)
    
    # Show a notification while data is being fetched
    id <- showNotification("Fetching data from FRED API...", duration = NULL, closeButton = FALSE, type = "message")
    # Ensure the notification is removed when the function exits
    on.exit(removeNotification(id), add = TRUE)
    
    tryCatch({
      # Use the key from the input field directly
      key_to_use <- input$api_key_input
      
      # Fetch raw data and then calculate the SMA
      raw_data <- fetch_fred_data(input$series, api_key = key_to_use)
      processed_data <- calculate_sma(raw_data, n = input$sma_n)
      
      processed_data
    }, error = function(e) {
      # Display an error message if the data fetch fails
      showNotification(paste("Error:", e$message), type = "error", duration = 10)
      return(NULL)
    })
  })
  
  # Render the plot title
  output$plot_title <- renderText({
    # Ensure data is ready before creating the title
    req(data_reactive())
    paste("Analysis for Series:", toupper(isolate(input$series)))
  })
  
  # Render the interactive plot using a different approach
  output$distPlot <- renderPlotly({
    plot_data <- data_reactive()
    req(plot_data)
    
    # Create a basic plotly plot from scratch to avoid ggplotly rendering issues
    p <- plot_ly(plot_data, x = ~date) |>
      add_lines(y = ~value, name = "Original Data", color = I("#2c3e50"), 
                text = paste("Date:", plot_data$date, "Value:", plot_data$value), hoverinfo = "text") |>
      add_lines(y = ~sma, name = paste0(isolate(input$sma_n), "-Period SMA"), 
                color = I("#e74c3c"), line = list(width = 1),
                text = paste("Date:", plot_data$date, "SMA:", round(plot_data$sma, 2)), hoverinfo = "text") |>
      layout(
        title = paste(isolate(input$series), "and", isolate(input$sma_n), "-Period SMA"),
        xaxis = list(title = "Date"),
        yaxis = list(title = "Value")
      )
    
    p
  })
}

# Run the application
shinyApp(ui = ui, server = server)
