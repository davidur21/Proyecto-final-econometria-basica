# Entrega 1 — Encuesta exploratoria

Primera etapa del proyecto: encuesta sobre confianza en distintas instituciones ante una emergencia hipotética, que sirvió para plantear la hipótesis del experimento final.

| Carpeta | Archivo | Qué es |
|---|---|---|
| `Data/` | `datos_encuesta_sucia.csv` | Export directo de Google Sheets, sin modificar |
| | `datos_encuesta.csv` | Base procesada (nombres estandarizados, tipos corregidos) |
| `Encuesta/` | `Encuesta_A2_Confianza_Institucional.md` | Diseño del cuestionario y uso econométrico de cada pregunta · [formulario](https://forms.gle/gT5WKYUj8LBdzNwAA) |
| `Shiny_App/` | `app.R` | Tablero interactivo en Shiny |
| `Reporte/` | `Informe_Entrega_1_Econometría.pdf` | Reporte de hallazgos preliminares |

## Cómo correr el tablero

Abrir `Shiny_App/app.R` en RStudio y dar clic en **Run App**. El tablero lee `../Data/datos_encuesta.csv`, así que hay que mantener la estructura de carpetas. Paquetes: `shiny`, `shinydashboard`, `shinyWidgets`, `ggplot2`, `dplyr`, `tidyr`, `plotly`, `DT`, `scales`, `stringr`.

No se recolectaron nombres, documentos, correos ni datos que permitan identificar a los participantes.
