# 📄 Corte de control con Impresión.
  - ENTRADA: Archivo QSAM. 
  - SALIDA: Archivo QSAM.
## 📚 Descripción del Programa
El programa `PGMIMCAF` procesa un archivo de entrada (`ENTRADA`) de registros de clientes, genera un listado impreso (`LISTADO`) y realiza un corte de control cada vez que cambia el tipo de documento del cliente. Además, maneja impresión paginada.

---

### 🚀 Estructura del Proyecto

```
├── src/
│ ├── PGMIMCAF.cbl # Programa COBOL 
│ ├── COPY/
│   ├── CPCLIENS  # Copybook (embebido para tener de referencia)
│
├── jcl/
│ ├── COMPILA.jcl   # JCL para precompilar
│ ├── EJECUTA.jcl   # JCL para ejecutar
│
├── archivos/
│ ├── CLIENTES  # archivo QSAM de entrada de datos.
│ ├── LISTADO   # archivo QSAM de salida de datos.
|
├── README.md
```
</br>

### 📋 Archivos Involucrados

- **Programa**: `PGMIMCAF.cbl` Programa fuente de validación.
- **JCL**: \
`COMPILA.jcl`: Compila un programa COBOL batch.
  1. Usa una librería de PROCs (ORIGEN.CURSOS.PROCLIB).
  2. Ejecuta el PROC COMPCOTE, que compila un programa COBOL batch.
  3. Compila el programa PGMCORT2 que debe estar en la librería USUARIO.CURSOS.
  4. (Opcional) Le pasa una librería de COPYBOOKs a través del DD COBOL.SYSLIB. 

  `EJECUTA.jcl`: Trata el archivo de entrada y ejecuta el programa.
  1. Borra (si existe) el archivo USUARIO.ARCHIVO.CLIENTES.SORT.
  2. Ordena USUARIO.ARCHIVOS por los primeros 2 bytes y genera USUARIO.ARCHIVO.SORT.
  3. Ejecuta el programa PGMIMCAF usando como entrada ARCHIVO.SORT y 
  genera un archivo resultante. Graba salida en SYSOUT.

- **Archivos de datos**:
  - `USUARIO.ARCHIVOS.CLIENTES`: Archivo QSAM de 50 bytes de largo de clientes. 
  - `USUARIO.ARCHIVOS.LISTADO`: Archivo QSAM de 132 bytes generado mediante EJECUTA.jcl.
- **Copybooks utilizados**:
  - `CPCLIENS`: Estructura de datos de clientes.

---

## 🏛️ Estructura del Programa 

  - **1000-INICIO**
    - Obtiene y guarda la fecha actual.
    - Inicializa variables y abre archivos ENTRADA y LISTADO.
    - Verifica errores de apertura y realiza la primera lectura del archivo.
    - Si el archivo no está vacío:
        - Muestra el primer tipo de documento y comienza la cuenta.
  - **2000-PROCESO**
    - Transfiere los campos del registro de cliente (`REG-CLIENTES`) al registro de salida (`WS-REG-LISTADO`).
    - Llama a la rutina de escritura `6000-GRABAR-SALIDA`.
    - Realiza una nueva lectura.
    - Verifica si terminó el archivo (`WS-FIN-LECTURA`):
        - Si terminó, llama al corte final.
        - Si no, compara el tipo de documento actual con el anterior:
            - Si son iguales, acumula.
            - Si cambiaron, realiza un corte con `2200-CORTE-MAYOR`.

  - **6000-GRABAR-SALIDA**
    - Imprime encabezado de página si se superaron 60 líneas.
    - Escribe el registro en el archivo `LISTADO`.
    - Aumenta contadores de línea e impresos.

  - **6500-IMPRIMIR-TITULOS**
    - Escribe el título (encabezado) en una nueva página del listado.
    - Incrementa número de página y reinicia contador de línea.

  - **2200-CORTE-MAYOR**
    - Muestra en consola el total de registros para el tipo de documento anterior.
    - Actualiza el tipo de documento anterior (`WS-TIPO-DOC-ANT`) con el actual.
    - Reinicia el acumulador para el nuevo tipo de documento.

  - **2100-LEER**
    - Lee el siguiente registro del archivo de entrada.
    - Si es correcto ('`00`'), actualiza contadores.
    - Si llega al final ('`10`'), activa `WS-FIN-LECTURA`.
    - Si hay error, muestra mensaje y finaliza.

  - **9999-FINAL**
    - Muestra el total de registros procesados e impresos.
    - Cierra ambos archivos.
    - Verifica errores de cierre.

---

## 🎯 Resultado

### 💬 Display 
```text
----------------------------         
REGISTRO VALIDADO OK - DOC: DU NRO: 90323335999
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 00126789000     
----------------------------         
DÍA INVÁLIDO PARA MES DE 31 DÍAS NRO: 00126789000        
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 90223373999     
----------------------------         
FEBRERO INVÁLIDO NRO: 90223373999    
----------------------------         
REGISTRO VALIDADO OK - DOC: PA NRO: 12312312312
----------------------------         
REGISTRO VALIDADO OK - DOC: CI NRO: 00136555000
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 00083333999     
----------------------------         
TIPO DOCUMENTO INVÁLIDO: CC NRO: 00123333300   
----------------------------         
TIPO DOCUMENTO INVÁLIDO: LD NRO: 00123449000   
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 09888000000     
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 00188889000     
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 00022000160     
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 00777789000     
----------------------------         
AÑO INVÁLIDO < 2025 - DOC NRO: 00023000190     
----------------------------         
DÍA INVÁLIDO PARA MES DE 31 DÍAS NRO: 00023000190        
==============================       
 TOTAL DE ENTRADAS LEIDAS 013        
 TOTAL DE REGISTROS GRABADOS  003    
 TOTAL DE REGISTROS ERRÓNEOS  013 
```
### 💾 Archivo QSAM DDSALID 
```TEXT
NOV-SECUEN    NOV-RESTO
00001         DU903233359990101111......20250425
00004         PA123123123120202114......20250430
00005         CI001365550000202130......20250430
```