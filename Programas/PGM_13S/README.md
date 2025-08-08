<div style="text-align: right;">

[( 🏠 )](/)

</div>

# 📄 Validación y Conteo por Estado Civil Mediante Corte de Control
- Entrada: archivo QSAM
- Salida: sysout display

## 📚 Descripción del Programa
`PGMC1CAF` realiza un **corte de control** por estado civil. Muestra la cantidad por cada corte de control y el total de registros. 

El objetivo principal es procesar un archivo de entrada con información de clientes para:
- Leer todos los registros.
- Agruparlos por **Estado Civil**.
- Contar cuántos registros pertenecen a cada Estado Civil.
- Mostrar el total de registros procesados.

---
### 🚀 Estructura del Proyecto

```
├── src/
│ ├── PGMC1CAF.cbl # Programa COBOL 
│ ├── COPY/
│ │ ├── CLICOB # Copybook (embebido para tener de referencia)
│
├── jcl/
│ ├── COMPILA.jcl # JCL para precompilar
│ ├── EJECUTA.jcl # JCL para ejecutar
│
├── README.md
```

---

### 📋 Archivos Involucrados

- **Programa**: `PGMCORT2.cbl` Programa fuente de corte de control.
- **JCL**: \
`COMPILA.jcl`: Compila un programa COBOL batch.
  1. Usa una librería de PROCs (ORIGEN.CURSOS.PROCLIB).
  2. Ejecuta el PROC COMPCOTE, que compila un programa COBOL batch.
  3. Compila el programa PGMCORT2 que debe estar en la librería USUARIO.CURSOS.
  4. (Opcional) Le pasa una librería de COPYBOOKs a través del DD COBOL.SYSLIB. 

  `EJECUTA.jcl`: Trata el archivo de entrada y ejecuta el programa.
  1. Borra (si existe) el archivo USUARIO.ARCHIVO.SORT.
  2. Ordena USUARIO.ARCHIVOS por los primeros 2 bytes y genera USUARIO.ARCHIVO.SORT.
  3. Ejecuta el programa PGM2CCAF usando como entrada ARCHIVO.SORT y graba salida en SYSOUT.


- **Archivos de datos**:
  - `KC03CAF.ARCHIVOS.CLICOB`: Archivo QSAM de 93 bytes de largo de clientes. 
  - `KC03CAF.ARCHIVOS.CLICOB.SORT`: Archivo QSAM de 93 bytes generado mediante EJECUTA.jcl ordenado 
- **Copybooks utilizados**:
  - `CLICOB`: Embebido para tener de referencia en el programa.
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

## 📊 Diagrama de Flujo
<image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">

---
## 🎯 Resultado

### 💬 Display 
```text
TOTAL DE CASADO    :    10                     
TOTAL DE DIVORCIADO:     3                     
TOTAL DE SOLTERO   :     8                     
TOTAL DE VIUDO     :     3                     
*************************** 
TOTAL DE REGISTROS =    24                     
```


<div style="text-align: right;">

[( 🏠 )](/)

</div>

