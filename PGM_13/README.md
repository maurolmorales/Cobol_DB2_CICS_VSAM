# 📄 Programa COBOL de Validación y Conteo por Estado Civil

## Descripción

`PGMC1CAF` es un programa desarrollado en COBOL que forma parte de una **Clase Sincrónica (13)** orientada a prácticas de manejo de archivos secuenciales y técnicas de **validación y cortes de control**.

El objetivo principal es procesar un archivo de entrada con información de clientes para:
- Leer todos los registros.
- Agruparlos por **Estado Civil**.
- Contar cuántos registros pertenecen a cada Estado Civil.
- Mostrar el total de registros procesados.

---

## 📁 Archivo de Entrada

- **Nombre Lógico:** `ENTRADA` (asignado a `DDENTRA`).
- **Formato:** Archivo secuencial con registros de longitud fija (`PIC X(93)`).
- **Contenido del Registro:**
  - Tipo de Documento: `DU`, `PA`, `PE`, `CI`
  - Número de Documento
  - Nombre y Apellido
  - Estado Civil: `SOLTERO`, `VIUDO`, `DIVORCIADO`, `CASADO`
  - Sexo: `F`, `M`, `O`

> 🔍 **Importante:** Los registros deben estar ordenados previamente por **Estado Civil**, ya que el programa aplica una técnica de **corte de control**.

---

## 🔄 Lógica de Funcionamiento

1. **Inicio**
   - Abre el archivo de entrada.
   - Valida que el archivo esté disponible.
   - Lee el primer registro para inicializar la clave de agrupación.

2. **Proceso**
   - Lee secuencialmente todos los registros.
   - Compara el Estado Civil del registro actual con el anterior.
   - Si cambia, muestra la cantidad acumulada del grupo anterior (corte de control).
   - Continua hasta finalizar todos los registros.

3. **Final**
   - Realiza el último corte.
   - Muestra el total de registros procesados.
   - Cierra el archivo y valida el cierre.

---

## 🧩 Estructura del Código

- **IDENTIFICATION DIVISION:** Nombre del programa.
- **ENVIRONMENT DIVISION:** Configuración del archivo de entrada.
- **DATA DIVISION:**  
  - *FILE SECTION:* Descripción del archivo y registro de entrada.
  - *WORKING-STORAGE SECTION:* Variables de control, contadores y registros de trabajo.
- **PROCEDURE DIVISION:**  
  - `1000-INICIO`: Inicialización y apertura de archivo.
  - `2000-PROCESO`: Ciclo principal de lectura y control.
  - `2500-LEER`: Rutina de lectura.
  - `2600-CORTE-EST-CIV`: Corte y muestra de acumulados por Estado Civil.
  - `9999-FINAL`: Cierre de archivo y resumen final.

---

## ⚙️ Requisitos

- Entorno de ejecución COBOL (Mainframe, z/OS o compilador local como OpenCOBOL/GnuCOBOL).
- Archivo de entrada ordenado por Estado Civil.
- Definición de `DDENTRA` en JCL o script de ejecución.

---

## 📊 Salidas

El programa genera salidas por consola (`DISPLAY`):
- Total de registros por cada Estado Civil.
- Mensajes de error si hay fallas en apertura, lectura o cierre.
- Total general de registros procesados.

```text
TOTAL DE CASADO    :    10                     
TOTAL DE DIVORCIADO:     3                     
TOTAL DE SOLTERO   :     8                     
TOTAL DE VIUDO     :     3                     
*************************** 
TOTAL DE REGISTROS =    24                     
```


---

## 📌 Notas

- Se recomienda validar previamente la calidad y formato de los registros de entrada.
- Para adaptaciones futuras, se puede extender la lógica para cortes de control por otros campos (por ejemplo, Sexo o Tipo de Documento).
- Este programa es un ejemplo didáctico para reforzar conceptos de **procesamiento batch secuencial** y **validación de datos** en COBOL.

---

## ✏️ Autor

- **Clase Sincrónica 13**
- **Propósito:** Ejercicio de práctica para aprendizaje de validación y procesamiento con corte de control en COBOL.

---

## 🗃️ Licencia

Uso educativo y formativo.

---

