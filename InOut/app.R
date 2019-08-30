#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readr)
library(dplyr)

# Source the functions so they can be used
source("functions.R")

# Read in the data so we have something initially
# Since the functions can read / write the data we will have to update 'live_data' too
live_data <- read_rds("log.rds")

# Define UI for application
ui <- fluidPage( # Application title
  titlePanel("H & SC Team Meetings"),

  # Sidebar with links to pick high level function
  navlistPanel(
    # Panel for picking new 'team'
    tabPanel(
      "Pick next Chair/Minute taker",
      # A button to click
      actionButton(inputId = "choose", label = "Choose"),
      # Some text boxes
      htmlOutput("next_chair"),
      htmlOutput("next_minuter")
    ),

    # Panel for displaying the log and updating data
    tabPanel(
      "Input Meeting",
      # Drop downs for picking names
      selectInput(inputId = "chair_name", label = "Last Chair", c(live_data$name, "* Other / Left team *")),
      selectInput(inputId = "minute_name", label = "Last Minute taker", c(live_data$name, "* Other / Left team *")),
      # Input for dates
      dateInput(
        inputId = "meeting_date",
        label = "Date of last meeting",
        value = Sys.Date(),
        min = "2018-01-01",
        weekstart = 1
      ),
      # Button for accepting input
      actionButton(inputId = "input_data", label = "Add data"),
      # A table to display the log
      dataTableOutput("log_table")
    )
  )
)

# Define server logic
server <- function(input, output) {
  ## Pick new team tab

  # Wait for a button click
  observeEvent(input$choose, {
    # Get the new 'team'
    # This is a tibble with one row
    team <- pick_team()
    # Fill in the text box with the selection for chair
    # Uses some HTML to display things nicely
    output$next_chair <- renderText(
      paste0(
        "<br> Chair is: <b>",
        team$chair,
        "</b><br>Chaired ",
        filter(live_data, name == team$chair)$times_chaired,
        " times before, last on ",
        filter(live_data, name == team$chair)$last_chaired
      )
    )

    # Same for minute taker
    output$next_minuter <- renderText(
      paste0(
        "<br><br>Minute taker is: <b>",
        team$minute_taker,
        "</b><br>Minuted ",
        filter(live_data, name == team$minute_taker)$times_minuted,
        " times before, last on ",
        filter(live_data, name == team$minute_taker)$last_minuted
      )
    )
  })

  ## Input meeting tab
  # Display the log as a table which can be sorted
  output$log_table <- renderDataTable(live_data)

  # Wait for a button click
  observeEvent(input$input_data, {
    # Update live data with the add_meeting function
    # This function will also write the data back to disk
    live_data <- add_meeting(
      input$chair_name,
      input$minute_name,
      as.character(input$meeting_date)
    )
    # Redraw the table with the new data
    output$log_table <- renderDataTable(live_data)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
