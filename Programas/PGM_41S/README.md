<div style="text-align: right;">

[( 🏠 )](/)

</div>

# 📄 Actualizador de novedades de clientes (QSAM → DB2)
- **Input**: `NOVEDADES` (QSAM, 80 bytes, archivo de entrada con novedades de clientes).
- **Output**: `ERRORES` (QSAM, FBA 132 bytes, listado de errores).
## 📚 Descripcion del Programa
Este programa COBOL (`PGMD1CAF`) procesa novedades de clientes para actualizar la tabla `TBCURCLI` en DB2.  
- **Propósito**: Validar modificaciones de clientes (cambio de número de cliente, nombre o sexo) y actualizar los registros correspondientes en la base de datos.  
- **Complemento**: En caso de errores, genera un archivo de salida con un listado formateado y estadísticas al final.  
- **Incluye**: Programa COBOL con SQL embebido, archivos QSAM de entrada/salida, JCLs para compilar/ejecutar, y copybooks (`SQLCA`, `TBCURCLI`).  

</br>

---

### 🚀 Estructura del Proyecto

```
├── src/
│ ├── PGMD1CAF.cbl # Programa COBOL con SQL embebido
│ ├── COPY/
│ │ ├── SQLCA.cpy # Copybook estándar para manejo de SQLCODE
│ │ ├── TBCURCLI.cpy # Copybook DCLGEN tabla clientes
│
├── jcl/
│ ├── COMPILA.jcl # JCL para precompilar, compilar y link-edit
│ ├── BIND.jcl # JCL para hacer el BIND del DBRM al PLAN
│ ├── EJECUTA.jcl # JCL para ejecutar el load module
│
├── README.md
```
</br>

### 📋 Archivos Involucrados

- **Programa**: `PGMD1CAF.cbl`  
  Procesa novedades de clientes, valida campos según el tipo de novedad y actualiza `TBCURCLI`.  

- **JCL**:
  - `COMPILA.jcl`: Compila el programa contra DB2.
  - `BIND.jcl`: Realiza el `BIND` del DBRM generado y lo asocia al plan correspondiente.
  - `EJECUTA.jcl`: Ejecuta el programa con sus DDs de entrada (`DDENTRA`) y salida (`DDSALID`).  

- **Archivos de datos**:
  - `KC03CAF.ARCHIVOS.NOVEDADES`: Archivo secuencial QSAM de entrada (80 bytes, FB).
  - `KC03CAF.ARCHIVOS.ERRORES`: Archivo secuencial QSAM de salida (132 bytes, FBA).

- **Copybooks utilizados**:
  - `SQLCA`: Área estándar de comunicación con DB2.
  - `TBCURCLI`: Estructura DCLGEN de la tabla de clientes (`TIPDOC, NRODOC, NROCLI, NOMAPE, FECNAC, SEXO`).

---

## ▶️ Descripción del JCL
#### 🪛 `COMPILA.jcl`
Precompila el programa COBOL con SQL embebido, compila el código fuente y realiza el link-edit, generando un módulo ejecutable.  

#### 🔗 `BIND.jcl`
Genera el plan en DB2 y asocia el DBRM del programa al mismo, habilitándolo para ejecución contra la base de datos.  

#### 🛠️ `EJECUTA.jcl`
Ejecuta el programa indicando DDs de entrada y salida. Al finalizar genera la salida impresa con errores y muestra estadísticas en `SYSOUT`.  


---

## 🏛️ Estructura del Programa 
- **1000-INICIO**: Apertura de archivos, inicialización de variables y lectura del primer registro.  
- **2000-PROCESO**: Ciclo principal que valida cada novedad y decide si grabar o rechazar.  
- **2100-LEER**: Lee el archivo de entrada, controla fin de archivo y actualiza contadores.  
- **2200-VERIFICAR**: Verifica los datos según el tipo de novedad (`CL`, `CN`, `CX`).  
- **2300-HANDLE-ERROR**: Maneja errores de validación, imprime detalle en archivo de salida y actualiza contadores.  
- **2400-GRABAR-REG**: Prepara datos y ejecuta actualización en DB2.  
- **2410 / 2420 / 2430-UPDATE**: Ejecutan el `UPDATE` en `TBCURCLI` según campo modificado.  
- **9999-FINAL**: Cierre de archivos y muestra de estadísticas en `SYSOUT`. 
---

## ⚙️ Secuencia del Programa
1. **Inicio**
   - Abrir archivos de entrada y salida.
   - Leer primer registro.
2. **Proceso**
   - Validar registro según tipo de novedad.
   - Si válido → ejecutar `UPDATE` en DB2.
   - Si inválido → imprimir detalle en archivo de salida.
   - Leer siguiente registro y repetir.
3. **Final**
   - Cerrar archivos.
   - Mostrar por `DISPLAY` las estadísticas: total leídas, con error y grabadas.  


---

## 📊 Diagrama de Flujo
<image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">

---


## 🎯 Resultado

### 💾 Archivo de Entrada `Novedades`
```text
NOV-TIP-NOV NOV-TIP-DOC  NOV-NRO-DOC NOV-CLI-NRO NOV-CLI-APELLIDO               NOV-CLI-FENAC NOV-CLI-SEXO FILLER    
#2          #3                    #4          #5 #6                             #7            #8           #9        
AN 1:2      AN 3:2           ZD 5:11     ZD 16:3 AN 19:30                       AN 49:8       AN 57:1      AN 58:23  
<>          <>          <---+----1->        <--> <---+----1----+----2----+----> <---+-->      -            <---+----1
****  Top of data  ****                          ****  Top of data  ****                                             
CN          PA           00186569890         455 MORALES SAMUEL, WILSON         19850820      M                      
CL          DU           00186567890         777 MORALES CAROLINA, DANVERS      19751205      F                      
AL          DU           77321654000         707 MORALES PUENTES, GUILLERMO     19800505      M                      
CN          PE           00982356440         502 MORALES ESTEBAN, TRABAJOS      19950211      M                      

```
<br />

### 🖨️ Archivo de Salida `Errores`
```text
MODIFICACIONES LEÍDAS - DETALLE DE ERRORES                                  
 | TIP-DOC |     NRO-DOC | NRO-CLI |             NOMAPE             | SEXO | FECHA NAC | 
                                                                            
MOTIVO DEL ERROR: TIPO DE NOVEDAD NO VÁLIDO                                 
 |      DU | 00186567890 |     777 | MORALES CAROLINA, DANVERS      |    F |  19751205 | 
```
<br />

### 💬 Display 
```text
REGISTRO GRABADO                                         
REGISTRO GRABADO                                         
REGISTRO GRABADO                                         
**********************************************           
TOTAL MODIFICACIONES LEÍDAS:   4                         
TOTAL MODIFICACIONES CON ERROR:   1                      
TOTAL MODIFICACIONES GRABADAS EN TABLA:   3         
```     