# Scripts

Contiene el código de procesamiento de datos, separado del tablero Shiny para mantener trazabilidad.

- **limpieza_datos.R** — toma `Data/datos_encuesta_sucia.csv`, renombra columnas (ej. los encabezados largos de la cuadrícula de Forms a `conf_alcaldia`, `conf_gob_nacional`, etc.), corrige tipos de dato y exporta `Data/datos_encuesta.csv`.

Para reproducir: correr este script antes de abrir `Shiny_App/app.R`.

## Nota

El siguiente código se realizó en R con ayuda de Claude Pro. Su uso es netamente académico: tuvimos algunos inconvenientes técnicos al construir el tablero de Shiny y fue necesario apoyarnos en esta herramienta para resolverlos.
