# **Encuesta A2 — Confianza institucional**

**Proyecto: Confianza y solidaridad ante emergencias — Econometría Básica 2026-II** Tiempo estimado de respuesta: 3-4 minutos | Meta: ≥100 observaciones

## **0\. Consentimiento (primera pantalla)**

> "Esta encuesta es voluntaria, anónima y de uso exclusivamente académico. No se recolectan nombres, documentos, correos ni datos que permitan identificarte. Al continuar aceptas participar."

* \[ \] Acepto participar *(checkbox obligatorio, sin esto no continúa)*

**Nota técnica:** no crees un campo de "nombre" ni de "correo". El `ID` anónimo lo genera Google Forms automáticamente (marca de tiempo \+ número de respuesta); lo extraes al exportar a Sheets/CSV.

## **1\. Escenario común** 

> *Antes de responder las siguientes preguntas, te pedimos que leas con atención la siguiente situación HIPOTÉTICA:*

> *"Durante las últimas semanas, las fuertes lluvias provocaron el desbordamiento de varios ríos en un municipio colombiano. Cerca de 800 familias tuvieron que abandonar sus viviendas y parte de la infraestructura local resultó afectada. Se ha iniciado una campaña para recaudar recursos destinados a alimentación, alojamiento temporal y reconstrucción."*

> *Con este escenario en mente, responde las siguientes preguntas según lo que tú realmente harías o percibirías si esta situación ocurriera.*

## **2\. Variables comunes (obligatorias en los 6 grupos)**

| \# | Variable (R) | Pregunta | Tipo / opciones | Uso econométrico |
| ----- | ----- | ----- | ----- | ----- |
| 1 | `edad` | ¿Cuál es tu edad? | Numérica corta (validación: entero, 16–90) | Control demográfico |
| 2 | `genero` | ¿Con qué género te identificas? | Opción múltiple: Femenino / Masculino / No binario / Prefiero no decir | Control demográfico |
| 3 | `vinculo_universidad` | ¿Cuál es tu vínculo con la universidad? | Opción múltiple: Estudiante / Docente / Administrativo / Egresado / Ninguno | Control / heterogeneidad de muestra |
| 4 | `ha_donado` | En los últimos 12 meses, ¿has donado dinero, bienes o tiempo a alguna causa? | Opción múltiple: Sí, dinero / Sí, bienes / Sí, tiempo (voluntariado) / Sí, combinación / No | Variable de experiencia previa (clave para hipótesis 3\) |
| 5 | `frecuencia_donacion` | Aproximadamente, ¿con qué frecuencia donas? | Opción múltiple: Nunca / Rara vez (1 vez al año) / Ocasional (2-4 veces al año) / Frecuente (mensual o más) | Complementa `dono_antes` |
| 6 | `causa_donacion` | ¿A qué tipo de causa has donado principalmente? | Opción múltiple: Emergencias/desastres / Salud / Educación / Religiosa / Animales / Otra / No aplica | Descriptiva |
| 7 | `donaria` | Ante la campaña descrita, ¿donarías? | Sí / No | **Variable dependiente principal (binaria)** |
| 8 | `monto_donacion` | ¿Cuánto estarías dispuesto a donar? (COP) | Numérica corta, validación 0–50.000. Mostrar solo si `dispuesto_donar` \= Sí (usa lógica de salto) | **Variable dependiente continua** |
| 9 | `confianza_campana` | En una escala de 0 a 10, ¿qué tan confiable te parece esta campaña? | Escala lineal 0–10 | Variable clave mediadora entre confianza institucional y donación |
| 10 | `prob_llegada_recursos` | ¿Qué probabilidad crees que hay de que los recursos lleguen efectivamente a las familias afectadas? (0% a 100%) | Escala lineal 0–100 (pasos de 20\) | Percepción de eficacia distinta de confianza general |
| 11 | `compartiria_campana` | ¿Compartirías esta campaña con otras personas? | Sí / No / Tal vez | Proxy de "solidaridad expresiva" sin costo monetario |
| 12 | `razon_donacion` | En una frase, ¿cuál es la razón principal por la que donarías o no donarías? | **Pregunta abierta corta** (párrafo corto, máx. \~150 caracteres) | Insumo cualitativo para justificar hipótesis en la 2ª entrega |

## **3\. Módulo específico A2 \- Confianza institucional (5 preguntas, sin enfoque en donaciones)**

| \# | Variable (R) | Pregunta | Tipo / opciones | Uso econométrico |
| ----- | ----- | ----- | ----- | ----- |
| 13 | `confianza_alcaldias` | ¿Qué tanta confianza te genera la Alcaldía municipal en general? | Escala lineal 0–10 | Variable independiente por institución |
| 14 | `confianza_gobierno` | ¿Qué tanta confianza te genera el Gobierno Nacional en general? | Escala lineal 0–10 | ídem |
| 15 | `confianza_ong` | ¿Qué tanta confianza te genera una ONG (ej. Cruz Roja, Defensa Civil)? | Escala lineal 0–10 | ídem |
| 16 | `confianza_universidades` | ¿Qué tanta confianza te genera una universidad? | Escala lineal 0–10 | ídem |
| 17 | `confianza_religiosa` | ¿Qué tanta confianza te genera una organización religiosa? | Escala lineal 0–10 | ídem |
| 18 | `confianza_empresas` | ¿Qué tanta confianza te genera una empresa privada? | Escala lineal 0–10 | ídem |
| 19 | `capacidad_institucion` | ¿Cuál institución crees que tiene mayor capacidad técnica y logística para responder ante una emergencia como esta? | Opción única (misma lista) | Mide percepción de *competencia*, distinta de confianza general dimensión adicional de la variable "confianza institucional" |
| 20 | `liderazgo_institucion` | En tu opinión, ¿qué institución debería liderar la coordinación de la respuesta ante esta emergencia? | Opción única (misma lista) | Variable categórica contrastable contra 13-18 y 19 (¿coincide confianza con preferencia de liderazgo?) |
| 21 | `experiencia_emergencia` | ¿Has tenido alguna experiencia, propia o cercana, con el manejo de una emergencia anterior por parte de alguna de estas instituciones? | Sí / No | Variable de experiencia previa posible determinante de la confianza reportada (hipótesis para 2ª entrega) |

**Truco de diseño:** en Google Forms, agrupamos las preguntas 13–18 en una sola **pregunta de cuadrícula (grid)** tipo "Escala lineal por fila" Google Forms la cuenta como una sola pregunta visual, así que el módulo completo queda en **5 preguntas** (dentro del rango de 4-6 que pide el rubro), aunque produzca 6 variables \+ 4 categóricas en el CSV.

**Por qué así:** ninguna de estas 8 preguntas menciona plata ni "recursos de la campaña" todo gira en torno a confianza, competencia percibida y experiencia previa con las instituciones, que es exactamente lo que dice el rubro para A1/A2 ("medir la confianza en distintas organizaciones y preguntar cuál debería administrar los recursos"). La 20 (`liderazgo_institucion`) cubre ese último requisito del rubro, pero reformulada como "liderar la coordinación" en vez de "administrar los recursos", para que no suene a pregunta de donación.

## **Resumen de estructura del formulario**

1. Consentimiento (1 pantalla)  
2. Escenario (1 pantalla, solo lectura)  
3. Datos demográficos (ítems 1-3)  
4. Experiencia previa de donación (ítems 4-6)  
5. Disposición ante la campaña (ítems 7-12, con salto lógico en el 8\)  
6. Confianza institucional \- grid (ítems 13-18)  
7. Administrador preferido (ítem 19\)

**Total: 21 variables, \~3-4 minutos.** Preguntas abiertas/semiabiertas: `razon_principal` (texto libre); el resto son cerradas para facilitar el análisis cuantitativo y el tablero Shiny.

---

## **Notas para el análisis posterior (rúbrica)**

* Las preguntas **19, 20 y 21** vs. la grid **13-18** dan tres contrastes distintos y valiosos para el reporte:  
  * ¿La institución que la gente *dice* que más confía (19) coincide con la que tiene el promedio más alto en la grid (13-18)? (chequeo de consistencia)  
  * ¿Confianza (13-18) y capacidad percibida (20) apuntan a la misma institución, o la gente confía en una pero cree que otra es más competente? Esa disociación es justo el tipo de hallazgo que impresiona en un proyecto.  
  * ¿A quién elegimos para coordinar (20) coincide con en quién más confían? Si no coincide, ahí hay una hipótesis causal fuerte para la 2ª entrega (ej. "la confianza no predice la preferencia de liderazgo tanto como la capacidad percibida").  
* `experiencia_institucional` (20) te permite probar si haber tenido contacto previo con estas instituciones en una emergencia real está asociado con mayor o menor confianza reportada — análogo a la pregunta orientadora del profesor sobre experiencia previa, pero aplicada a instituciones en vez de donaciones.  
  


