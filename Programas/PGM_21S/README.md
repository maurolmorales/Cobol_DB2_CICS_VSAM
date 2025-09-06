[( 🏠 )](/) </div>

# 📄 PROGM21S - Corte de Control e Impresión de Listado

* **Entrada**: `CLIENTES` (LRECL=50, RECFM=FB). Este archivo se ordena previamente y se usa la versión ordenada `CLIENTES.ORD` para procesar.
* **Salida listada**: `LISTADO` (archivo de salida impresa, LRECL=133, RECFM=FB).
* **Otros**: `SYSOUT` (sysout del job), `CLIENTES.ORD` (archivo intermedio generado por SORT).

## 📚 Descripción del Programa

Este programa COBOL (`PROGM21S`) procesa un archivo secuencial de clientes ordenado por **tipo de documento** y genera un listado impreso con cortes de control por cada cambio de tipo de documento.

* **Propósito del programa**: recorrer registros de clientes, imprimir cada registro en formato tabulado, y generar subtotales (cortes) por cada `TIPO DE DOCUMENTO` detectado en el flujo de datos.
* **Incluye en el proyecto**: código COBOL (`PROGM21S.cbl`), JCL para compilar y ejecutar, archivos de datos (entrada y salida), y copybooks (si se requieren para layouts externos).

</br>

---

### 🚀 Estructura del Proyecto

```text
├── src/
│   ├── PROGM21S.cbl          # Programa COBOL batch que procesa archivo de clientes ordenado
│   ├── COPY/
│   │   ├── CPCLIENS.cpy      # (opcional) copybook con layout de cliente (si aplica)
│   │   └── SQLCA.cpy         # (no usado en este batch sin DB2, pero común en proyectos)
│
├── jcl/
│   ├── COMPILA.jcl           # JCL para precompilar/compilar (COMPCOBO) y generar el load
│   ├── RUN-IDCAMS-SORT-RUN.jcl # JCL para borrar datasets, ordenar y ejecutar PROGM21S
│
├── data/
│   ├── KC03CAF.ARCHIVOS.CLIENTES # (ORIG) archivo de entrada original
│   ├── KC03CAF.ARCHIVOS.CLIENTES.ORD # archivo de entrada ordenado por tipo doc
│   └── KC03CAF.ARCHIVOS.LISTADO  # dataset de salida impreso
│
├── README.md
```

</br>

---

### 📋 Archivos Involucrados

* **Programa**: `PROGM21S.cbl` — Programa batch COBOL que lee `ENTRADA`, detecta cambios en `CLIS-TIP-DOC`, realiza acumuladores por grupo y escribe un listado formateado en `LISTADO`.

* **JCL**:

  * **COMPILA.jcl**: Invoca el compilador COBOL (`COMPCOBO`), con `ALUMLIB=KC03CAF.CURSOS` y `GOPGM=PROGM21S`. Se define `COBOL.SYSLIB` apuntando al dataset de copybooks `KC02788.ALU9999.COPYLIB`.
  * **RUN (EJECUTA).jcl**: Job en tres pasos: 1) `IDCAMS` para eliminar datasets previos (`KC03CAF.ARCHIVOS.CLIENTES.ORD`, `KC03CAF.ARCHIVOS.LISTADO`), 2) `SORT` para ordenar `KC03CAF.ARCHIVOS.CLIENTES` por las posiciones de `TIPO DOC` (campos 1-2), generando `CLIENTES.ORD`, 3) ejecutar `PROGM21S` con `DDENTRA` apuntando a `CLIENTES.ORD` y `DDLISTA` al dataset de salida.

* **Archivos de datos**:

  * `KC03CAF.ARCHIVOS.CLIENTES` : **entrada original**, RECFM=FB, LRECL=50 (según comentario "LARGO 50 BYTES").
  * `KC03CAF.ARCHIVOS.CLIENTES.ORD` : **entrada ordenada** producida por el paso de SORT (DISP=(,CATLG)).
  * `KC03CAF.ARCHIVOS.LISTADO` : **archivo de salida** (RECFM=FB, LRECL=133) donde se vuelca el listado formateado.

* **Copybooks utilizados**:
  * `CPCLIENS.cpy` (sugerido): layout del registro cliente (se encontró el layout inline en el programa; se puede extraer a un copybook).

---

## ▶️ Descipción del JCL

#### 🪛 COMPILA.jcl

* Job `KC03CAFC` ejecuta el compilador COBOL mediante el procedimiento `COMPCOBO`.
* Parámetros importantes: `ALUMLIB=KC03CAF.CURSOS` (librería con programas/loads), `GOPGM=PROGM21S` (nombre del programa generado).
* `COBOL.SYSLIB` apunta a `KC02788.ALU9999.COPYLIB` para resolver copybooks durante compilación.
* Resultado: creación del load module `PROGM21S` en la librería definida por el procedimiento `COMPCOBO` (p. ej. `KC03CAF.CURSOS.PGMLIB`).

#### 🔗 RUN - IDCAMS / SORT / EXEC PROGM21S (EJECUTA.jcl)

* **STEP1 (IDCAMS)**: borra datasets residuales `KC03CAF.ARCHIVOS.CLIENTES.ORD` y `KC03CAF.ARCHIVOS.LISTADO` para garantizar un estado limpio. Se usa `SET MAXCC = 0` para normalizar el retorno.
* **STEP2 (SORT)**: ordena `KC03CAF.ARCHIVOS.CLIENTES` por formato `BI` y campos `(1,2,A)` (campo 1-2 = `CLIS-TIP-DOC`) y genera `KC03CAF.ARCHIVOS.CLIENTES.ORD` con `DCB=(LRECL=50,BLKSIZE=6200,RECFM=FB)`.
* **STEP3 (EXEC PROGM21S)**:

  * `STEPLIB` debe contener la librería con el load `PROGM21S` (por ejemplo `KC03CAF.CURSOS.PGMLIB`).
  * `DDENTRA` -> `KC03CAF.ARCHIVOS.CLIENTES.ORD` (entrada ordenada).
  * `DDLISTA` -> `KC03CAF.ARCHIVOS.LISTADO` (archivo de salida, LRECL=133, FB), se crea si no existe.
  * `SYSOUT` y `SYSUDUMP` definidos para debugging y trazas.

---

## 🏛️ Estructura del Programa

* **MAIN-PROGRAM-I / MAIN-PROGRAM-F**: punto de entrada y retorno (`GOBACK`). Orquesta la secuencia de `INICIO`, `PROCESO` (bucle de lectura) y `FINAL`.
* **1000-INICIO**: inicialización de variables, `ACCEPT WS-FECHA FROM DATE`, apertura de archivos `ENTRADA` y `LISTADO`, manejo de errores de `OPEN`, inicialización de contadores y lectura del primer registro.
* **2000-PROCESO**: ciclo principal; por cada registro arma la línea de salida (`WS-REG-LISTADO`), invoca `6000-GRABAR-SALIDA` y controla la lógica de corte por `CLIS-TIP-DOC` (si cambia el tipo de documento, realiza corte mayor e imprime títulos).
* **2100-LEER**: `READ ENTRADA INTO REG-CLIENTES` y evaluación de `FS-ENT` (`'00'`, `'10'`, `OTHER`) para contadores y final de lectura.
* **2200-CORTE-MAYOR**: procedimiento que ejecuta el corte por tipo de documento; mueve contadores a campos de impresión, llama a `2110-CORTE-IMPRIME` y reinicia acumuladores.
* **2110-CORTE-IMPRIME**: escribe las líneas que conforman el bloque del corte (línea separadora, línea del corte con cantidad, etc.).
* **6000-GRABAR-SALIDA**: maneja paginado y límites de líneas por página (`IMP-CUENTA-LINEA`), escribe `WS-REG-LISTADO` en `LISTADO`, chequea `FS-LISTADO`, incrementa `WS-IMPRESOS`.
* **6500-IMPRIMIR-TITULOS / SUBTITULOS**: imprime títulos y subtítulos (manejo de `AFTER PAGE` y control de página), resetea contadores por página.
* **9999-FINAL**: cierra archivos, muestra totales por `DISPLAY` (`LEIDOS`, `IMPRESOS`) y realiza chequeos finales de `CLOSE`.

---

## ⚙️ Secuencia del Programa

1. **Inicio**

   * Aceptar fecha del sistema y preparar campos de título.
   * Abrir archivos `ENTRADA` y `LISTADO` y validar `FS-ENT`/`FS-LISTADO`.
   * Leer primer registro y marcar `WS-PRIMER-REG`.

2. **Proceso**

   * Mientras no sea fin de archivo (\`WS-FIN-LECTURA = 'N'):

     * Leer registro (`2100-LEER`).
     * Mapear campos de `REG-CLIENTES` a la estructura de impresión (`WS-REG-LISTADO`).
     * Grabar la salida (`6000-GRABAR-SALIDA`) — controla paginación y `AFTER PAGE` para títulos.
     * Control de corte: si cambia `CLIS-TIP-DOC`, ejecutar `2200-CORTE-MAYOR` y reimprimir títulos.

3. **Final**

   * Ejecutar `2200-CORTE-MAYOR` para el último grupo si es necesario.
   * Mostrar totales (`WS-REGISTROS-CANT`, `WS-LEIDOS-ENTRADA`, `WS-IMPRESOS`) por `DISPLAY`.
   * Cerrar archivos y validar `FS-ENT`/`FS-LISTADO` en `CLOSE`.

---

## 📊 Diagrama de Flujo

<img src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">

---

## 🎯 Resultado

### 🖨️ Formato del archivo de salida
```text
                                                                          
 71     TOTAL CLIENTE/CUENTA POR SUCURSAL:   6- 9-2025    NUMERO PAGINA:  
| TIPO DE DOCUMENTO | NRO DE DOCUMENTO | SUCURSAL | TIPO CUENTA | NUM-CTA | IMPORTE      | FECHA      | LOCALIDAD     |
-----------------------------------------------------------------------------------------------------------------------
| PA                |       5.5987.412 |       05 |          01 |     130 |  $  90000,00 | 2021/12/30 | ARGENTINA      
| PA                |       5.9432.178 |       05 |          01 |     137 |  $  40000,00 | 2021/12/30 | ARGENTINA      
| PA                |       5.7234.896 |       04 |          02 |     133 |  $  40000,00 | 2021/12/30 | ARGENTINA      
| PA                |       6.8765.430 |       04 |          02 |     133 |  $  40000,00 | 2021/12/30 | URUGUAY        
| PA                |       6.9012.348 |       05 |          01 |     137 |  $  40000,00 | 2021/12/30 | BOLIVIA        
| PE                |       4.1876.530 |       03 |          01 |     140 |  $  70000,00 | 2021/12/30 | ARGENTINA      
=======================================================================================================================
         CANTIDAD TIPO CUENTA PA     6                                    
                                                                          
                                                                          
 75     TOTAL CLIENTE/CUENTA POR SUCURSAL:   6- 9-2025    NUMERO PAGINA:  
| TIPO DE DOCUMENTO | NRO DE DOCUMENTO | SUCURSAL | TIPO CUENTA | NUM-CTA | IMPORTE      | FECHA      | LOCALIDAD     |
-----------------------------------------------------------------------------------------------------------------------
| PE                |       6.9012.348 |       04 |          02 |     143 |  $  50000,00 | 2021/02/30 | URUGUAY        
| PE                |       6.1789.234 |       03 |          01 |     140 |  $  70000,00 | 2021/12/30 | ARGENTINA      
| PE                |       8.2789.004 |       04 |          02 |     143 |  $  50000,00 | 2021/02/30 | PERU           
| PE                |       8.2789.004 |       04 |          02 |     143 |  $  50000,00 | 2021/02/30 | PERU           
=======================================================================================================================
         CANTIDAD TIPO CUENTA PE     4                                     
```

### 💬 Display
```text
=================================               
TIPO-DOC: DU                                    
TOTAL TIPO DOCU =  55                           
                                                
=================================               
TIP-DOC = PA                                    
TOTAL TIPO DOCU =   6                           
                                                
=================================               
TIP-DOC = PE                                    
TOTAL TIPO DOCU =   4                           
**********************************************  
TOTAL REGISTROS =  65                           
LEIDOS:     00065                               
IMPRESOS:   00065                               
```


