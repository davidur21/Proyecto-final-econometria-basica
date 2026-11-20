# Cuestionario — Experimento final

**Proyecto:** Confianza institucional y donaciones · Econometría Básica 2026-II · Grupo A2
**Herramienta:** Google Forms · **Aplicación:** 27 de octubre – 12 de noviembre de 2026 · **Respuestas válidas:** 153

Las preguntas de este documento son las del formulario, copiadas textualmente de los encabezados de la base de datos (`Data/Base_Datos_Entrega_Final.xlsx`). Las opciones de respuesta son las que aparecen en los datos.

---

## Diseño experimental

Todas las personas leen el **mismo escenario hipotético**: una campaña para ayudar a **800 familias afectadas por una inundación** en un municipio colombiano. Lo único que cambia entre versiones es la **institución que administra los recursos**.

| Versión | Institución que administra la campaña | Último dígito del documento | Respuestas |
|---|---|---|---|
| 1 | Universidad pública | 1, 6, 9 | 47 |
| 2 | Alcaldía municipal *(grupo de referencia)* | 3, 4, 8 | 49 |
| 3 | Universidad privada | 0, 2, 5, 7 | 57 |

La versión se asigna con la pregunta del último dígito del documento de identidad (sección 3), que funciona como una regla de asignación casi aleatoria. En los datos, una persona con dígito 0 quedó en la versión de universidad pública.

> El escenario es **hipotético**: no corresponde a una emergencia ni a una campaña real.

---

## 1. Consentimiento y filtro

| # | Pregunta | Opciones |
|---|---|---|
| 1 | ¿Acepta participar voluntariamente en esta encuesta? | Sí, acepto participar |
| 2 | ¿Tiene 18 años o más? | Sí / No |

## 2. Datos de la persona

| # | Pregunta | Opciones | Variable en R |
|---|---|---|---|
| 3 | ¿Cuántos años cumplidos tiene? | Número | `edad` |
| 4 | ¿Con qué género se identifica? | Mujer / Hombre / No binario u otro / Prefiero no responder | `genero`, `mujer` |
| 5 | ¿Cuál es su vínculo actual con una universidad? | Estudiante de pregrado / Estudiante de posgrado / Egresado(a) / Docente o personal administrativo / Persona externa a la comunidad universitaria | `vinculo`, `estudiante` |
| 6 | Si tiene vínculo con una universidad, ¿esa universidad es pública o privada? | Pública / Privada / No se tiene vinculo | `tipo_universidad` |
| 7 | En los últimos 12 meses, ¿realizó alguna de estas acciones? [Donó dinero] | Sí / No | `experiencia` |
| 8 | En los últimos 12 meses, ¿realizó alguna de estas acciones? [Donó bienes (ropa, alimentos, etc.)] | Sí / No | `experiencia` |
| 9 | En los últimos 12 meses, ¿realizó alguna de estas acciones? [Donó tiempo (voluntariado)] | Sí / No | `experiencia` |

`experiencia` = 1 si la persona respondió "Sí" en al menos una de las preguntas 7, 8 o 9.

## 3. Código y asignación de versión

| # | Pregunta | Opciones |
|---|---|---|
| 10 | Código de participación (ingrese los últimos 4 dígitos de su documento de identidad). | Número de 4 dígitos (sirve para detectar respuestas duplicadas) |
| 11 | Para continuar, indique el último dígito de su documento de identidad (por ejemplo, si termina en 4, seleccione 4). No escriba el número completo. | 0–9 (asigna la versión del escenario) |

## 4. Escenario (según la versión)

| # | Pregunta | Opciones |
|---|---|---|
| 12 | Marque la casilla para confirmar que leyó la información anterior. | Leí la información *(la casilla de cada versión identifica qué institución vio la persona)* |

## 5. Preguntas después del escenario

| # | Pregunta | Opciones | Variable en R |
|---|---|---|---|
| 13 | Si esta campaña fuera real, ¿cuánto dinero estaría dispuesto(a) a donar? Escriba la cantidad en pesos colombianos (COP), solo números, sin puntos ni comas. Si no donaría dinero, escriba 0. | Número (COP) | `monto` (**variable dependiente principal**), `dona` |
| 14 | ¿Estaría dispuesto(a) a donar dinero a esta campaña? Tenga en cuenta la cantidad que escribió en la pregunta anterior. | Sí / No | `intencion` |
| 15 | ¿Cuánta confianza le genera esta campaña? | Escala 0–10 | `confianza` |
| 16 | ¿Qué probabilidad hay, en su opinión, de que los recursos recaudados lleguen a las familias afectadas? Escriba un número de 0 a 100 (0 % = ninguna, 100 % = seguro). | 0–100 | `prob_llegada` |
| 17 | ¿Compartiría esta campaña con otras personas? | Sí / No | `compartir` |
| 18 | Según la información que leyó, ¿qué tipo de institución administrará la campaña? | Una universidad pública / Alcaldía Municipal / Universidad privada / ONG / Cruz Roja / Gobierno | `comprension` (chequeo de atención) |

**Chequeo de atención (pregunta 18):** identificó correctamente la institución el 83 % en la versión de U. pública (39/47), el 69 % en la de alcaldía (34/49) y el 88 % en la de U. privada (50/57). No se excluyó a nadie por esta pregunta.

---

Este cuestionario corresponde a la **entrega final**. El cuestionario de la primera entrega (encuesta exploratoria) está en `01_Entrega_1_Encuesta_Exploratoria/Encuesta/`.
