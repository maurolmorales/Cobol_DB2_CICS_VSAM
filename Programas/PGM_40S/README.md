<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 Programa COBOL con Corte de Control y Listado Formateado

## Descripción

`PGMIMCAF` es un programa escrito en COBOL, desarrollado como parte de la **Clase Sincrónica 21**, cuyo objetivo es procesar un archivo de entrada de clientes **ordenado por Tipo de Documento**, generando un **listado impreso** con información detallada y organizada.

El programa aplica la técnica de **corte de control** para agrupar registros por **Tipo de Documento**, calculando subtotales por grupo y controlando la paginación para un informe claro y profesional.

---

## 🎯 Funcionalidades principales

✅ **Lectura de Archivo Secuencial**
- Abre y valida el archivo de entrada `ENTRADA`.
- Lee registros secuencialmente hasta finalizar.

✅ **Corte de Control**
- Detecta cambios en el Tipo de Documento.
- Muestra subtotales de registros para cada grupo.
- Imprime separadores y totales parciales.

✅ **Generación de Listado**
- Crea un archivo de salida `LISTADO` en formato de reporte.
- Incluye títulos, subtítulos, líneas de separación y datos detallados.
- Controla la cantidad de líneas por página y reimprime títulos cuando es necesario.

✅ **Estadísticas**
- Muestra por consola la cantidad total de registros leídos y grabados.
- Muestra mensajes de error si hay incidentes en apertura, lectura, escritura o cierre.

---

## 📁 Archivos de Entrada y Salida

### 📥 Archivo de Entrada (`ENTRADA`)
- **Nombre lógico:** `DDENTRA`
- **Formato:** Secuencial, registros de longitud fija (`X(50)`).
- **Contenido:** Datos de clientes con campos como:
  - `CLIS-TIP-DOC`: Tipo de Documento (`DU`, `PA`, `PE`).
  - Número de Documento.
  - Sucursal.
  - Tipo de Cuenta (`01` = Cuenta Corriente, `02` = Caja de Ahorros, `03` = Plazo Fijo).
  - Número de Cuenta.
  - Importe.
  - Fecha (AAAAMMDD).
  - Localidad.

> ⚠️ **Importante:** El archivo debe estar ordenado previamente por `CLIS-TIP-DOC` para que el corte de control funcione correctamente.

### 📤 Archivo de Salida (`LISTADO`)
- **Nombre lógico:** `DDLISTA`
- **Formato:** Reporte impreso de ancho fijo (`X(132)`).
- **Contenido:**
  - Encabezados de página con fecha y número de página.
  - Subtítulos de columnas.
  - Registros de clientes detallados y formateados.
  - Subtotales por Tipo de Documento.
  - Total general.

---

## 🧩 Estructura del Código

- **IDENTIFICATION DIVISION:** Identificación del programa.
- **ENVIRONMENT DIVISION:** Configuración de archivos de entrada y salida.
- **DATA DIVISION:**
  - *FILE SECTION:* Descripción de `ENTRADA` y `LISTADO`.
  - *WORKING-STORAGE SECTION:* Variables de control, contadores, títulos, subtítulos y líneas de separación.
- **PROCEDURE DIVISION:**
  - `1000-INICIO`: Inicialización, apertura de archivos, carga de fecha de proceso.
  - `2000-PROCESO`: Lectura y procesamiento de registros, aplicación del corte de control.
  - `2100-LEER`: Rutina de lectura.
  - `2200-CORTE-MAYOR`: Emite subtotales al cambiar de Tipo de Documento.
  - `6000-GRABAR-SALIDA`: Genera registros del listado y controla paginación.
  - `6500-IMPRIMIR-TITULOS` y `6500-IMPRIMIR-SUBTITULOS`: Encabezados de página.
  - `9999-FINAL`: Cierre de archivos y resumen final.

---

## 🎯 Formato del archivo de salida y Display
El archivo de salida `LISTADO` contiene líneas formateadas con información agrupada. Ejemplo de líneas que se generan:

#### 💬 DISPLAY

```text
CUENTA SIN CLIENTE EN TBCURCLI                          
CUENTA SIN CLIENTE EN TBCURCLI                          
CUENTA SIN CLIENTE EN TBCURCLI                          
*******************************          
LEIDOS:           014                                   
ENCONTRADOS:      011                                   
NO ENCONTRADOS:   003                                   
```
</br>

#### 💾 Archivo QSAM LISTADO
```text
           CLIENTES ENCONTRADOS EN TABLA CLIENTES                             
-------------------------------------------------------------------           
| TIPDOC |    NRODOC    |  NROCLI |             NOMAPE             |          
-------------------------------------------------------------------           
|     DU |          111 |      10 | AMASO FLORES JUANA INES        |          
|     DU |          135 |      11 | COMOMIRO ESTEBAN JOSE          |          
|     DU |          555 |      13 | PERENCIO CARMEN                |          
|     DU |          666 |      15 | PAZ JUAN PEDRO                 |          
|     PA |          234 |      16 | PERA FEDERICO                  |          
|     PA |          333 |      17 | PACIENCIA NOEMI                |          
|     PA |          456 |      18 | PRIETO JOSE                    |          
|     PE |          234 |      20 | PEREZ MARCELA                  |          
|     PE |          456 |      21 | PRUDENCIO MARIA JOSE           |          
|     PE |          789 |      22 | EQUINOCCIO JACINTO             |          
|     PE |          999 |      23 | PEREYRA LUCENA MARTIN          |          
```

<div style="text-align: right;">

[( 🏠 )](/)

</div>