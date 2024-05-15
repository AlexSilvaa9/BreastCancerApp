
# Cargar el conjunto de datos mtcars
data(mtcars)

# Entrenar un modelo de regresión lineal simple
modelo <- lm(mpg ~ wt, data = mtcars)

# Guardar el modelo entrenado
saveRDS(modelo, "modelo_entrenado.rds")

# Resumen del modelo entrenado
summary(modelo)


library(shiny)

# Carga el modelo entrenado
modelo <- readRDS("modelo_entrenado.rds")

ui <- fluidPage(
  titlePanel("Aplicación de Predicción"),
  includeCSS("bootstrap.css"),
  sidebarLayout(
    sidebarPanel(
      # Elementos de entrada para los datos del usuario
      numericInput("input_variable_1", "Variable 1:", value = 0),
      numericInput("input_variable_2", "Variable 2:", value = 0),
      # Agrega más elementos de entrada según sea necesario
      actionButton("submit_button", "Realizar Predicción")
    ),
    mainPanel(
      # Mostrar resultados de la predicción
      textOutput("resultado_prediccion")
    )
  )
)

server <- function(input, output) {
  # Realizar predicción cuando se hace clic en el botón
  observeEvent(input$submit_button, {
    # Recolecta los datos ingresados por el usuario
    datos_usuario <- data.frame(
      wt = input$input_variable_1,
      mpg = input$input_variable_2
      # Agrega más variables según sea necesario
    )
    # Realiza la predicción usando el modelo cargado
    prediccion <- predict(modelo, newdata = datos_usuario)
    # Muestra la predicción al usuario
    output$resultado_prediccion <- renderText({
      paste("La predicción es:", prediccion)
    })
  })
}

shinyApp(ui, server)