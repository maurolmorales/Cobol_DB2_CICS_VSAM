# 📄 Corte de Control
- Entrada: archivo QSAM
- Salida: sysout display
## 📚 Descripción del Programa
El programa `MLM2CCAF` realiza un **corte de control por número de sucursal**, acumulando los importes de cada una. Se trata de un ejemplo típico de procesamiento secuencial y agrupamiento de registros en COBOL, utilizado en el contexto del curso de Programación en Mainframe.

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│ ├── MLM2CCAF.cbl # Programa COBOL 
│ ├── COPY/
│ │ ├── CORTE # Copybook (embebido para tener de referencia)
│
├── jcl/
│ ├── COMPILA.jcl # JCL para precompilar
│ ├── EJECUTA.jcl # JCL para ejecutar
│
├── README.md
```
</br>

### 📋 Archivos Involucrados

- **Programa**: `MLM2CCAF.cbl` Programa fuente de corte de control.
- **JCL**: \
`COMPILA.jcl`: Compila un programa COBOL batch.
  1. Usa una librería de PROCs (ORIGEN.CURSOS.PROCLIB).
  2. Ejecuta el PROC COMPCOTE, que compila un programa COBOL batch.
  3. Compila el programa MLM2CCAF que debe estar en la librería USUARIO.CURSOS.
  4. (Opcional) Le pasa una librería de COPYBOOKs a través del DD COBOL.SYSLIB. 

  `EJECUTA.jcl`: Trata el archivo de entrada y ejecuta el programa.
  1. Borra (si existe) el archivo USUARIO.ARCHIVO.SORT.
  2. Ordena USUARIO.ARCHIVOS por los primeros 2 bytes y genera USUARIO.ARCHIVO.SORT.
  3. Ejecuta el programa PGM2CCAF usando como entrada ARCHIVO.SORT y graba salida en SYSOUT.


- **Archivos de datos**:
  - `KC03CAF.ARCHIVOS.CORTE`: Archivo QSAM de 20 bytes de largo de clientes. 
  - `KC03CAF.ARCHIVOS.CORTE.SORT`: Archivo QSAM de 20 bytes generado mediante EJECUTA.jcl ordenado 
- **Copybooks utilizados**:
  - `CORTE`: Embebido para tener de referencia en el programa.
---

## 🏛️ Estructura del Programa 
- **1000-INICIO**: 
  - Abre el archivo de entrada.
  - Si el OPEN falla, muestra mensaje y marca fin de lectura.
  - Si abre bien, lee el primer registro.
  - Si hay datos, inicializa variables con los datos leídos.
- **2000-PROCESO**: 
Lee un nuevo registro.
  - Si ya no hay más registros, hace el último corte.
  - Si hay datos:
    - Si la sucursal es la misma que la anterior, sigue acumulando.
    - Si la sucursal cambió, ejecuta el corte y comienza acumulador para la nueva.
- **2200-CORTE-MAYOR – Corte de control**
  - Muestra el subtotal de una sucursal.
  - Suma ese importe al total general.
  - Reinicia acumulador para la próxima sucursal.
- **2100-LEER – Leer archivo**
  - Lee un nuevo registro en la estructura.
  - Evalúa el código de estado (FS-ENT) y determina si hay más registros o fin de archivo.
- **9999-FINAL – Cierre**
  - Muestra el importe total de todas las sucursales.
  - Cierra el archivo de entrada.
  - Si hubo error al cerrar, lo muestra y define un código de retorno.

---


## 🎯 Resultado

### 💬 Display 
```TEXT
=================================                                  
NUM-SUC: 01 
IMPORTE: $     21.801,50                                           
---------------------------------                                  
            
=================================                                  
NUM-SUC: 02 
IMPORTE: $     32.000,60                                           
---------------------------------                                  
            
=================================                                  
NUM-SUC: 45 
IMPORTE: $        410,00                                           
---------------------------------                                  
            
=================================                                  
NUM-SUC: 49 
IMPORTE: $     33.450,00                                           
---------------------------------                                  
            
**********************************************                     
IMPORTE TOTAL = $     87.662,10                                    
```