<div style="text-align: right;">

[( 🏠 )](/)

</div>

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
    - Imprime encabezado de página si se superaron 15 líneas.
    - Escribe el registro en el archivo `LISTADO`.
    - Aumenta contadores de línea e impresos.

  - **6500-IMPRIMIR-TITULOS**
    - Escribe el título (encabezado) en una nueva página del listado.
    - Llama al párrafo `6600-IMPRIMIR-SUBTITULOS`.
    - Incrementa número de página y reinicia contador de línea.

  - **2200-CORTE-MAYOR**
    - Muestra en consola el total de registros para el tipo de documento anterior.
    - Actualiza el tipo de documento anterior (`WS-TIPO-DOC-ANT`) con el actual.
    - Llama al párrafo `6700-CORTE-IMPRIME`.
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
## 📊 Diagrama de Flujo
<image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">
---

## 🎯 Resultado

### 💬 Display 
```text
=================================                                         
TIPO-DOC = DU                                                             
TOTAL TIPO DOCU =  55                                                     
                                                                          
=================================                                         
TIP-DOC = PA                                                              
TOTAL TIPO DOCU =   6                                                     
                                                                          
=================================                                         
TIP-DOC = PE                                                              
TOTAL TIPO DOCU =   4                                                     
                                                                          
=================================                            
TOTAL REGISTROS =  65                                                     
LEIDOS:     00065                                                         
IMPRESOS:   00065                                                         
```
### 💾 Archivo QSAM DDSALID 
```TEXT
 DU     TOTAL CLIENTE/CUENTA POR SUCURSAL:   4- 8-2025    NUMERO PAGINA:  1                           
-----------------------------------------------------------------------------------------------
|TIPO DOC.| NUM. DOCUMENTO   |SUC.|TIPO| NUM.|    IMPORTE      |   FECHA    |    LOCALIDAD    |       
-----------------------------------------------------------------------------------------------
|      DU |        23.123.456|  02|  01|  123|  -$       300,00|  30-12-2021|  ARGENTINA      |       
|      DU |        28.345.679|  03|  03|  125|   $ 1.000.000,40|  30-12-2021|  ARGENTINA      |       
|      DU |        26.345.678|  01|  03|  124|  -$     2.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        29.765.432|  04|  01|  126|   $ 1.000.003,00|  30-12-2021|  ARGENTINA      |       
|      DU |        27.890.123|  03|  01|  125|  -$       400,00|  30-12-2021|  ARGENTINA      |       
|      DU |        24.567.890|  02|  02|  123|  -$ 4.000.000,00|  25-12-2021|  ARGENTINA      |       
|      DU |        25.981.234|  02|  03|  123|  -$ 4.000.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        21.100.127|  01|  01|  124|  -$    10.000,00|  15-05-2021|  PARAGUAY       |       
|      DU |        38.456.789|  05|  01|  134|   $   200.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        39.872.104|  05|  03|  136|   $    80.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        37.985.421|  05|  01|  132|   $       700,00|  30-12-2021|  ARGENTINA      |       
|      DU |        34.678.901|  05|  11|  130|   $    60.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        31.547.892|  05|  01|  128|   $    10.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        32.789.012|  05|  02|  128|   $    30.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        30.128.976|  04|  02|  126|   $    40.000,00|  30-12-2021|  ARGENTINA      |       
                                                                                                      
 DU     TOTAL CLIENTE/CUENTA POR SUCURSAL:   4- 8-2025    NUMERO PAGINA:  2                           
-----------------------------------------------------------------------------------------------
|TIPO DOC.| NUM. DOCUMENTO   |SUC.|TIPO| NUM.|    IMPORTE      |   FECHA    |    LOCALIDAD    |       
-----------------------------------------------------------------------------------------------
|      DU |        33.901.234|  05|  01|  129|   $       400,00|  30-12-2021|  ARGENTINA      |       
|      DU |        36.781.245|  04|  02|  129|   $    80.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        46.457.832|  02|  01|  123|  -$       300,00|  30-12-2021|  ARGENTINA      |       
|      DU |        48.672.103|  03|  01|  125|  -$       400,00|  30-12-2021|  ARGENTINA      |       
|      DU |        47.568.914|  02|  02|  124|  -$     2.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        49.123.867|  01|  03|  124|  -$     2.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        44.126.789|  02|  03|  123|  -$ 4.000.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        45.321.098|  02|  02|  123|  -$ 4.000.000,00|  25-12-2021|  ARGENTINA      |       
|      DU |        43.219.876|  04|  01|  144|   $    30.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        42.998.456|  04|  01|  142|   $40.080.000,00|  15-30-2021|  ARGENTINA      |       
|      DU |        40.983.217|  05|  01|  138|   $ 5.000.000,00|  30-12-2021|  ARGENTINA      |       
|      DU |        40.983.217|  05|  01|  138|   $ 5.000.000,00|  30-12-2021|  ARGENTINA      |
|      DU |        50.348.901|  03|  03|  125|   $ 1.000.000,40|  30-12-2021|  ARGENTINA      |
|      DU |        51.490.238|  04|  02|  126|   $    40.000,00|  30-12-2021|  ARGENTINA      |
|      DU |        56.120.987|  05|  12|  131|   $         8,00|  30-12-2021|  ARGENTINA      |
|      DU |        53.789.124|  05|  03|  128|   $    30.000,00|  30-12-2021|  ARGENTINA      |
                                                                                               
 DU     TOTAL CLIENTE/CUENTA POR SUCURSAL:   4- 8-2025    NUMERO PAGINA:  3                    
-----------------------------------------------------------------------------------------------
|TIPO DOC.| NUM. DOCUMENTO   |SUC.|TIPO| NUM.|    IMPORTE      |   FECHA    |    LOCALIDAD    |
-----------------------------------------------------------------------------------------------
|      DU |        54.890.213|  04|  02|  129|   $    80.000,00|  30-12-2021|  ARGENTINA      |
|      DU |        52.678.145|  05|  01|  128|   $    10.000,00|  30-12-2021|  ARGENTINA      |
|      DU |        58.341.209|  05|  02|  135|   $    10.000,00|  30-12-2021|  ARGENTINA      |
|      DU |        51.239.876|  05|  02|  135|   $    10.000,00|  30-12-2021|  PARAGUAY       |
|      DU |        63.981.234|  02|  02|  124|  -$     2.000,00|  30-12-2021|  CHILE          |
|      DU |        60.547.812|  03|  02|  139|   $    60.000,00|  30-12-2021|  ARGENTINA      |
|      DU |        62.890.145|  04|  01|  142|   $40.080.000,00|  15-30-2021|  ARGENTINA      |
|      DU |        67.543.219|  05|  12|  131|   $         8,00|  30-12-2021|  BRAZIL         |
|      DU |        65.234.987|  04|  03|  126|   $    40.000,00|  30-12-2021|  PARAGUAY       |
|      DU |        66.389.012|  05|  03|  128|   $    30.000,00|  30-12-2021|  BRAZIL         |
|      DU |        64.123.567|  03|  02|  125|   $ 1.000.000,40|  30-12-2021|  BOLIVIA        |
|      DU |        70.128.456|  03|  02|  139|   $    60.000,00|  30-12-2021|  PERU           |
|      DU |        79.345.671|  04|  01|  126|   $ 1.000.003,00|  30-12-2021|  URUGUAY        |
|      DU |        74.569.014|  05|  01|  132|   $       700,00|  30-12-2021|  BOLIVIA        |
|      DU |        73.458.923|  05|  01|  134|   $   200.000,00|  30-12-2021|  PARAGUAY       |
                                                                                               
 DU     TOTAL CLIENTE/CUENTA POR SUCURSAL:   4- 8-2025    NUMERO PAGINA:  4                    
-----------------------------------------------------------------------------------------------
|TIPO DOC.| NUM. DOCUMENTO   |SUC.|TIPO| NUM.|    IMPORTE      |   FECHA    |    LOCALIDAD    |
-----------------------------------------------------------------------------------------------
|      DU |        77.982.347|  05|  02|  128|   $    30.000,00|  30-12-2021|  BRAZIL         |
|      DU |        76.891.236|  05|  01|  129|   $       400,00|  30-12-2021|  URUGUAY        |
|      DU |        71.234.589|  05|  01|  138|   $ 5.000.000,00|  30-12-2021|  PERU           |
|      DU |        78.123.450|  04|  03|  126|   $    40.000,00|  30-12-2021|  ECUADOR        |
|      DU |        70.128.456|  03|  02|  141|   $ 8.000.000,00|  30-12-2021|  CHILE          |
|      DU |        72.347.801|  05|  03|  136|   $    80.000,00|  30-12-2021|  URUGUAY        |
|      DU |        72.347.801|  05|  03|  136|   $    80.000,00|  30-12-2021|  URUGUAY        |
|      DU |        75.670.125|  05|  11|  130|   $    60.000,00|  30-12-2021|  PERU           |
|      DU |        71.234.589|  03|  02|  141|   $ 8.000.000,00|  30-12-2021|  BOLIVIA        |
|      DU |        80.456.782|  03|  02|  125|   $ 1.000.000,40|  30-12-2021|  URUGUAY        |
|      DU |        81.567.893|  01|  01|  124|  -$    10.000,00|  00-00-0000|  ECUADOR        |

          CANTIDAD TIPO CUENTA DU    55                                                        
                                                                                               
                                                                                               
|      PA |        35.987.654|  05|  01|  130|   $    90.000,00|  30-12-2021|  ARGENTINA      |
|      PA |        57.234.896|  04|  02|  133|   $    40.000,00|  30-12-2021|  ARGENTINA      |
|      PA |        59.432.178|  05|  01|  137|   $    40.000,00|  30-12-2021|  ARGENTINA      |
|      PA |        55.987.412|  05|  01|  130|   $    90.000,00|  30-12-2021|  ARGENTINA      |
|      PA |        68.765.430|  04|  02|  133|   $    40.000,00|  30-12-2021|  URUGUAY        |
                                                                                               
 PA     TOTAL CLIENTE/CUENTA POR SUCURSAL:   4- 8-2025    NUMERO PAGINA:  5                    
-----------------------------------------------------------------------------------------------
|TIPO DOC.| NUM. DOCUMENTO   |SUC.|TIPO| NUM.|    IMPORTE      |   FECHA    |    LOCALIDAD    |
-----------------------------------------------------------------------------------------------
|      PA |        69.012.348|  05|  01|  137|   $    40.000,00|  30-12-2021|  BOLIVIA        |

          CANTIDAD TIPO CUENTA PA     6                                                        
                                                                                               
                                                                                               
|      PE |        41.876.530|  03|  01|  140|   $    70.000,00|  30-12-2021|  ARGENTINA      |
|      PE |        69.012.348|  04|  02|  143|   $    50.000,00|  30-02-2021|  URUGUAY        |
|      PE |        61.789.234|  03|  01|  140|   $    70.000,00|  30-12-2021|  ARGENTINA      |
|      PE |        82.789.004|  04|  02|  143|   $    50.000,00|  30-02-2021|  PERU           |

          CANTIDAD TIPO CUENTA PE     4                                      
             
```

<div style="text-align: right;">

[( 🏠 )](/)

</div>