<div style="text-align: right;">

[( 🏠 )](/)

</div>

# 📄 Doble Corte de Control con Verificación
- Entrada: archivo QSAM
- Salida: sysout display
## 📚 Descripción del Programa
El programa `PROGM07A` realiza un **doble corte de control** por tipo de documento y luego por sexo del cliente luego de haber validado el tipo de documento sea igual al especificado. Muestra la cantidad por cada corte de control y el total de registros. Se trata de un ejemplo típico de procesamiento secuencial y agrupamiento de registros en COBOL, utilizado en el contexto del curso de Programación en Mainframe.

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│ ├── PROGM07A.cbl # Programa COBOL 
│ ├── COPY/
│ │ ├── CLICOB # Copybook (embebido para tener de referencia)
│
├── jcl/
│ ├── COMPILA.jcl # JCL para precompilar
│ ├── EJECUTA.jcl # JCL para ejecutar
│
├── README.md
```
</br>

### 📋 Archivos Involucrados

- **Programa**: `PROGM07A.cbl` Programa fuente de corte de control.
- **JCL**: \
`COMPILA.jcl`: Compila un programa COBOL batch.
  1. Usa una librería de PROCs (ORIGEN.CURSOS.PROCLIB).
  2. Ejecuta el PROC COMPCOTE, que compila un programa COBOL batch.
  3. Compila el programa PROGM07A que debe estar en la librería USUARIO.CURSOS.
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

## 🏛️ Estructura del Programa 
- **1000-INICIO**: 
  - Abre el archivo y valida que se abrió bien.
  - Lee el primer registro fuera del bucle.
  - Si el archivo no está vacío:
    - Guarda los valores actuales de tipo de documento y sexo como “anteriores”.
    - Inicializa los contadores.
    - Muestra el encabezado del primer tipo de documento.


- **2000-PROCESO**: 
  - Lee un nuevo registro.
  - Si es fin de archivo, hace el corte final de tipo de documento.
  - Si no, verifica:
      - Si el tipo de documento es válido (DU, PA, PE, CI).
          - Si es igual al anterior:
              - Si también es del mismo sexo, **sigue contando**.
              - Si cambia de sexo, hace el **corte de sexo**.
          - Si cambia el tipo de documento, hace **corte doble** (tipo y sexo).
- **2300-CORTE-TIPDOC – Corte Mayor**
  - Hace primero el corte de sexo pendiente.
  - Muestra el total por tipo de documento anterior.
  - Si no es el final del archivo, muestra encabezado para el nuevo tipo.
  - Reinicia los contadores para el nuevo grupo.

- **2600-CORTE-SEXO – Corte Menor**
  - Muestra el total acumulado del sexo anterior.
  - Reinicia contador y actualiza el sexo actual.

- **2500-LEER – Leer registro**
  - Lee un registro del archivo y lo guarda en `WS-REG-CLICOB`.
  - Si la lectura es exitosa (`00`), incrementa contador.
  - Si es fin de archivo (`10`), marca final.
  - Si es otro error, lo muestra y también termina la lectura.

- **9999-FINAL – Cierre**
  - Muestra el total de registros procesados.
  - Cierra el archivo.
  - Si falla el `CLOSE`, muestra error y retorna código 9999.

---
## 📊 Diagrama de Flujo
<image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">

---

## 🎯 Resultado

### 💬 Display 
```TEXT
=================================                                               
TIP-DOC = CI                                                                    
                                                                                
TOTAL SEXO F   2                                                                
TOTAL SEXO O   1                                                                
TOTAL TIPO DOCU =   3                                                           
                                                                                
=================================                                               
TIP-DOC = DU                                                                    
                                                                                
TOTAL SEXO F   2                                                                
TOTAL SEXO M   6                                                                
TOTAL TIPO DOCU =   8                                                           
                                                                                
=================================                                               
TIP-DOC = PA                                                                    
                                                                                
TOTAL SEXO F   3                                                                
TOTAL SEXO M   2                                                                
TOTAL TIPO DOCU =   5                                                           
                                                                                
=================================                                               
TIP-DOC = PE                                                                    
                                                                                
TOTAL SEXO F   3                                                                
TOTAL SEXO M   5                                                                
TOTAL TIPO DOCU =   8                                                           
                                                                                
**********************************************                                  
TOTAL REGISTROS =  24
```

<div style="text-align: right;">

[( 🏠 )](/)

</div>