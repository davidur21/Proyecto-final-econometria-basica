# Scripts

Contiene el código de procesamiento de datos, separado del tablero Shiny para mantener trazabilidad.

- **limpieza_datos.R** toma `Data/datos_crudos.csv`, renombra columnas (ej. los encabezados largos de la cuadrícula de Forms a `conf_alcaldia`, `conf_gob_nacional`, etc.), corrige tipos de dato y exporta `Data/datos_limpios.csv`.

Para reproducir: correr este script antes de abrir `Shiny_App/app.R`.
