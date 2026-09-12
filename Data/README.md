# Data

Contiene la base de datos recolectada en la encuesta del Grupo A2 (Confianza institucional).

- **datos_encuesta_sucia.csv** — export directo de Google Sheets, sin ninguna modificación. Se conserva como respaldo del formulario original.
- **datos_encuesta.csv** — versión procesada a partir de `Scripts/limpieza_datos.R`: nombres de columna estandarizados, valores faltantes tratados y tipos de dato corregidos. Este es el archivo que alimenta el tablero Shiny.

No se recolectaron nombres, documentos, correos ni datos que permitan identificar a los participantes.

## Próximos avances

Para las siguientes entregas del proyecto, se ajustarán algunas variables a formato dummy o binario según se requiera para el análisis econométrico (por ejemplo, `dispuesto_donar` o `experiencia_institucional`), con el fin de facilitar su uso en modelos de regresión.
