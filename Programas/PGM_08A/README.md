# Programa COBOL con Validación de Registros

## 📄 Descripción

**PGMVACAF** es un programa escrito en COBOL como parte de la **Clase 8 Asincrónica** del curso de Desarrollo COBOL.  
El objetivo del programa es procesar un archivo de entrada con novedades de clientes, validar la información (principalmente la fecha y el tipo de documento) y generar un archivo de salida con los registros válidos.  
Los registros con datos inválidos se informan mediante mensajes en consola y no se graban.

---

## ⚙️ Funcionamiento general

El programa sigue una estructura modular con divisiones y secciones bien definidas:
1. **Apertura de archivos**: Abre archivos de entrada y salida, con control de errores.
2. **Lectura y procesamiento de registros**: 
   - Verifica que el tipo de documento sea válido (`DU`, `PA`, `PE` o `CI`).
   - Valida la fecha para comprobar año, mes y día correctos (incluyendo años bisiestos).
   - Si el registro es válido, se graba en el archivo de salida.
   - Si no, se muestra un mensaje de error detallando la causa.
3. **Cierre de archivos y totales**: Cierra los archivos y muestra en consola un resumen de:
   - Total de registros leídos.
   - Total de registros grabados.
   - Total de registros erróneos.

---

## 🗃️ Estructura de Archivos

- **Archivo de entrada (`ENTRADA`)**
  - Layout: `CPNOVCLI` (50 bytes)
  - Contiene datos de novedades de clientes.

- **Archivo de salida (`SALIDA`)**
  - Layout: `CPNCLIV` (55 bytes)
  - Incluye número secuencial y resto de datos validados.

---

## ✅ Validaciones implementadas

- **Tipo de documento:** debe ser uno de `DU`, `PA`, `PE` o `CI`.
- **Fecha:**  
  - Año debe ser >= 2025.  
  - Mes debe estar entre 1 y 12.  
  - Día debe ser coherente según el mes y año (incluye control de febrero y años bisiestos).

Los registros que no cumplen estas condiciones se consideran erróneos y se contabilizan aparte.

---

## 🏷️ Campos principales

- **Novedades de clientes (`WS-REG-NOVCLIE`):**
  - `NOV-TIP-DOC`: Tipo de documento.
  - `NOV-NRO-DOC`: Número de documento.
  - `NOV-CLI-FECHA`: Fecha del registro en formato `AAAAMMDD`.

- **Registro validado (`REG-NOVCLIE-VAL`):**
  - Incluye número secuencial y resto de campos del registro de entrada.

---

## 📊 Resumen de ejecución

Al finalizar, el programa muestra en pantalla:
- Registros leídos.
- Registros grabados.
- Registros erróneos.

---

## 🚩 Consideraciones

- Este programa es un ejemplo práctico de procesamiento batch en COBOL con validaciones de negocio y manejo de archivos secuenciales.
- Los mensajes de error ayudan a depurar registros con inconsistencias en los datos.
- Se recomienda validar las estructuras `COPY` (`CPNOVCLI` y `CPNCLIV`) antes de ejecutar en un entorno productivo.

---

## 👨‍💻 Autor

Clase desarrollada como parte de la **Formación en Desarrollo COBOL**.  
Programa: **PGMVACAF**  
Clase: **Clase 8 Asincrónica**  

---

## 📂 Archivos relacionados

- `PGMVACAF.cbl` → Código fuente COBOL.
- `CPNOVCLI` → Copybook para estructura de entrada.
- `CPNCLIV` → Copybook para estructura de salida validada.

---

## ✅ Estado

✔️ Programa funcional con manejo de errores y control de totales.

---

## 🗓️ Última actualización

Julio 2025
