# 🧾 Doble Corte de Control con Entrada VSAM

## 📚 Descripción del programa
Este programa COBOL batch realiza un **doble corte de control** sobre un archivo VSAM (KSDS) de entrada que contiene registros de clientes. El objetivo es agrupar y acumular importes (`CLI-SALDO`) por:

  **1**. **Sucursal (`CLI-NRO-SUC`)** - Corte de control mayor. \
  **2**. **Tipo de cuenta (`CLI-TIP-CUE`)** - Corte de control menor. \
Al finalizar cada grupo (por tipo de cuenta y luego por sucursal), se imprime el total acumulado. También se muestra el total general al final del procesamiento.



--- 

## 🚀 Estructura del proyecto
```
├── programa/
│   └── PGMBMLM.cbl
│
├── jcl/
│   ├── COMPILA.jcl   # Compilación con procedimiento COMPDB2
│   └── EJECUTA.jcl   # Ejecución del programa
│
|── archivo/
│   ├── ORIGEN.CLIENT1.KSDS.VSAM    # Archivo tipo VSAM KSDS de entrada.
│   ├── KC03CAF.ARCHIVOS.DATA.SORT  # Archivo generado QSAM ordenado. 
|
├── README.md
```

### 📋 Archivos involucrados

- **Programa**: `PGMBMLM.cbl` (fuente principal en COBOL con SQL embebido).
- **JCL**:
  - `COMPILA.jcl`: Compila el programa usando `COMPDB2`.
  - `BIND.jcl`: Genera el plan `CURSOCAF` asociado al programa.
  - `EJECUTA.jcl`: Ejecuta el programa contra DB2, generando la salida.

- **Copybooks utilizados**:
  - `DCLTBCURCLI`: estructura de cliente. (`NOMAPE`). 
  - `DCLTBCURCTA`: estructura de cuenta (`TIPCUEN`, `NROCUEN`, `SALDO`, etc.).

---

### ▶️ Descipción del JCL

#### 🪛 `COMPILA.jcl`
Compila un programa COBOL batch.
  1. Usa una librería de PROCs (ORIGEN.CURSOS.PROCLIB).
  2. Ejecuta el PROC COMPCOTE, que compila un programa COBOL batch.
  3. Compila el programa MLM2CCAF que debe estar en la librería USUARIO.CURSOS.
  4. (Opcional) Le pasa una librería de COPYBOOKs a través del DD COBOL.SYSLIB.

#### 🛠️ `EJECUTA.jcl`
La ejecución del programa `PGMDCCAF` se realiza en tres pasos principales:

  1. STEP 1 – Limpieza del dataset temporal. Se elimina el dataset de trabajo si existe, para evitar conflictos al regenerarlo con el sort.

```jcl
//STEP1    EXEC PGM=IDCAMS,COND=(8,LT) 
//SYSPRINT DD SYSOUT=* 
//SYSIN    DD * 
     DELETE   KC03CAF.ARCHIVOS.DATA.SORT 
     SET MAXCC=0 
```

  2. STEP 2 – Ordenamiento del archivo VSAM. Se ordena el archivo por los campos:
  - `CLI-NRO-SUC` (posición 14, longitud 2)
  - `CLI-TIP-CUE` (posición 16, longitud 2)

  Esto es fundamental para que el programa pueda aplicar correctamente el doble corte de control.

```jcl
//STEP2     EXEC PGM=SORT,COND=EVEN 
//SORTIN    DD DSN=KC02788.ALU9999.CLIENT1.KSDS.VSAM,DISP=SHR 
//SORTOUT   DD DSN=KC03CAF.ARCHIVOS.DATA.SORT,DISP=(,CATLG),
//          DCB=(LRECL=50,RECFM=FB),...
//SYSIN     DD * 
  SORT FORMAT=BI,FIELDS=(14,2,A,16,2,A) 
```

  3.  STEP 3 – Ejecución del programa PGMDCCAF. Se ejecuta el programa con:
  - `STEPLIB` apuntando a la librería de carga donde está el ejecutable.
  - `DDENTRA` con el archivo ordenado como entrada.
  - `SYSOUT` para redireccionar la salida a un spool o dataset.
```jcl
//STEP3    EXEC PGM=PGMDCCAF 
//STEPLIB  DD DSN=KC03CAF.CURSOS.PGMLIB,DISP=SHR 
//DDENTRA  DD DSN=KC03CAF.ARCHIVOS.DATA.SORT,DISP=SHR 
//SYSOUT   DD DSN=KC03CAF.SYSOUT,DISP=SHR 
```




---

## 🏛️ Estructura del Programa  
División de procedimientos:

  - **1000-INICIO**:
    - Inicializa indicadores de fin de lectura y acumuladores.
    - Abre el archivo VSAM de entrada (`DDENTRA`).
    - Realiza la primera lectura del archivo.
    - Si el archivo no está vacío, muestra la cabecera de la primera sucursal.

  - **2000-PROCESO**:
    - Realiza el procesamiento principal del programa.
    - Lee el siguiente registro del archivo.
    - Aplica lógica de doble corte de control:
      - Si cambia el valor de `CLI-NRO-SUC`, realiza corte mayor.
      - Si cambia el valor de `CLI-TIP-CUE`, realiza corte menor.
      - Si no hay cambio, acumula el saldo al subtotal.

  - **2100-LEER**:
    - Lee el siguiente registro del archivo.
    - Controla el `FILE STATUS` (`FS-ENT`).
    - Si `FS-ENT = 00`: incrementa el contador de registros.
    - Si `FS-ENT = 10`: marca fin de lectura (`WS-FIN-LECTURA = Y`).
    - Si otro valor: muestra error y también marca fin.

  - **2200-CORTE-MAYOR**:
    - Se dispara cuando cambia la sucursal (`CLI-NRO-SUC`).
    - Antes de cortar, ejecuta corte menor.
    - Imprime el total acumulado por sucursal.
    - Suma al total general.
    - Reinicia acumulador de sucursal.
    - Muestra encabezado para nueva sucursal.

  - **2300-CORTE-MENOR**:
    - Se dispara cuando cambia el tipo de cuenta (`CLI-TIP-CUE`).
    - Imprime el subtotal acumulado por tipo de cuenta.
    - Reinicia acumulador del tipo de cuenta con el saldo actual.
    - Actualiza el tipo de cuenta de referencia.

  - **9999-FINAL**:
    - Imprime la cantidad total de registros leídos.
    - Imprime el total general de importes acumulados.
    - Cierra el archivo de entrada.
    - Si hubo error en el cierre, lo informa.

---

## ⚙️ Secuencia del programa

1. **Inicio**
    - Se inicializa `WS-FIN-LECTURA` como `'N'` (no fin de lectura).
    - Se abre el archivo de entrada DDENTRA (VSAM).
    - Si la apertura falla (`FS-ENT ≠ '00'`), muestra error y finaliza.
    - Se realiza la primera lectura (`2100-LEER`).
    - Si el archivo está vacío (`WS-FIN-LECTURA` = 'Y'), lo informa.
    - Si no está vacío:
      - Se cargan los valores de sucursal y tipo de cuenta actuales.
      - Se inicia el acumulador del tipo de cuenta.
      - Se imprime encabezado con el número de sucursal.

2. **Proceso**
  - A. 2100-LEER:
    - Se lee el próximo registro.
    - Si fin de archivo (FS-ENT = 10): se marca fin de lectura.
    - Si lectura correcta (FS-ENT = 00): continúa procesamiento.
    - Si otro código: muestra error y finaliza.
  - B. Lógica de corte de control:
    - Se compara el nuevo registro con los valores anteriores:
      - Si la sucursal cambió → se ejecuta `2200-CORTE-MAYOR`.
      - Si solo cambió el tipo de cuenta → se ejecuta `2300-CORTE-MENOR`.
      - Si no cambió ninguno → se acumula el saldo.
    - Luego se continúa el ciclo hasta `WS-FIN-LECTURA = 'Y'`.

3. **Final**
    - Al alcanzar fin de archivo, se ejecuta el corte mayor final para procesar el último grupo.
    - Se imprime la cantidad total de registros procesados.
    - Se imprime el total general acumulado de saldos.
    - Se cierra el archivo `DDENTRA`.
    - Si el cierre da error (`FS-ENT ≠ '00'`), lo informa y retorna código 9999.

---

## 🎯 Resultado

#### 💬 Display 
```texto
=================================        
NUM SUC: 01                              
---------------------------------        
IMPORTE 01: -$     10.000,00             
IMPORTE 03: -$      2.000,00             
---------------------------------        
TOTAL: -$     12.000,00                  
=================================        
                                         
                                         
NUM SUC: 02                              
IMPORTE 01: -$        300,00             
IMPORTE 02: -$  4.002.000,00             
IMPORTE 03: -$  4.000.000,00             
---------------------------------        
TOTAL: -$  8.002.300,00                  
=================================        
                                         
                                         
NUM SUC: 03                              
IMPORTE 01:  $     69.600,00             
IMPORTE 02:  $  9.060.000,40             
IMPORTE 03:  $  1.000.000,40             
---------------------------------        
TOTAL:  $ 10.129.600,80                  
=================================        
                                         
                                         
NUM SUC: 04                              
IMPORTE 01:  $ 41.110.003,00             
IMPORTE 02:  $    210.000,00             
IMPORTE 03:  $     40.000,00             
---------------------------------        
TOTAL:  $ 41.360.003,00                  
=================================        
                                                 
                                                 
NUM SUC: 05                                      
IMPORTE 01:  $  5.341.100,00                     
IMPORTE 02:  $     40.008,00                     
IMPORTE 03:  $    170.000,00                     
---------------------------------                
TOTAL:  $  5.551.108,00                          
=================================                
                                                 
**********************************************   
TOTAL REGISTROS =  33                            
TOTAL IMPORTES  =  $ 49.026.411,80                         
```


