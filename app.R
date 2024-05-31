library(shiny)
library(e1071)
library(shinyjs)

# Load the trained Naive Bayes model
load("modelo_final.RData")
modelo <- modelo_final

# Define the UI with a modern theme
ui <- fluidPage(
  includeCSS("bootstrap.css"), # Apply a modern theme
  useShinyjs(), # Include shinyjs for JavaScript manipulation
  tags$head(
    tags$style(
      HTML("
            .prediction-text {
              font-size: 15px;
            }
          ")
    )
  ),
  div(style = " padding: 20px; border-radius: 10px; text-align: center; margin-bottom: 30px;",
      tags$h1("Breast Cancer Prediction App", style = " font-size: 30px;")),
  
  div(class = "container",
      h3("Enter the variables:"),
      fluidRow(
        column(6, selectInput("input_edad", "Age:", choices = c("0-30", "31-40", "41-50", "51-60", "61-70", "+70"), selected = "0-30")),
        column(6, selectInput("input_rest", "REst:", choices = c("N", "P"), selected = "N"))
      ),
      fluidRow(
        column(6, selectInput("input_grado", "Grade:", choices = c("1", "2", "3"), selected = "1")),
        column(6, selectInput("input_estadio", "Stage:", choices = c("T0-T1", "T2", "T3", "T4"), selected = "T0-T1"))
      ),
      fluidRow(
        column(6, actionButton("submit_button", "Make Prediction", class = "btn-primary")),
        column(6, actionButton("help_button", "Need help with oncological variables?", class = "btn-info"))
      ),
      div(style = "height: 20px;"), # Add space below buttons
      div(style = "border-bottom: 2px solid #ccc; margin-bottom: 20px;"), # Border for separation
      div(id = "resultado_container", style = "display: none;",
          h3("Prediction Result:"),
          div(class = "alert alert-dismissible alert-light prediction-text",
              strong("Prediction: "), 
              textOutput("resultado_prediccion")
          )
      ),
      br(),
      div(id = "help_container", style = "display: none;",
          div(class = "alert alert-dismissible alert-info",
              strong("Help: "), 
              "This alert provides information about the oncological variables used in the prediction:",
              br(),
              p("- Age: The age of the patient."),
              p("- REst: Hormone receptor status (N: Negative, P: Positive)."),
              p("- Grade: Histological grade of the tumor (1, 2, or 3)."),
              p("- Stage: Tumor stage (T0-T1, T2, T3, or T4)."),
              br(),
              "It's important to note that this prediction is based on statistical modeling and should not replace personalized medical advice. Please consult with your healthcare provider for any concerns or questions regarding breast cancer diagnosis or treatment.",
              tags$button(type = "button", class = "btn-close", onclick = "shinyjs.hide('help_container');")
          )
      ),
      br(),
      div(id = "progress_container", style = "display: none;",
          div(class = "progress",
              div(class = "progress-bar", role = "progressbar", 
                  style = "width: 0%;", aria_valuenow = "0", aria_valuemin = "0", aria_valuemax = "100")
          )
      )
  )
)

# Define the server logic
server <- function(input, output, session) {
  # Perform prediction when the button is clicked
  observeEvent(input$submit_button, {
    # Collect user input data
    datos_usuario <- data.frame(
      Edad = factor(input$input_edad, levels = c("0-30", "31-40", "41-50", "51-60", "61-70", "+70")),
      REst = factor(input$input_rest, levels = c("N", "P")),
      Grado = factor(input$input_grado, levels = c("1", "2", "3")),
      Estadio = factor(input$input_estadio, levels = c("T0-T1", "T2", "T3", "T4"))
    )
    
    # Show progress bar
    shinyjs::show("progress_container")
    
    # Update the progress bar
    for (i in seq(0, 100, by = 25)) {
      shinyjs::runjs(paste0("$('.progress-bar').css('width', '", i, "%').attr('aria-valuenow', '", i, "');"))
      Sys.sleep(0.25)  # Shortened to 0.25 seconds to match 1 second total duration
    }
    
    # Perform prediction using the loaded model
    prediccion <- predict(modelo, newdata = datos_usuario, type = "raw")
    probabilidad <- prediccion[2]
    
    # Display the prediction to the user
    output$resultado_prediccion <- renderText({
      paste("The probability that the result is 'YES' is:", round(probabilidad, 2))
    })
    
    # Hide the progress bar after completing the prediction
    shinyjs::hide("progress_container")
    shinyjs::show("resultado_container")
  })
  
  # Display help alert if requested
  observeEvent(input$help_button, {
    shinyjs::show("help_container")
  })
}

# Run the Shiny app
shinyApp(ui, server)
