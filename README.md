
# EconoTools

EconoTools is an R package and Shiny application for streamlined economic analysis. It integrates with the FRED (Federal Reserve Economic Data) API to allow users to fetch, clean, analyze, and visualize macroeconomic time-series data using both static and interactive charts.

## Features

- Fetch data from the FRED API using a user-defined key
- Clean and transform economic data using custom R functions
- Generate static plots with ggplot2 and interactive plots with plotly
- Launch an interactive dashboard using Shiny
- Modular code structure suitable for academic or research use
- Package documented using roxygen2 and tested with testthat

## Prerequisites

- R and RStudio
- A free FRED API Key: https://fred.stlouisfed.org/docs/api/api_key.html

## Installation and Setup

### 1. Set your FRED API Key

In RStudio, run:

```r
install.packages("usethis")
usethis::edit_r_environ()
```

Then add the following line to the file that opens (replace `your_key_here`):

```
FRED_API_KEY='your_key_here'
```

Save the file and restart RStudio.

### 2. Install required packages

```r
install.packages(c(
  "devtools", "shiny", "ggplot2", "plotly", "dplyr", "httr",
  "jsonlite", "zoo", "roxygen2", "testthat", "magrittr", "bslib", "knitr"
))
```

### 3. Build and install the package

```r
devtools::document()
devtools::test()
devtools::install()
```

### 4. Launch the Shiny application

```r
shiny::runApp("inst/shiny-app/")
```

## Project Structure

```
EconoTools/
├── R/                  # R functions for data processing and analysis
├── man/                # Documentation files
├── tests/              # Unit tests
├── inst/shiny-app/     # Shiny application code
├── DESCRIPTION         # Package metadata
├── NAMESPACE           # Auto-generated export declarations
└── README.md           # This file
```

## Author

Alen K Suresh  
Email: alenkarakkattil4444@gmail.com  
GitHub: https://github.com/alenkarakkattil  
LinkedIn: https://www.linkedin.com/in/alen-k-suresh

## License

This project is licensed under the MIT License.
