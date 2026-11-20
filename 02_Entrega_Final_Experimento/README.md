# Entrega final — Experimento de confianza institucional

Experimento con encuesta (Google Forms, 27 de octubre – 12 de noviembre de 2026, **153 respuestas**). Cada persona leyó la misma campaña hipotética para 800 familias afectadas por una inundación; lo único que cambiaba era la institución que administraba los recursos: **alcaldía municipal** (49, grupo de referencia), **universidad pública** (47) o **universidad privada** (57).

## Contenido

| Carpeta | Archivo | Qué es |
|---|---|---|
| `Data/` | `Base_Datos_Entrega_Final.xlsx` | Base original exportada del formulario (153 filas, 21 columnas) |
| | `Base_Datos_Entrega_Final.csv` | La misma base en CSV (UTF-8) |
| | `datos_analisis.csv` | Variables usadas en el análisis, generada por el código |
| `Encuesta/` | `Cuestionario_Experimento.md` | Preguntas textuales, opciones y regla de asignación de versiones |
| `Codigo/` | `Analisis_Donaciones_Grupo_A2.Rmd` | Código en R: limpieza, gráficas, regresiones y pruebas |
| | `Analisis_Donaciones_Grupo_A2.html` | Resultado del código (tablas y gráficas) |
| `Graficas/` | `01` a `07` `.png` | Gráficas del análisis a 300 dpi |
| `Documentos/` | `Poster_The_Econometrics_Times_A2.pdf` | Póster A3 |
| | `Blog_Confianza_Institucional_A2` | Blog (`.pdf` y `.docx`) |
| | `Informe_Final_Confianza_Institucional_A2` | Informe (`.pdf` y `.docx`) |

## Variables de `datos_analisis.csv`

| Variable | Tipo | Descripción |
|---|---|---|
| `institucion` | Factor | Alcaldía (base) · U. pública · U. privada |
| `monto` | COP | Monto que donaría la persona (0 si no donaría) |
| `dona` | 0/1 | 1 si `monto` > 0 |
| `confianza` | 0–10 | Confianza que le genera la campaña |
| `prob_llegada` | 0–100 | Probabilidad percibida de que la ayuda llegue a las familias |
| `estudiante` | 0/1 | 1 si es estudiante de pregrado o posgrado |
| `edad` | Años | Edad cumplida |
| `genero` | Texto | Mujer · Hombre · No binario u otro · Prefiero no responder |
| `mujer` | 0/1 | 1 si se identifica como mujer |
| `experiencia` | 0/1 | 1 si donó dinero, bienes o tiempo en los últimos 12 meses |

## Estrategia de análisis

1. **Separar los datos:** 41 respuestas con $0 y **112 con monto positivo**; las regresiones usan las 112.
2. **Regresión normal (MCO)** del monto contra las dummies `U. pública` y `U. privada` (base: alcaldía), sin y con controles (estudiante, edad, mujer, experiencia). La misma especificación se usa para confianza y probabilidad de llegada.
3. **Interacciones:** institución × estudiante (principal) e institución × experiencia.
4. **Regresiones por grupos:** estudiantes / no estudiantes, con / sin experiencia, mujeres / hombres.
5. **Datos escalados:** monto y edad estandarizados con `scale()`.
6. **Pruebas:** t individuales, F conjunta, U. pública = U. privada y F de interacciones. Todos los errores son **robustos HC1** (Breusch-Pagan p = 0,078; la desviación estándar del monto va de $53.620 a $353.914 según el grupo).

## Notas sobre los datos

- La interacción institución × experiencia **no se puede estimar con precisión**: en la U. privada solo hay 1 donante sin experiencia previa. Está en el código, pero no se usa en las conclusiones.
- Seis montos son muy bajos ($20, $20, $50, $100, $100 y $500); se conservaron tal como se registraron.
- Identificó correctamente la institución que vio el 83 % de la versión U. pública, el 69 % de la de alcaldía y el 88 % de la de U. privada. No se excluyó a nadie.
