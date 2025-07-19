# Doble Corte de Control Mas Impresión.

## 📚 Descripción del programa

Este programa COBOL (`PGM5CCAF`) realiza un procesamiento batch que:

- Lee un archivo secuencial de clientes.
- Aplica cortes de control por **sucursal (`CLIS-SUC`)** y luego por **tipo de cliente (`CLIS-TIPO`)**.
- Acumula importes y cantidades por grupo.
- Genera un archivo de salida con subtotales y totales.
- Imprime por `DISPLAY` los registros procesados, saldos y errores.
---

## 🚀 Estructura del proyecto
```
├── programa/
│ └── PGM5CCAF.cbl 
│
├── jcl/
│ ├── COMPILA.jcl # JCL para compilar (usa PROCLIB)
│ └── EJECUTA.jcl # JCL para ejecución, incluye SORT
│
├── data/
│ ├── CLIENTES # Archivo de entrada no ordenado
│ ├── CLIENTES.SORT # Archivo ordenado (intermedio)
│ └── LISTADO # Salida con información resumida
│
├── README.md
```

### 📋 Archivos involucrados

- **Programa**: `PGM5CCAF.cbl` (programa fuente principal).
- **JCL**:
  - `COMPILA.jcl` (compilación del programa).
  - `EJECUTA.jcl` (ejecución del programa + preprocesamiento de datos).
- **Archivos de datos**:
  - `USUARIO.ARCHIVOS.CLIENTES`: archivo original sin ordenar.
  - `USUARIO.ARCHIVOS.CLIENTES.SORT`: archivo ordenado por sucursal y tipo.
  - `USUARIO.ARCHIVOS.LISTADO`: salida del listado con subtotales y totales.
- **Copy**:
  - Se utiliza copybook externo. A modo de facilitar el entendimiento, la estructura de entrada está definida en el mismo programa (`REG-CLIENTES`).

---

### ▶️ Descipción del JCL

#### 🪛 `COMPILA.jcl`

Utiliza una *PROCEDURE* (`COMPCOTE`) con parámetros para compilar el programa COBOL:

```jcl
//STEP1    EXEC COMPCOTE, 
//         ALUMLIB=USUARIO.CURSOS, 
//         GOPGM=PGM5CCAF
```

Incluye definición de biblioteca de copys (SYSLIB) si se requiere.

Produce un load module que se puede ejecutar con run.jcl.

#### 🛠️ `EJECUTA.jcl`
Contiene tres pasos:

1. `IDCAMS (STEP1)`: elimina archivos anteriores (LISTADO, CLIENTES.SORT).

2. `SORT (STEP2)`: ordena el archivo original por CLIS-SUC (pos 14,2) y CLIS-TIPO (pos 16,2).

3. `PGM5CCAF (STEP3)`: ejecuta el programa con los archivos correctos:

```jcl
//DDENTRA  DD DSN=USUARIO.ARCHIVOS.CLIENTES.SORT,DISP=SHR
//DDLISTA  DD DSN=USUARIO.ARCHIVOS.LISTADO,UNIT=SYSDA,...
```
---

## 🏛️ Estructura del Programa
División de procedimientos:
-  `1000-INICIO`: Apertura de archivos, inicialización de variables y primera lectura.

- `2000-PROCESO`: Bucle principal. Lee registros, detecta cambios de grupo y llama a cortes.

- `2300-CORTE-MAYOR`: Imprime subtotal por sucursal y reinicia acumuladores.

- `2600-CORTE-MENOR`: Imprime subtotal por tipo de cliente y acumula para la sucursal.

- `2500-LEER`: Maneja la lectura de registros y estados del archivo.

- `9999-FINAL`: Cierra archivos, imprime totales finales y termina el programa.

---

## ⚙️ Secuencia del programa

1. **Inicio**
   - Abre los archivos.
   - Lee el primer registro.
   - Inicializa acumuladores y guarda claves de corte (`CLIS-SUC`, `CLIS-TIPO`).

2. **Proceso**
   - Bucle de lectura hasta fin de archivo (`WS-FIN-LECTURA = 'Y'`).
   - Detecta cambios de tipo o sucursal.
   - En cada cambio, imprime subtotales y reinicia acumuladores.

3. **Final**
   - Al llegar al EOF:
     - Imprime últimos subtotales.
     - Calcula e imprime totales generales (cantidad de registros y saldo acumulado).
   - Cierra los archivos.
---


## 🎯 Formato del archivo de salida y Display
El archivo de salida `LISTADO` contiene líneas formateadas con información agrupada. Ejemplo de líneas que se generan:

#### 💬 DISPLAY
```texto
=================================           
SUCURSAL: 01                                
---------------------------------           
TIPO: 01 CANT:   2 SALDO: -$     20.000,00  
TIPO: 03 CANT:   2 SALDO: -$      4.000,00  
TOTAL => CANT:   4 SALDO: -$     24.000,00  
                                            
=================================           
SUCURSAL: 02                                
---------------------------------           
TIPO: 01 CANT:   2 SALDO: -$        600,00  
TIPO: 02 CANT:   4 SALDO: -$  8.004.000,00  
TIPO: 03 CANT:   2 SALDO: -$  8.000.000,00  
TOTAL => CANT:   8 SALDO: -$ 16.004.600,00  
                                           
...

=================================                
SUCURSAL: 05                                     
---------------------------------                
TIPO: 01 CANT:  14 SALDO:  $ 10.682.200,00       
TIPO: 02 CANT:   4 SALDO:  $     80.000,00       
TIPO: 03 CANT:   4 SALDO:  $    220.000,00       
TIPO: 11 CANT:   2 SALDO:  $    120.000,00       
TIPO: 12 CANT:   2 SALDO:  $         16,00       
TOTAL => CANT:  26 SALDO:  $ 11.102.216,00       
                                                 
**********************************************   
TOTAL REGISTROS =  65                            
TOTAL SALDO =  $ 98.022.823,60                       
```
</br>

#### 📁 Archivo QSAM LISTADO
```TEXT
SUCURSAL: 01                               
TIPO:  1  -$     20.000,00                 
TIPO:  3  -$      4.000,00                 
                                           
SUCURSAL: 02                               
TIPO:  1  -$        600,00                 
TIPO:  2  -$  8.004.000,00                 
TIPO:  3  -$  8.000.000,00                 
                                           
...                
                                           
SUCURSAL: 05                               
TIPO:  1   $ 10.682.200,00                 
TIPO:  2   $     80.000,00                 
TIPO:  3   $    220.000,00                 
TIPO: 11   $    120.000,00                 
TIPO: 12   $         16,00                 
********************                       
TOTAL REGISTROS =  65                      
TOTAL SALDO =  $ 98.022.823,60             

```


