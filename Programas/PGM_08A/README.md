<div style="text-align: right;">

[( 🏠 )](/)

</div>

# 📄 Validación de Registros
  - ENTRADA: Archivo QSAM. 
  - SALIDA: Archivo QSAM.
## 📚 Descripción del Programa
**PGMVACAF** es un programa cuyo objetivo es procesar un archivo de entrada con novedades de clientes, validar la información (principalmente la fecha y el tipo de documento) y generar un archivo de salida con los registros válidos.  
Los registros con datos inválidos se informan mediante mensajes en 
consola y no se graban.

---

### 🚀 Estructura del Proyecto

```
├── src/
│ ├── PGMVACAF.cbl # Programa COBOL 
│ ├── COPY/
│   ├── CPNOVCLI  # Copybook (embebido para tener de referencia)
│   ├── CPNCLIV   # Copybook (embebido para tener de referencia)
│
├── jcl/
│ ├── COMPILA.jcl # JCL para precompilar
│ ├── EJECUTA.jcl # JCL para ejecutar
│
├── archivos/
│ ├── NOVCLIEN        # archivo QSAM de entrada de datos.
│ ├── NOVCLIEN.VALID  # archivo QSAM de salida de datos.
|
├── README.md
```
</br>

### 📋 Archivos Involucrados

- **Programa**: `PGMVACAF.cbl` Programa fuente de validación.
- **JCL**: \
`COMPILA.jcl`: Compila un programa COBOL batch.
  1. Usa una librería de PROCs (ORIGEN.CURSOS.PROCLIB).
  2. Ejecuta el PROC COMPCOTE, que compila un programa COBOL batch.
  3. Compila el programa PGMCORT2 que debe estar en la librería USUARIO.CURSOS.
  4. (Opcional) Le pasa una librería de COPYBOOKs a través del DD COBOL.SYSLIB. 

  `EJECUTA.jcl`: Trata el archivo de entrada y ejecuta el programa.
  1. Borra (si existe) el archivo USUARIO.ARCHIVO.SORT.
  2. Ordena USUARIO.ARCHIVOS por los primeros 2 bytes y genera USUARIO.ARCHIVO.SORT.
  3. Ejecuta el programa PGMVACAF usando como entrada ARCHIVO.SORT y 
  genera un archivo resultante. Graba salida en SYSOUT.

- **Archivos de datos**:
  - `USUARIO.ARCHIVOS.NOVCLIEN`: Archivo QSAM de 50 bytes de largo de clientes. 
  - `USUARIO.ARCHIVOS.NOVCLIEN.VALID`: Archivo QSAM de 55 bytes generado mediante EJECUTA.jcl.
- **Copybooks utilizados**:
  - `CPNOVCLI`: Contiene datos de novedades de clientes.
  - `CPNCLIV`: Incluye número secuencial y resto de datos validados.

---

## 🏛️ Estructura del Programa 

  - **1000-INICIO**
    - Abre archivos de entrada (ENTRADA) y salida (SALIDA).
    - Si hay error en OPEN, lo muestra por pantalla y termina.
    - Si la entrada abre bien, lee el primer registro (2100-LEER-I).
  - **2000-PROCESO**
    - **2010-VERIFICAR**
      - Se ejecuta en ciclo hasta `FS-ENTRADA-FIN`.
      - Valida el tipo de documento (`DU`, `PA`, `PE`, `CI`).
      - Valida si el número de documento es de tipo numérico. 
      - Valida si la sucursal se encuentra entre los números 1 y 3.
      - Verifica la fecha estén dentro de los parámetros correspondientes (`2020-VERIF-FECHA`).
      - Si se verifica todo: graba el registro (2200-GRABAR-REG).
        - Si no es válido: lo rechaza y muestra mensaje por display.
    - **2100-LEER** 
      - lee el siguiente registro

  - **2020-VERIF-FECHA**
    - Convierte `NOV-CLI-FECHA` en formato de año, mes y día.
    - Valida:
      - Que el año sea >= 2025.
      - Que el mes esté entre 1 y 12.
      - Que el día sea coherente según el mes (31, 30, 28 o 29 para años bisiestos).
    - Si alguna condición falla, muestra un mensaje de error y marca el registro como inválido.
  - **2100-LEER**
    - Realiza `READ ENTRADA INTO WS-REG-NOVCLIE`.
    - Si es exitoso ('`00`'): incrementa contador de leídos.
    - Si EOF ('`10`'): no hace nada.
    - Si otro error: muestra mensaje y finaliza con error.
  - **2025-HANDLE-ERROR**
    - Cambia a `'No'` en `WS-REG-VALIDO`
    - Muestra por display el error encontrado.  
  - **2200-GRABAR-REG**
    - Incrementa `NOV-SECUEN`.
    - Copia `WS-REG-NOVCLIE` en el registro de salida (`NOV-RESTO`).
    - Escribe `REG-SALIDA` desde `REG-NOVCLIE-VAL`.
    - Si es exitoso ('`00`'): muestra mensaje de registro grabado.
    - Si error: muestra error y finaliza proceso.
  - **3000-FINAL**
    - Si no hubo errores (`RETURN-CODE <> 9999`), realiza:
    - `3010-CLOSE-FILES`
    - `3020-MOSTRAR-TOTALES`
  - **3010-CLOSE-FILES**
    - Cierra ambos archivos.
    - Si falla el `CLOSE`, lo informa y termina con error.
  - **3020-MOSTRAR-TOTALES**
    - Muestra:
      - Total de registros leídos.
      - Total de registros grabados.
      - Total de registros erróneos.

---
## 📊 Diagrama de Flujo
<image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">

---

## 🎯 Resultado

### 💬 Display 
```text
----------------------------                                                  
REGISTRO OK - DOC: DU NRO: 90323335999                                        
----------------------------                                                  
REGISTRO INVÁLIDO: DU NRO: 00126789000 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: DU NRO: 00126789000 CAUSA: DÍA INVÁLIDO PARA MES DE 31 DÍAS
----------------------------                                                  
REGISTRO INVÁLIDO: PA NRO: 90223373999 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: PA NRO: 90223373999 CAUSA: FEBRERO INVÁLIDO                
----------------------------                                                  
REGISTRO OK - DOC: PA NRO: 12312312312                                        
----------------------------                                                  
REGISTRO OK - DOC: CI NRO: 00136555000                                        
----------------------------                                                  
REGISTRO INVÁLIDO: PA NRO: 00083333999 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: CC NRO: 00123333300 CAUSA: TIPO DOC NO VALIDO              
----------------------------                                                  
REGISTRO INVÁLIDO: CC NRO: 00123333300 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: LD NRO: 00123449000 CAUSA: TIPO DOC NO VALIDO              
----------------------------                                                  
REGISTRO INVÁLIDO: LD NRO: 00123449000 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: LD NRO: 00123449000 CAUSA: DÍA INVÁLIDO PARA MES DE 30 DÍAS
----------------------------                                                  
REGISTRO INVÁLIDO: DU NRO: 09888000000 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: DU NRO: 00188889000 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: DU NRO: 00022000160 CAUSA: AÑO INVÁLIDO < 2025             
----------------------------                                                  
REGISTRO INVÁLIDO: PE NRO: 00777789000 CAUSA: AÑO INVÁLIDO < 2025             
REGISTRO INVÁLIDO: DU NRO: 00023000190 CAUSA: AÑO INVÁLIDO < 2025              
----------------------------                                                   
REGISTRO INVÁLIDO: DU NRO: 00023000190 CAUSA: DÍA INVÁLIDO PARA MES DE 31 DÍAS 
==============================                                                 
 TOTAL DE ENTRADAS LEIDAS:     13                                              
 TOTAL DE REGISTROS GRABADOS:   3                                              
 TOTAL DE REGISTROS ERRÓNEOS:  10                                              
```
### 💾 Archivo QSAM DDSALID 
```TEXT
NOV-SECUEN    NOV-RESTO
00001         DU903233359990101111......20250425
00004         PA123123123120202114......20250430
00005         CI001365550000202130......20250430
```


<div style="text-align: right;">

[( 🏠 )](/)

</div>
