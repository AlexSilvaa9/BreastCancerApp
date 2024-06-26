library(shiny)
library(nnet)
library(shinyjs)

# Load the trained nnet model
load("modelo_final.RData")

# Definir niveles para cada variable
niveles_edad <- c("0-39", "40-49", "50-59", "60-69", "70-79", "≥80")
niveles_fdiag <- c("2000-2009", "2010-2019")
niveles_estadio <- c("I", "II", "III", "IV")
niveles_grado <- c("1", "2", "3")

# Define the UI with a modern theme
ui <- fluidPage(
  includeCSS("bootstrap.css"), # Aplicar un tema moderno
  useShinyjs(), # Incluir shinyjs para manipulación con JavaScript
  tags$head(
    tags$style(
      HTML("
            .prediction-text {
              font-size: 15px;
            }
          ")
    )
  ),
  
  div(style = "padding: 20px; border-radius: 10px; text-align: center; margin-bottom: 30px;",
      tags$h1("Breast Cancer Survival Prediction App", style = "font-size: 30px;")),
  
  div(class = "container",
      h3("Enter the variables:"),
      fluidRow(
        column(6, selectInput("input_edad", "Age at Diagnosis:", choices = niveles_edad, selected = "0-39")),
        column(6, selectInput("input_fdiag", "Year of Diagnosis:", choices = niveles_fdiag, selected = "2000-2009"))
      ),
      fluidRow(
        column(6, selectInput("input_estadio", "Stage:", choices = niveles_estadio, selected = "I")),
        column(6, selectInput("input_grado", "Grade:", choices = niveles_grado, selected = "1"))
      ),
      fluidRow(
        column(6, actionButton("submit_button", "Make Prediction", class = "btn-primary")),
        column(6, actionButton("help_button", "Need help with oncological variables?", class = "btn-info"))
      ),
      div(style = "height: 20px;"), # Agregar espacio debajo de los botones
      div(style = "border-bottom: 2px solid #ccc; margin-bottom: 20px;"), # Borde para separación
      div(id = "resultado_container", style = "display: none;",
          h3("Prediction Result:"),
          div(class = "alert alert-dismissible alert-light prediction-text",
              strong("Prediction: "), 
              htmlOutput("resultado_prediccion")
              
              
          )
      ),
      br(),
      div(id = "help_container", style = "display: none;",
          div(class = "alert alert-dismissible alert-info",
              strong("Help: "), 
              "This alert provides information about the oncological variables used in the prediction:",
              br(),
              p("- Age: The age of the patient."),
              p("- Year of Diagnosis: The year in which the diagnosis was made."),
              p("- Stage: The stage of the cancer (I, II, III, IV)."),
              p("- Grade: Histological grade of the tumor (1, 2, or 3)."),
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
      EDAD_DCO = factor(input$input_edad, levels = niveles_edad),
      F.DIAG = factor(input$input_fdiag, levels = niveles_fdiag),
      ESTADIO = factor(input$input_estadio, levels = niveles_estadio),
      GRADO = factor(input$input_grado, levels = niveles_grado)
    )
    
    # Show progress bar
    shinyjs::show("progress_container")
    
    # Update the progress bar
    for (i in seq(0, 100, by = 25)) {
      shinyjs::runjs(paste0("$('.progress-bar').css('width', '", i, "%').attr('aria-valuenow', '", i, "');"))
      Sys.sleep(0.25)  # Shortened to 0.25 seconds to match 1 second total duration
    }
    
    # Perform prediction using the loaded model
    prediccion <- predict(modelo_final, newdata = datos_usuario, type = "raw")
    resultado <- ifelse(prediccion > 0.94, "Alive", "Exitus")
    # Display the prediction to the user
    output$resultado_prediccion <- renderText({
      paste("The probability that the patient is alive is:", 
              round(prediccion, 2), "<br>",
              "Setting a threshold on 0.94 the prediction is:", resultado)
      
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
