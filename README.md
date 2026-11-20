# Confianza institucional y donaciones

**Proyecto final · Econometría Básica 2026-II · Universidad del Rosario · Grupo A2**

¿Cambia la institución que administra una campaña de ayuda (alcaldía, universidad pública o universidad privada) cuánto dona la gente y cuánta confianza le genera? Para responderlo hicimos un experimento con encuesta: tres versiones de la misma campaña hipotética para 800 familias afectadas por una inundación, en las que solo cambia quién maneja la plata.

**Integrantes:** Kevin Alexander Carrillo Garzón · David Steven Pascagaza Rodríguez · Luna Valentina Pinilla Malaver · Tomás Rangel Palacio · Luis Fernando Rodríguez Guevara

---

## Entrega final

| Entregable | Archivo |
|---|---|
| Póster (A3) | [`Poster_The_Econometrics_Times_A2.pdf`](02_Entrega_Final_Experimento/Documentos/Poster_The_Econometrics_Times_A2.pdf) |
| Blog | [`Blog_Confianza_Institucional_A2.pdf`](02_Entrega_Final_Experimento/Documentos/Blog_Confianza_Institucional_A2.pdf) · [`.docx`](02_Entrega_Final_Experimento/Documentos/Blog_Confianza_Institucional_A2.docx) |
| Informe | [`Informe_Final_Confianza_Institucional_A2.pdf`](02_Entrega_Final_Experimento/Documentos/Informe_Final_Confianza_Institucional_A2.pdf) · [`.docx`](02_Entrega_Final_Experimento/Documentos/Informe_Final_Confianza_Institucional_A2.docx) |
| Código en R | [`Analisis_Donaciones_Grupo_A2.Rmd`](02_Entrega_Final_Experimento/Codigo/Analisis_Donaciones_Grupo_A2.Rmd) · [resultado `.html`](02_Entrega_Final_Experimento/Codigo/Analisis_Donaciones_Grupo_A2.html) |
| Base de datos | [`Base_Datos_Entrega_Final.xlsx`](02_Entrega_Final_Experimento/Data/Base_Datos_Entrega_Final.xlsx) · [`.csv`](02_Entrega_Final_Experimento/Data/Base_Datos_Entrega_Final.csv) |
| Cuestionario | [`Cuestionario_Experimento.md`](02_Entrega_Final_Experimento/Encuesta/Cuestionario_Experimento.md) |

## Resultados principales

| | Alcaldía *(base)* | U. pública | U. privada |
|---|---|---|---|
| Respuestas | 49 | 47 | 57 |
| Donan un monto > $0 | 73,5 % | 68,1 % | 77,2 % |
| Mediana entre donantes | $40.000 | $40.000 | $40.000 |
| Confianza en la campaña (0–10) | 5,94 | 6,81 | 7,02 |
| Prob. de que la ayuda llegue (0–100) | 56,2 | 64,7 | 63,8 |

MCO sobre los 112 donantes, base alcaldía, con controles y errores robustos HC1:

| Variable dependiente | U. pública | U. privada | Prueba F (p) |
|---|---|---|---|
| Monto (COP) | −47.450 (p = 0,321) | +60.458 (p = 0,511) | 0,189 |
| Confianza (0–10) | +0,73 (p = 0,244) | +1,10 (p = 0,058) | 0,165 |
| Prob. de que la ayuda llegue | +6,65 (p = 0,247) | +7,37 (p = 0,182) | 0,367 |

- **No hay evidencia de que la institución cambie cuánto dona la gente.**
- La alcaldía genera algo menos de confianza y menor expectativa de que la ayuda llegue, pero sin significancia estadística.
- La interacción institución × estudiante no es significativa (F p = 0,161).
- Lo que más se asocia con donar es haber donado antes: dona el 81,1 % de quienes donaron en el último año, frente al 41,9 % de quienes no.

Todas las cifras del póster, el blog y el informe salen del mismo código en R y coinciden entre sí.

## Estructura del repositorio

```
Proyecto-final-econometria-basica/
├── README.md
├── 01_Entrega_1_Encuesta_Exploratoria/      Primera entrega (encuesta exploratoria)
│   ├── Data/          datos_encuesta_sucia.csv · datos_encuesta.csv
│   ├── Encuesta/      Encuesta_A2_Confianza_Institucional.md
│   ├── Shiny_App/     app.R (tablero interactivo)
│   └── Reporte/       Informe_Entrega_1_Econometría.pdf
└── 02_Entrega_Final_Experimento/            Entrega final (experimento)
    ├── Data/          Base_Datos_Entrega_Final.xlsx · .csv · datos_analisis.csv
    ├── Encuesta/      Cuestionario_Experimento.md
    ├── Codigo/        Analisis_Donaciones_Grupo_A2.Rmd · .html
    ├── Graficas/      7 gráficas en PNG (300 dpi)
    └── Documentos/    Póster · Blog · Informe
```

## Cómo reproducir los resultados

1. Descargar o clonar el repositorio.
2. Abrir `02_Entrega_Final_Experimento/Codigo/Analisis_Donaciones_Grupo_A2.Rmd` en RStudio.
3. Darle **Knit**. Los paquetes que falten se instalan solos (`readxl`, `dplyr`, `ggplot2`, `scales`, `sandwich`, `lmtest`, `car`, `stargazer`, `tidyr`).

El código lee la base desde `../Data/`, guarda las gráficas en `../Graficas/` y exporta `../Data/datos_analisis.csv`. Se probó con R 4.5.

## Nota

El escenario es hipotético y la muestra es por conveniencia (no representativa). La alcaldía se agregó después del prerregistro en AsPredicted (#318500), que solo incluía universidad pública y privada. Los resultados son asociativos. Parte del código y de los documentos se hizo con apoyo de Claude, con uso netamente académico.
