# Scripts

Contiene el código de procesamiento de datos, separado del tablero Shiny para mantener trazabilidad.

- **limpieza_datos.R** — toma `Data/datos_encuesta_sucia.csv`, renombra columnas (ej. los encabezados largos de la cuadrícula de Forms a `conf_alcaldia`, `conf_gob_nacional`, etc.), corrige tipos de dato y exporta `Data/datos_encuesta.csv`.

Para reproducir: correr este script antes de abrir `Shiny_App/app.R`.

El tablero Shiny interactivo ya está listo dentro del código (`Shiny_App/app.R`) — solo hay que cargar las librerías correspondientes (`library(...)` al inicio del script) y darle clic en "Run App" en RStudio.

## Cómo correr el tablero

Hay dos formas de ejecutar el código:

1. **Copiando y pegando el código R** directamente en un script nuevo de RStudio (desde `Shiny_App/app.R`), y luego dándole clic en "Run App".
2. **Descargando el archivo `app.R`** directo desde este repositorio y abriéndolo en RStudio, para correrlo sin necesidad de copiar y pegar nada.

## Nota

El siguiente código se realizó en R con ayuda de Claude Pro. Su uso es netamente académico: tuvimos algunos inconvenientes técnicos al construir el tablero de Shiny y fue necesario apoyarnos en esta herramienta para resolverlos.
