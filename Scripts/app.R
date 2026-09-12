# ==============================================================================
# DASHBOARD: Confianza institucional y disposición a donar
# Proyecto Final - Econometría Básica 2026-II | Grupo A2 (Confianza institucional)
#
# Versión con interfaz shinydashboard (sidebar oscuro, cajas de color, valueBox)
# y la paleta de colores tipo "flat UI": azul pizarra, rojo, azul, verde,
# naranja y morado.
#
# Para ejecutarlo: coloque este archivo (app.R) y "datos_encuesta.csv" en la
# misma carpeta, ábralo en RStudio y presione "Run App".
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. LIBRERÍAS
# Si falta alguna, instálela con:
# install.packages(c("shiny","shinydashboard","shinyWidgets","ggplot2","dplyr",
#                     "tidyr","plotly","DT","scales","stringr"))
# ------------------------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)
library(DT)
library(scales)
library(stringr)

# ------------------------------------------------------------------------------
# 1. LECTURA Y LIMPIEZA DE LOS DATOS
# Importante: NO se modifica el archivo original en disco. Todo el procesamiento
# se hace en memoria, dentro de este script.
# ------------------------------------------------------------------------------

datos_raw <- read.csv("datos_encuesta.csv", stringsAsFactors = FALSE, encoding = "UTF-8")

datos <- datos_raw %>%
  mutate(
    # --- Monto donado: viene como texto tipo "$ 50,000.00" o "$ -" ---
    monto_donacion_num = monto_donacion %>%
      str_replace_all("[^0-9.]", "") %>%
      as.numeric(),
    monto_donacion_num = ifelse(is.na(monto_donacion_num), 0, monto_donacion_num),

    # --- Variables categóricas: se limpian espacios y mayúsculas para que
    #     categorías equivalentes (ej. "empresas Privadas") no queden separadas ---
    genero = str_trim(genero),
    vinculo_universidad = str_trim(vinculo_universidad),
    ha_donado = str_trim(ha_donado),
    donaria = str_trim(tolower(donaria)),
    compartiria_campana = str_trim(tolower(compartiria_campana)),
    experiencia_emergencia = str_trim(tolower(experiencia_emergencia)),

    capacidad_institucion = str_trim(str_to_lower(capacidad_institucion)),
    liderazgo_institucion = str_trim(str_to_lower(liderazgo_institucion)),

    # --- Experiencia previa de donación (derivada de ha_donado) ---
    experiencia_previa = ifelse(
      ha_donado == "no, ninguna de las anteriores", "Sin experiencia previa", "Con experiencia previa"
    ),

    # --- Probabilidad percibida: se deja como factor ordenado para filtros,
    #     y se calcula un punto medio numérico solo para gráficos de dispersión ---
    prob_llegada_recursos = str_trim(prob_llegada_recursos),
    prob_llegada_recursos = factor(
      prob_llegada_recursos,
      levels = c("0 - 20", "20 - 40", "40 - 60", "60 - 80", "80 - 100")
    ),
    prob_llegada_punto_medio = case_when(
      prob_llegada_recursos == "0 - 20"   ~ 10,
      prob_llegada_recursos == "20 - 40"  ~ 30,
      prob_llegada_recursos == "40 - 60"  ~ 50,
      prob_llegada_recursos == "60 - 80"  ~ 70,
      prob_llegada_recursos == "80 - 100" ~ 90,
      TRUE ~ NA_real_
    ),

    donaria_lbl = ifelse(donaria == "si", "Sí donaría", "No donaría")
  )

# Etiquetas legibles para las instituciones (se usan en varias secciones)
etiquetas_instituciones <- c(
  confianza_alcaldias      = "Alcaldías",
  confianza_gobierno       = "Gobierno Nacional",
  confianza_ong            = "ONG",
  confianza_universidades  = "Universidades",
  confianza_religiosa      = "Organizaciones religiosas",
  confianza_empresas       = "Empresas privadas"
)

etiquetas_cap_lider <- c(
  "gobierno nacional"      = "Gobierno Nacional",
  "alcaldias"              = "Alcaldías",
  "ong"                    = "ONG",
  "universidades"          = "Universidades",
  "empresas privadas"      = "Empresas privadas",
  "organizacion religiosa" = "Organizaciones religiosas"
)

# ------------------------------------------------------------------------------
# PALETA DE COLORES (estilo "flat UI"): azul pizarra, rojo, azul, verde,
# naranja y morado, extendida con dos tonos más de la misma familia para las
# categorías con más de 6 valores.
# ------------------------------------------------------------------------------
paleta <- c("#2C3E50", "#E74C3C", "#3498DB", "#27AE60", "#F39C12", "#9B59B6")
paleta_extendida <- c(paleta, "#16A085", "#34495E")

color_si  <- "#27AE60"  # verde: sí donaría
color_no  <- "#E74C3C"  # rojo: no donaría

# ------------------------------------------------------------------------------
# 2. FUNCIÓN AUXILIAR: frecuencia de palabras en razón de donar / no donar
# (se usa en lugar de una nube de palabras, que es más difícil de leer)
# ------------------------------------------------------------------------------
palabras_vacias <- c(
  "de","la","el","en","y","a","que","los","las","un","una","por","para","no","si","sí",
  "me","mi","se","es","lo","con","como","porque","del","al","o","u","e","donaria","donaría",
  "esta","este","esto","son","hay","muy","mas","más","pero","ya","le","les","sus","su",
  "sea","ser","hace","tengo","tener","donde","cuando","eso","asi","así","yo","tu","tú"
)

calcular_frecuencia_palabras <- function(textos, top_n = 12) {
  textos <- textos[!is.na(textos) & str_trim(textos) != ""]
  if (length(textos) == 0) return(data.frame(palabra = character(0), frecuencia = integer(0)))

  texto_unido <- str_to_lower(paste(textos, collapse = " "))
  texto_unido <- str_replace_all(texto_unido, "[^a-záéíóúñ ]", " ")
  palabras <- str_split(texto_unido, "\\s+")[[1]]
  palabras <- palabras[nchar(palabras) > 3 & !(palabras %in% palabras_vacias)]

  if (length(palabras) == 0) return(data.frame(palabra = character(0), frecuencia = integer(0)))

  tabla <- as.data.frame(table(palabras), stringsAsFactors = FALSE)
  names(tabla) <- c("palabra", "frecuencia")
  tabla <- tabla %>% arrange(desc(frecuencia)) %>% head(top_n)
  tabla
}

# Margen amplio y estándar para TODOS los gráficos, de modo que ejes, títulos,
# etiquetas rotadas y leyendas nunca queden recortados.
margen_amplio <- list(l = 90, r = 40, b = 110, t = 60, pad = 6)

# ------------------------------------------------------------------------------
# 3. INTERFAZ DE USUARIO (UI)
# ------------------------------------------------------------------------------

ui <- dashboardPage(
  skin = "blue",

  dashboardHeader(title = "Confianza y donación — Grupo A2", titleWidth = 340),

  dashboardSidebar(
    width = 340,
    sidebarMenu(
      id = "menu",
      menuItem("Inicio y perfil", tabName = "inicio", icon = icon("house")),
      menuItem("Disposición a donar", tabName = "donacion", icon = icon("hand-holding-dollar")),
      menuItem("Confianza institucional", tabName = "confianza", icon = icon("landmark")),
      menuItem("Confianza vs. donación", tabName = "confvsdon", icon = icon("magnifying-glass-chart")),
      menuItem("Experiencia previa", tabName = "experiencia", icon = icon("clock-rotate-left")),
      menuItem("Razones", tabName = "razones", icon = icon("comment-dots")),
      menuItem("Capacidad y liderazgo", tabName = "capacidad", icon = icon("people-group")),
      menuItem("Tabla de datos", tabName = "tabla", icon = icon("table"))
    ),
    hr(style = "border-color: #4b6584;"),
    h4(" Filtros globales", style = "padding-left: 15px; color: white;"),

    sliderInput(
      "f_edad", "Rango de edad:",
      min = min(datos$edad), max = max(datos$edad),
      value = c(min(datos$edad), max(datos$edad)), step = 1
    ),

    pickerInput(
      "f_genero", "Género:",
      choices = sort(unique(datos$genero)), selected = sort(unique(datos$genero)),
      multiple = TRUE, options = list(`actions-box` = TRUE, `live-search` = TRUE)
    ),

    pickerInput(
      "f_vinculo", "Vínculo con la institución:",
      choices = sort(unique(datos$vinculo_universidad)), selected = sort(unique(datos$vinculo_universidad)),
      multiple = TRUE, options = list(`actions-box` = TRUE)
    ),

    prettyCheckboxGroup(
      "f_experiencia", "Experiencia previa de donación:",
      choices = c("Con experiencia previa", "Sin experiencia previa"),
      selected = c("Con experiencia previa", "Sin experiencia previa"),
      status = "info", icon = icon("check")
    ),

    prettyCheckboxGroup(
      "f_exp_emergencia", "Experiencia previa con emergencias reales:",
      choiceNames = c("Sí", "No"), choiceValues = c("si", "no"),
      selected = c("si", "no"), status = "warning", icon = icon("check")
    ),

    pickerInput(
      "f_causa", "Causa donada previamente:",
      choices = sort(unique(datos$causa_donacion)), selected = sort(unique(datos$causa_donacion)),
      multiple = TRUE, options = list(`actions-box` = TRUE, `live-search` = TRUE)
    ),

    sliderInput(
      "f_confianza_campana", "Confianza en la campaña (0-10):",
      min = 0, max = 10, value = c(0, 10)
    ),

    sliderInput(
      "f_monto", "Monto dispuesto a donar (COP):",
      min = 0, max = max(datos$monto_donacion_num), value = c(0, max(datos$monto_donacion_num)),
      step = 5000, pre = "$"
    ),

    pickerInput(
      "f_instituciones", "Instituciones a comparar:",
      choices = unname(etiquetas_instituciones), selected = unname(etiquetas_instituciones),
      multiple = TRUE, options = list(`actions-box` = TRUE)
    ),

    prettyRadioButtons(
      "f_donaria", "Disposición a donar a la campaña:",
      choices = c("Todos", "Sí donaría", "No donaría"),
      selected = "Todos", status = "success", shape = "round"
    ),

    br(),
    actionButton(
      "f_reset", "Restablecer filtros", icon = icon("rotate-left"),
      style = "margin-left: 15px; background-color:#E74C3C; color:white; border:none;"
    ),
    br(), br()
  ),

  dashboardBody(
    tags$head(tags$style(HTML("
      .content-wrapper { background-color: #f4f6f9; }
      .box { border-top: 3px solid #2C3E50; border-radius: 8px; }
      .small-box { border-radius: 10px; }
      .skin-blue .main-header .logo { font-weight: bold; }
    "))),

    tabItems(

      # ---------- PESTAÑA 1: INICIO Y PERFIL ----------
      tabItem(
        tabName = "inicio",
        fluidRow(
          box(
            title = "Escenario de la encuesta", status = "primary", solidHeader = TRUE, width = 12,
            p(
              "Durante las últimas semanas, las fuertes lluvias provocaron el desbordamiento de varios ríos ",
              "en un municipio colombiano. Cerca de 800 familias tuvieron que abandonar sus viviendas y parte ",
              "de la infraestructura local resultó afectada. Se ha iniciado una campaña para recaudar recursos ",
              "destinados a alimentación, alojamiento temporal y reconstrucción."
            ),
            p(strong("Pregunta general: "), "¿qué hace que una persona confíe lo suficiente en una campaña de ayuda para decidir donar?"),
            p(em("Dimensión del grupo: Confianza institucional. Encuesta anónima y voluntaria, propósito exclusivamente académico."))
          )
        ),
        fluidRow(
          valueBoxOutput("kpi_n", width = 3),
          valueBoxOutput("kpi_edad", width = 3),
          valueBoxOutput("kpi_donaria", width = 3),
          valueBoxOutput("kpi_monto", width = 3)
        ),
        fluidRow(
          box(title = "Distribución de edad", status = "primary", solidHeader = TRUE, width = 12,
              plotlyOutput("plot_edad", height = 420))
        ),
        fluidRow(
          box(title = "Género", status = "info", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_genero", height = 400)),
          box(title = "Vínculo institucional", status = "info", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_vinculo", height = 400))
        )
      ),

      # ---------- PESTAÑA 2: DISPOSICIÓN A DONAR ----------
      tabItem(
        tabName = "donacion",
        fluidRow(
          valueBoxOutput("kpi_si", width = 3),
          valueBoxOutput("kpi_no", width = 3),
          valueBoxOutput("kpi_mediana", width = 3),
          valueBoxOutput("kpi_sd", width = 3)
        ),
        fluidRow(
          box(title = "¿Estaría dispuesto(a) a donar?", status = "success", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_donaria", height = 420)),
          box(title = "Distribución del monto ofrecido", status = "success", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_monto_hist", height = 420))
        ),
        fluidRow(
          box(
            title = "Comparar disposición / monto según otra variable", status = "success", solidHeader = TRUE,
            width = 12,
            selectInput(
              "var_comparacion", "Comparar monto donado según:",
              width = "400px",
              choices = c(
                "Experiencia previa de donación" = "experiencia_previa",
                "Género" = "genero",
                "Confianza en la campaña (0-10)" = "confianza_campana",
                "Probabilidad percibida de que llegue la ayuda" = "prob_llegada_recursos",
                "Vínculo institucional" = "vinculo_universidad"
              )
            ),
            plotlyOutput("plot_comparacion_monto", height = 620)
          )
        ),
        fluidRow(
          box(title = "Monto donado vs. confianza en la campaña, por género", status = "success",
              solidHeader = TRUE, width = 6, plotlyOutput("scatter_monto_genero", height = 460)),
          box(title = "¿Compartiría la campaña?", status = "success", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_compartiria", height = 460))
        )
      ),

      # ---------- PESTAÑA 3: CONFIANZA INSTITUCIONAL ----------
      tabItem(
        tabName = "confianza",
        fluidRow(
          box(
            title = "Confianza promedio por institución (0 a 10)", status = "warning", solidHeader = TRUE,
            width = 12,
            p("Calculada dinámicamente sobre las observaciones que cumplen los filtros seleccionados (usa el selector de instituciones del panel izquierdo)."),
            plotlyOutput("plot_confianza_inst", height = 480)
          )
        ),
        fluidRow(
          box(title = "Mapa de calor: correlación entre niveles de confianza", status = "warning",
              solidHeader = TRUE, width = 6, plotlyOutput("heatmap_corr", height = 420)),
          box(title = "Tabla resumen por institución (n, promedio, desviación)", status = "warning",
              solidHeader = TRUE, width = 6, DTOutput("tabla_confianza"))
        ),
        fluidRow(
          box(
            title = "¿Confianza vs. capacidad y liderazgo percibidos?", status = "warning", solidHeader = TRUE,
            width = 12,
            p(
              "El informe encuentra que las universidades reciben la mayor confianza promedio, pero el ",
              "Gobierno Nacional es percibido como el actor con mayor capacidad técnica/logística y también ",
              "como el que debería liderar la entrega de ayudas. Este gráfico permite verificar ese contraste ",
              "con el subconjunto de datos filtrado."
            ),
            plotlyOutput("plot_confianza_vs_capacidad", height = 650)
          )
        )
      ),

      # ---------- PESTAÑA 4: CONFIANZA VS DISPOSICIÓN A DONAR ----------
      tabItem(
        tabName = "confvsdon",
        fluidRow(
          box(
            title = "Nota metodológica", status = "danger", solidHeader = TRUE, width = 12,
            p(strong("Estos gráficos muestran asociaciones descriptivas y no permiten establecer causalidad."),
              " La encuesta de esta primera etapa no corresponde al experimento; la causalidad se explorará en la segunda entrega.")
          )
        ),
        fluidRow(
          box(title = "Confianza en la campaña vs. monto donado", status = "primary", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_confianza_monto", height = 440)),
          box(title = "Confianza en la campaña vs. disposición a donar", status = "primary", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_confianza_donaria", height = 440))
        ),
        fluidRow(
          box(
            title = "Probabilidad percibida de que la ayuda llegue vs. monto donado", status = "primary",
            solidHeader = TRUE, width = 12,
            plotlyOutput("plot_prob_monto", height = 460)
          )
        ),
        fluidRow(
          box(
            title = "Confianza en la campaña vs. probabilidad percibida, según disposición a donar",
            status = "primary", solidHeader = TRUE, width = 12,
            plotlyOutput("scatter_confianza_prob", height = 460)
          )
        )
      ),

      # ---------- PESTAÑA 5: EXPERIENCIA PREVIA ----------
      tabItem(
        tabName = "experiencia",
        fluidRow(
          box(
            title = "Con experiencia previa de donación vs. sin experiencia previa", status = "info",
            solidHeader = TRUE, width = 12,
            p("Comparación descriptiva; una diferencia entre grupos no implica que la experiencia previa cause una mayor disposición a donar."),
            tableOutput("tabla_experiencia")
          )
        ),
        fluidRow(
          box(title = "Frecuencia de donaciones", status = "info", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_frecuencia_donacion", height = 440)),
          box(title = "Causa apoyada previamente (o \"no aplica\" si no tiene experiencia)", status = "info",
              solidHeader = TRUE, width = 6, plotlyOutput("plot_causa_donacion", height = 440))
        ),
        fluidRow(
          box(
            title = "Confianza institucional según experiencia previa con EMERGENCIAS REALES (por institución)",
            status = "info", solidHeader = TRUE, width = 12,
            p("Esta es una variable distinta a la experiencia previa de donación: aquí se compara a quienes ya han vivido una emergencia real."),
            plotlyOutput("box_experiencia_emergencia", height = 520)
          )
        )
      ),

      # ---------- PESTAÑA 6: RAZONES PARA DONAR / NO DONAR ----------
      tabItem(
        tabName = "razones",
        fluidRow(
          box(
            title = "Palabras más frecuentes en la razón para donar o no donar", status = "warning",
            solidHeader = TRUE, width = 12,
            p("Según el filtro de disposición a donar activo en el panel izquierdo.")
          )
        ),
        fluidRow(
          box(title = "Razones de quienes SÍ donarían", status = "success", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_palabras_si", height = 500)),
          box(title = "Razones de quienes NO donarían", status = "danger", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_palabras_no", height = 500))
        )
      ),

      # ---------- PESTAÑA 7: CAPACIDAD Y LIDERAZGO ----------
      tabItem(
        tabName = "capacidad",
        fluidRow(
          box(title = "¿Quién tiene mayor capacidad técnica/logística?", status = "primary", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_capacidad", height = 460)),
          box(title = "¿Quién debería liderar la entrega de ayudas?", status = "primary", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_liderazgo", height = 460))
        ),
        fluidRow(
          box(
            title = "Confianza vs. capacidad percibida (¿coinciden?) — vista de dispersión", status = "primary",
            solidHeader = TRUE, width = 12,
            p("Cada punto es una institución: eje X = confianza promedio, eje Y = veces elegida como la de mayor capacidad técnica/logística."),
            plotlyOutput("scatter_confianza_capacidad", height = 480)
          )
        )
      ),

      # ---------- PESTAÑA 8: TABLA DE DATOS ----------
      tabItem(
        tabName = "tabla",
        fluidRow(
          box(
            title = "Datos filtrados (fila = un participante)", status = "primary", solidHeader = TRUE, width = 12,
            downloadButton("descargar_csv", "Descargar datos filtrados (.csv)",
                           style = "margin-bottom: 15px; background-color:#2C3E50; color:white;"),
            DTOutput("tabla_datos")
          )
        )
      )
    )
  )
)

# ------------------------------------------------------------------------------
# 4. LÓGICA DEL SERVIDOR
# ------------------------------------------------------------------------------
server <- function(input, output, session) {

  # --- Botón para restablecer todos los filtros a su estado inicial ---
  observeEvent(input$f_reset, {
    updateSliderInput(session, "f_edad", value = c(min(datos$edad), max(datos$edad)))
    updatePickerInput(session, "f_genero", selected = sort(unique(datos$genero)))
    updatePickerInput(session, "f_vinculo", selected = sort(unique(datos$vinculo_universidad)))
    updatePrettyCheckboxGroup(session, "f_experiencia", selected = c("Con experiencia previa", "Sin experiencia previa"))
    updatePrettyCheckboxGroup(session, "f_exp_emergencia", selected = c("si", "no"))
    updatePickerInput(session, "f_causa", selected = sort(unique(datos$causa_donacion)))
    updateSliderInput(session, "f_confianza_campana", value = c(0, 10))
    updateSliderInput(session, "f_monto", value = c(0, max(datos$monto_donacion_num)))
    updatePickerInput(session, "f_instituciones", selected = unname(etiquetas_instituciones))
    updatePrettyRadioButtons(session, "f_donaria", selected = "Todos")
  })

  # --- Data reactiva: aplica TODOS los filtros globales ---
  datos_filtrados <- reactive({
    req(input$f_genero, input$f_vinculo, input$f_experiencia, input$f_exp_emergencia, input$f_causa)
    df <- datos %>%
      filter(
        edad >= input$f_edad[1], edad <= input$f_edad[2],
        genero %in% input$f_genero,
        vinculo_universidad %in% input$f_vinculo,
        experiencia_previa %in% input$f_experiencia,
        experiencia_emergencia %in% input$f_exp_emergencia,
        causa_donacion %in% input$f_causa,
        confianza_campana >= input$f_confianza_campana[1],
        confianza_campana <= input$f_confianza_campana[2],
        monto_donacion_num >= input$f_monto[1],
        monto_donacion_num <= input$f_monto[2]
      )

    if (input$f_donaria == "Sí donaría") df <- df %>% filter(donaria == "si")
    if (input$f_donaria == "No donaría") df <- df %>% filter(donaria == "no")

    df
  })

  # Aviso reutilizable cuando el filtro deja la muestra vacía
  requerir_datos <- function(df) {
    validate(need(nrow(df) > 0, "No hay observaciones que cumplan los filtros seleccionados."))
  }

  # ---------------- KPIs: Inicio ----------------
  output$kpi_n <- renderValueBox({
    valueBox(nrow(datos_filtrados()), "Observaciones (filtro actual)", icon = icon("users"), color = "blue")
  })
  output$kpi_edad <- renderValueBox({
    df <- datos_filtrados(); requerir_datos(df)
    valueBox(paste(round(mean(df$edad), 1), "años"), "Edad promedio", icon = icon("cake-candles"), color = "navy")
  })
  output$kpi_donaria <- renderValueBox({
    df <- datos_filtrados(); requerir_datos(df)
    valueBox(percent(mean(df$donaria == "si"), accuracy = 0.1), "% dispuesto a donar",
             icon = icon("hand-holding-heart"), color = "green")
  })
  output$kpi_monto <- renderValueBox({
    df <- datos_filtrados(); requerir_datos(df)
    valueBox(dollar(mean(df$monto_donacion_num), prefix = "$"), "Monto promedio ofrecido",
             icon = icon("coins"), color = "yellow")
  })

  # ---------------- Gráficos: Inicio y perfil ----------------
  output$plot_edad <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    rango_edad <- range(df$edad)
    cortes_eje <- pretty(rango_edad, n = 10)
    p <- ggplot(df, aes(x = edad)) +
      geom_histogram(binwidth = 1, boundary = 0, fill = paleta[3], color = "white") +
      scale_x_continuous(breaks = cortes_eje) +
      labs(x = "Edad", y = "Número de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>% layout(margin = margen_amplio)
  })

  output$plot_genero <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    resumen <- df %>% count(genero) %>% mutate(pct = n / sum(n))
    p <- ggplot(resumen, aes(x = reorder(genero, n), y = n, fill = genero,
                              text = paste0(genero, ": ", n, " (", percent(pct, 0.1), ")"))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = paleta_extendida) +
      labs(x = NULL, y = "Número de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE) %>%
      layout(margin = margen_amplio, showlegend = FALSE)
  })

  output$plot_vinculo <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    resumen <- df %>% count(vinculo_universidad) %>% mutate(pct = n / sum(n))
    p <- ggplot(resumen, aes(x = reorder(vinculo_universidad, n), y = n, fill = vinculo_universidad,
                              text = paste0(vinculo_universidad, ": ", n, " (", percent(pct, 0.1), ")"))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = paleta_extendida) +
      labs(x = NULL, y = "Número de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE) %>%
      layout(margin = margen_amplio, showlegend = FALSE)
  })

  # ---------------- KPIs: Disposición a donar ----------------
  output$kpi_si <- renderValueBox({
    df <- datos_filtrados(); requerir_datos(df)
    valueBox(percent(mean(df$donaria == "si"), 0.1), "Sí donaría", icon = icon("check"), color = "green")
  })
  output$kpi_no <- renderValueBox({
    df <- datos_filtrados(); requerir_datos(df)
    valueBox(percent(mean(df$donaria == "no"), 0.1), "No donaría", icon = icon("xmark"), color = "red")
  })
  output$kpi_mediana <- renderValueBox({
    df <- datos_filtrados(); requerir_datos(df)
    valueBox(dollar(median(df$monto_donacion_num), prefix = "$"), "Monto mediano",
             icon = icon("scale-balanced"), color = "blue")
  })
  output$kpi_sd <- renderValueBox({
    df <- datos_filtrados(); requerir_datos(df)
    valueBox(dollar(sd(df$monto_donacion_num), prefix = "$"), "Desviación estándar del monto",
             icon = icon("chart-line"), color = "purple")
  })

  # ---------------- Gráficos: Disposición a donar ----------------
  output$plot_donaria <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    resumen <- df %>% count(donaria_lbl)
    plot_ly(
      resumen, labels = ~donaria_lbl, values = ~n, type = "pie", hole = 0.55,
      marker = list(colors = c("Sí donaría" = color_si, "No donaría" = color_no)[resumen$donaria_lbl],
                    line = list(color = "white", width = 2)),
      textinfo = "label+percent", hoverinfo = "text",
      text = ~paste0(donaria_lbl, ": ", n, " participantes")
    ) %>%
      layout(showlegend = TRUE, margin = margen_amplio) %>%
      config(displayModeBar = FALSE)
  })

  output$plot_monto_hist <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    p <- ggplot(df, aes(x = monto_donacion_num)) +
      geom_histogram(binwidth = 5000, fill = color_si, color = "white") +
      scale_x_continuous(labels = dollar_format(prefix = "$")) +
      labs(x = "Monto que estaría dispuesto a donar", y = "Número de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>% layout(margin = margen_amplio)
  })

  output$plot_comparacion_monto <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    var <- input$var_comparacion

    if (var == "confianza_campana") {
      p <- ggplot(df, aes(x = confianza_campana, y = monto_donacion_num)) +
        geom_jitter(width = 0.15, alpha = 0.7, color = paleta[3]) +
        geom_smooth(method = "lm", se = FALSE, color = paleta[2]) +
        scale_y_continuous(labels = dollar_format(prefix = "$")) +
        labs(x = "Confianza en la campaña (0-10)", y = "Monto donado") +
        theme_minimal(base_size = 13)
      ggplotly(p) %>% config(displayModeBar = FALSE) %>% layout(margin = margen_amplio)
    } else {
      df$grupo <- as.factor(df[[var]])
      p <- ggplot(df, aes(x = grupo, y = monto_donacion_num, fill = grupo)) +
        geom_boxplot(show.legend = FALSE) +
        scale_fill_manual(values = paleta_extendida) +
        scale_y_continuous(labels = dollar_format(prefix = "$")) +
        labs(x = NULL, y = "Monto donado") +
        theme_minimal(base_size = 13) +
        theme(axis.text.x = element_text(angle = 30, hjust = 1))
      ggplotly(p) %>% config(displayModeBar = FALSE) %>%
        layout(margin = list(l = 90, r = 40, b = 160, t = 60, pad = 6), showlegend = FALSE)
    }
  })

  output$scatter_monto_genero <- renderPlotly({
    df <- datos_filtrados() %>% filter(donaria == "si")
    requerir_datos(df)
    p <- ggplot(df, aes(x = confianza_campana, y = monto_donacion_num, color = genero)) +
      geom_jitter(width = 0.2, size = 2.5, alpha = 0.75) +
      geom_smooth(method = "lm", se = FALSE, color = paleta[1], linetype = "dashed") +
      scale_color_manual(values = paleta_extendida) +
      scale_y_continuous(labels = dollar_format(prefix = "$")) +
      labs(x = "Confianza en la campaña (0-10)", y = "Monto donado", color = "Género") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>% layout(margin = margen_amplio)
  })

  output$plot_compartiria <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    resumen <- df %>% count(compartiria_campana) %>% mutate(pct = n / sum(n))
    p <- ggplot(resumen, aes(x = reorder(str_to_sentence(compartiria_campana), n), y = n, fill = compartiria_campana,
                              text = paste0(str_to_sentence(compartiria_campana), ": ", n, " (", percent(pct, 0.1), ")"))) +
      geom_col(show.legend = FALSE) +
      scale_fill_manual(values = paleta_extendida) +
      labs(x = NULL, y = "Número de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE) %>%
      layout(margin = margen_amplio, showlegend = FALSE)
  })

  # ---------------- Confianza institucional ----------------
  datos_confianza_larga <- reactive({
    df <- datos_filtrados(); requerir_datos(df)
    req(input$f_instituciones)
    df %>%
      select(names(etiquetas_instituciones)) %>%
      pivot_longer(everything(), names_to = "institucion", values_to = "confianza") %>%
      mutate(institucion = etiquetas_instituciones[institucion]) %>%
      filter(institucion %in% input$f_instituciones) %>%
      group_by(institucion) %>%
      summarise(confianza_prom = mean(confianza), .groups = "drop") %>%
      arrange(desc(confianza_prom))
  })

  # Formato largo SIN resumir (una fila por participante x institución), para
  # el mapa de calor, la tabla resumen y el boxplot cruzado con emergencias.
  datos_confianza_larga_full <- reactive({
    df <- datos_filtrados(); requerir_datos(df)
    req(input$f_instituciones)
    df %>%
      select(all_of(names(etiquetas_instituciones)), experiencia_emergencia) %>%
      pivot_longer(cols = names(etiquetas_instituciones), names_to = "institucion", values_to = "confianza") %>%
      mutate(institucion = etiquetas_instituciones[institucion]) %>%
      filter(institucion %in% input$f_instituciones)
  })

  output$plot_confianza_inst <- renderPlotly({
    resumen <- datos_confianza_larga()
    p <- ggplot(resumen, aes(x = reorder(institucion, confianza_prom), y = confianza_prom, fill = institucion,
                              text = paste0(institucion, ": ", round(confianza_prom, 2)))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = paleta) +
      scale_y_continuous(limits = c(0, 10)) +
      labs(x = NULL, y = "Confianza promedio (0-10)") +
      theme_minimal(base_size = 13)
    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 170, r = 40, b = 90, t = 60, pad = 6), showlegend = FALSE)
  })

  output$plot_confianza_vs_capacidad <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)

    confianza <- datos_confianza_larga() %>% rename(entidad = institucion, valor = confianza_prom) %>%
      mutate(valor = valor / 10, indicador = "Confianza promedio (escala 0-1)")

    capacidad <- df %>% count(capacidad_institucion) %>%
      mutate(entidad = etiquetas_cap_lider[capacidad_institucion], valor = n / sum(n),
             indicador = "% que la ve con mayor capacidad") %>%
      filter(!is.na(entidad)) %>% select(entidad, valor, indicador)

    liderazgo <- df %>% count(liderazgo_institucion) %>%
      mutate(entidad = etiquetas_cap_lider[liderazgo_institucion], valor = n / sum(n),
             indicador = "% que la ve como líder de la ayuda") %>%
      filter(!is.na(entidad)) %>% select(entidad, valor, indicador)

    comparacion <- bind_rows(confianza, capacidad, liderazgo)

    p <- ggplot(comparacion, aes(x = entidad, y = valor, fill = indicador,
                                  text = paste0(entidad, " - ", indicador, ": ", percent(valor, 0.1)))) +
      geom_col(position = "dodge") +
      scale_y_continuous(labels = percent_format(accuracy = 1)) +
      scale_fill_manual(values = c(
        "Confianza promedio (escala 0-1)" = paleta[1],
        "% que la ve con mayor capacidad" = paleta[5],
        "% que la ve como líder de la ayuda" = paleta[2]
      )) +
      labs(x = NULL, y = NULL, fill = NULL) +
      theme_minimal(base_size = 13) +
      theme(axis.text.x = element_text(angle = 30, hjust = 1), legend.position = "bottom")
    ggplotly(p, tooltip = "text") %>%
      config(displayModeBar = FALSE) %>%
      layout(
        legend = list(orientation = "h", x = 0, y = -0.55, xanchor = "left"),
        margin = list(l = 70, r = 40, b = 220, t = 60, pad = 6)
      )
  })

  output$heatmap_corr <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    cols_seleccionadas <- names(etiquetas_instituciones)[etiquetas_instituciones %in% input$f_instituciones]
    validate(need(length(cols_seleccionadas) >= 2, "Selecciona al menos dos instituciones en el panel izquierdo para calcular correlaciones."))
    mat <- df %>% select(all_of(cols_seleccionadas)) %>% cor(use = "complete.obs")
    colnames(mat) <- etiquetas_instituciones[colnames(mat)]
    rownames(mat) <- etiquetas_instituciones[rownames(mat)]
    plot_ly(
      x = colnames(mat), y = rownames(mat), z = mat, type = "heatmap",
      colors = colorRampPalette(c(paleta[5], "white", paleta[1]))(50), zmin = -1, zmax = 1
    ) %>%
      config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 140, r = 40, b = 140, t = 40, pad = 6))
  })

  output$tabla_confianza <- renderDT({
    df <- datos_confianza_larga_full()
    validate(need(nrow(df) > 0, "No hay datos con estos filtros."))
    df %>%
      group_by(institucion) %>%
      summarise(
        n = n(),
        promedio = round(mean(confianza, na.rm = TRUE), 2),
        desviacion = round(sd(confianza, na.rm = TRUE), 2),
        .groups = "drop"
      ) %>%
      arrange(desc(promedio)) %>%
      rename(Institución = institucion, N = n, Promedio = promedio, `Desv. estándar` = desviacion) %>%
      datatable(options = list(dom = "t", pageLength = 8), rownames = FALSE)
  })

  # ---------------- Confianza vs. disposición a donar ----------------
  output$plot_confianza_monto <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    p <- ggplot(df, aes(x = confianza_campana, y = monto_donacion_num)) +
      geom_jitter(width = 0.15, alpha = 0.7, color = paleta[3]) +
      geom_smooth(method = "lm", se = FALSE, color = paleta[2]) +
      scale_y_continuous(labels = dollar_format(prefix = "$")) +
      labs(x = "Confianza en la campaña (0-10)", y = "Monto donado") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>% layout(margin = margen_amplio)
  })

  output$plot_confianza_donaria <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    p <- ggplot(df, aes(x = donaria_lbl, y = confianza_campana, fill = donaria_lbl)) +
      geom_boxplot(show.legend = FALSE) +
      scale_fill_manual(values = c("Sí donaría" = color_si, "No donaría" = color_no)) +
      labs(x = NULL, y = "Confianza en la campaña (0-10)") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>%
      layout(margin = margen_amplio, showlegend = FALSE)
  })

  output$plot_prob_monto <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    p <- ggplot(df, aes(x = prob_llegada_punto_medio, y = monto_donacion_num)) +
      geom_jitter(width = 3, alpha = 0.7, color = paleta[3]) +
      geom_smooth(method = "lm", se = FALSE, color = paleta[2]) +
      scale_x_continuous(labels = function(x) paste0(x, "%")) +
      scale_y_continuous(labels = dollar_format(prefix = "$")) +
      labs(x = "Probabilidad percibida de que la ayuda llegue (punto medio del rango)", y = "Monto donado") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 90, r = 40, b = 130, t = 60, pad = 6))
  })

  output$scatter_confianza_prob <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    p <- ggplot(df, aes(x = prob_llegada_recursos, y = confianza_campana, color = donaria_lbl)) +
      geom_jitter(width = 0.15, height = 0.2, size = 2.5, alpha = 0.75) +
      scale_color_manual(values = c("Sí donaría" = color_si, "No donaría" = color_no)) +
      labs(x = "Probabilidad percibida de que lleguen los recursos", y = "Confianza en la campaña (0-10)",
           color = "¿Donaría?") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>% layout(margin = margen_amplio)
  })

  # ---------------- Experiencia previa ----------------
  output$tabla_experiencia <- renderTable({
    df <- datos_filtrados(); requerir_datos(df)
    df %>%
      group_by(experiencia_previa) %>%
      summarise(
        `Observaciones` = n(),
        `% dispuesto a donar` = percent(mean(donaria == "si"), 0.1),
        `Monto promedio` = dollar(mean(monto_donacion_num), prefix = "$"),
        `Confianza promedio en la campaña` = round(mean(confianza_campana), 2),
        `Prob. percibida promedio (punto medio, %)` = round(mean(prob_llegada_punto_medio, na.rm = TRUE), 1),
        .groups = "drop"
      ) %>%
      rename(`Grupo` = experiencia_previa)
  }, striped = TRUE, bordered = TRUE, width = "100%")

  output$plot_frecuencia_donacion <- renderPlotly({
    # Usa el filtro general (incluye a quienes no tienen experiencia previa,
    # cuya frecuencia queda registrada como "nunca").
    df <- datos_filtrados()
    requerir_datos(df)
    resumen <- df %>% count(frecuencia_donacion)
    p <- ggplot(resumen, aes(x = reorder(frecuencia_donacion, n), y = n, fill = frecuencia_donacion)) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = paleta_extendida) +
      labs(x = NULL, y = "Número de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 220, r = 40, b = 90, t = 60, pad = 6), showlegend = FALSE)
  })

  output$plot_causa_donacion <- renderPlotly({
    # Usa el filtro general (incluye a quienes no tienen experiencia previa,
    # cuya causa queda registrada como "no aplica").
    df <- datos_filtrados()
    requerir_datos(df)
    resumen <- df %>% count(causa_donacion)
    p <- ggplot(resumen, aes(x = reorder(causa_donacion, n), y = n, fill = causa_donacion)) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = paleta_extendida) +
      labs(x = NULL, y = "Número de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 140, r = 40, b = 90, t = 60, pad = 6), showlegend = FALSE)
  })

  output$box_experiencia_emergencia <- renderPlotly({
    df <- datos_confianza_larga_full()
    validate(need(nrow(df) > 0, "No hay datos con estos filtros."))
    df <- df %>% mutate(experiencia_emergencia_lbl = ifelse(experiencia_emergencia == "si", "Sí", "No"))
    p <- ggplot(df, aes(x = experiencia_emergencia_lbl, y = confianza, fill = experiencia_emergencia_lbl)) +
      geom_boxplot(show.legend = FALSE) +
      facet_wrap(~institucion) +
      scale_fill_manual(values = c("Sí" = paleta[3], "No" = paleta[2])) +
      labs(x = "¿Experiencia previa con emergencias reales?", y = "Confianza (0-10)") +
      theme_minimal(base_size = 12)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>%
      layout(margin = margen_amplio, showlegend = FALSE)
  })

  # ---------------- Razones para donar / no donar ----------------
  output$plot_palabras_si <- renderPlotly({
    df <- datos_filtrados() %>% filter(donaria == "si")
    resumen <- calcular_frecuencia_palabras(df$razon_donacion)
    validate(need(nrow(resumen) > 0, "No hay suficiente texto para analizar con este filtro."))
    p <- ggplot(resumen, aes(x = reorder(palabra, frecuencia), y = frecuencia)) +
      geom_col(fill = color_si) + coord_flip() +
      labs(x = NULL, y = "Frecuencia") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 140, r = 40, b = 90, t = 60, pad = 6))
  })

  output$plot_palabras_no <- renderPlotly({
    df <- datos_filtrados() %>% filter(donaria == "no")
    resumen <- calcular_frecuencia_palabras(df$razon_donacion)
    validate(need(nrow(resumen) > 0, "No hay suficiente texto para analizar con este filtro."))
    p <- ggplot(resumen, aes(x = reorder(palabra, frecuencia), y = frecuencia)) +
      geom_col(fill = color_no) + coord_flip() +
      labs(x = NULL, y = "Frecuencia") +
      theme_minimal(base_size = 13)
    ggplotly(p) %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 140, r = 40, b = 90, t = 60, pad = 6))
  })

  # ---------------- Capacidad y liderazgo institucional ----------------
  output$plot_capacidad <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    resumen <- df %>% count(capacidad_institucion) %>%
      mutate(entidad = etiquetas_cap_lider[capacidad_institucion], pct = n / sum(n)) %>%
      filter(!is.na(entidad))
    p <- ggplot(resumen, aes(x = reorder(entidad, pct), y = pct, fill = entidad,
                              text = paste0(entidad, ": ", percent(pct, 0.1)))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = paleta) +
      scale_y_continuous(labels = percent_format(accuracy = 1)) +
      labs(x = NULL, y = "% de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 180, r = 40, b = 90, t = 60, pad = 6), showlegend = FALSE)
  })

  output$plot_liderazgo <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    resumen <- df %>% count(liderazgo_institucion) %>%
      mutate(entidad = etiquetas_cap_lider[liderazgo_institucion], pct = n / sum(n)) %>%
      filter(!is.na(entidad))
    p <- ggplot(resumen, aes(x = reorder(entidad, pct), y = pct, fill = entidad,
                              text = paste0(entidad, ": ", percent(pct, 0.1)))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = rev(paleta)) +
      scale_y_continuous(labels = percent_format(accuracy = 1)) +
      labs(x = NULL, y = "% de participantes") +
      theme_minimal(base_size = 13)
    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE) %>%
      layout(margin = list(l = 180, r = 40, b = 90, t = 60, pad = 6), showlegend = FALSE)
  })

  output$scatter_confianza_capacidad <- renderPlotly({
    df <- datos_filtrados(); requerir_datos(df)
    ranking_confianza <- datos_confianza_larga()
    ranking_capacidad <- df %>% count(capacidad_institucion) %>%
      mutate(institucion = etiquetas_cap_lider[capacidad_institucion]) %>%
      filter(!is.na(institucion)) %>% select(institucion, n_capacidad = n)

    comb <- full_join(ranking_confianza, ranking_capacidad, by = "institucion") %>%
      mutate(n_capacidad = replace_na(n_capacidad, 0), confianza_prom = replace_na(confianza_prom, 0))
    validate(need(nrow(comb) > 0, "No hay datos con estos filtros."))

    p <- ggplot(comb, aes(x = confianza_prom, y = n_capacidad, color = institucion,
                           text = paste0(institucion, "\nConfianza: ", round(confianza_prom, 2),
                                         "\nVeces elegida como más capaz: ", n_capacidad))) +
      geom_point(size = 5) +
      scale_color_manual(values = paleta_extendida) +
      scale_x_continuous(limits = c(0, 10)) +
      labs(x = "Confianza promedio (0-10)", y = "N° de veces elegida como más capaz", color = NULL) +
      theme_minimal(base_size = 13)
    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE) %>% layout(margin = margen_amplio)
  })

  # ---------------- Tabla de datos ----------------
  output$tabla_datos <- renderDT({
    df <- datos_filtrados(); requerir_datos(df)
    df %>%
      select(
        edad, genero, vinculo_universidad, ha_donado, experiencia_previa,
        experiencia_emergencia, causa_donacion, donaria, monto_donacion_num,
        confianza_campana, prob_llegada_recursos, compartiria_campana,
        capacidad_institucion, liderazgo_institucion
      ) %>%
      rename(
        `Edad` = edad, `Género` = genero, `Vínculo` = vinculo_universidad,
        `Historial de donación` = ha_donado, `Experiencia previa` = experiencia_previa,
        `Vivió emergencia real` = experiencia_emergencia, `Causa donada antes` = causa_donacion,
        `¿Donaría?` = donaria, `Monto ($)` = monto_donacion_num,
        `Confianza en campaña (0-10)` = confianza_campana, `Prob. percibida` = prob_llegada_recursos,
        `Compartiría` = compartiria_campana, `Mayor capacidad` = capacidad_institucion,
        `Debería liderar` = liderazgo_institucion
      )
  }, filter = "top", options = list(pageLength = 10, scrollX = TRUE))

  output$descargar_csv <- downloadHandler(
    filename = function() paste0("datos_filtrados_A2_", Sys.Date(), ".csv"),
    content = function(file) write.csv(datos_filtrados(), file, row.names = FALSE)
  )
}

# ------------------------------------------------------------------------------
# 5. EJECUCIÓN DE LA APP
# ------------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
