[( 🏠 )](/) </div> 

# 📄 Corte de Control con SQL embebido  
- **Inputs**: Tablas DB2 `TBCURCTA` y `TBCURCLI`  
- **Outputs**: Reporte por `DISPLAY` con cortes de control por sucursal y total general de cuentas  

## 📚 Descripción del Programa 
Este programa COBOL (**PROGM16S**) realiza un **proceso batch con SQL embebido** que obtiene cuentas de clientes con saldo mayor a cero desde DB2, aplicando un **corte de control por sucursal (SUCUEN)** y mostrando subtotales y totales generales por consola.  
- **Propósito del programa**: listar y contabilizar la cantidad de cuentas activas (saldo > 0) agrupadas por sucursal.  
- **Incluye**: código fuente COBOL (`.cbl`), copybooks (`SQLCA`, `DCLGEN` de tablas), JCLs de compilación, bind y ejecución.  

</br>

---

### 🚀 Estructura del Proyecto
```text
├── src/
│ ├── PROGM16S.cbl # Programa COBOL con SQL embebido y JOIN
│ ├── COPY/
│ │ ├── SQLCA.cpy # Copybook estándar para manejo de SQLCODE
│ │ ├── TBCURCTA.cpy # Copybook DCLGEN tabla cuentas
│ │ ├── TBCURCLI.cpy # Copybook DCLGEN tabla clientes
│
├── jcl/
│ ├── compile.jcl # JCL para precompilar, compilar y link-edit
│ ├── bind.jcl # JCL para hacer el BIND del DBRM al PLAN
│ ├── run.jcl # JCL para ejecutar el load module
│
├── README.md
```

</br>

---

### 📋 Archivos Involucrados 
- **Programa**: `PROGM16S.cbl` → Obtiene cuentas con saldo positivo y aplica corte de control por sucursal.  
- **JCL**:  
  - `compile.jcl`: Compila el programa usando precompilador DB2 (DSNHPC) y compilador COBOL.  
  - `bind.jcl`: Genera/actualiza el **PACKAGE** y el **PLAN** asociado al DBRM.  
  - `run.jcl`: Ejecuta el programa contra DB2, mostrando la salida por SYSOUT.  
- **Archivos de datos**:  
  - No utiliza archivos secuenciales, solo acceso a tablas DB2.  
- **Copybooks utilizados**:  
  - `SQLCA.cpy`: Manejo de códigos SQL (SQLCODE, SQLSTATE).  
  - `TBCURCTA.cpy`: Estructura DCLGEN de tabla de cuentas.  
  - `TBCURCLI.cpy`: Estructura DCLGEN de tabla de clientes.  

---

## ▶️ Descripción del JCL 

#### 🪛 compile.jcl 
Precompila el programa con DB2 (genera el DBRM), compila el COBOL y link-edita el load module en la librería de carga.  

#### 🔗 bind.jcl 
Toma el DBRM generado y lo asocia a un **PACKAGE** y **PLAN** en DB2 para permitir la ejecución en runtime.  

#### 🛠️ run.jcl 
Ejecuta el programa desde un JOB en batch, mostrando los resultados del `DISPLAY` en el SYSOUT.  

---

## 🏛️ Estructura del Programa 
- **1000-INICIO**:  
  - Inicializa variables, abre el cursor `ITEM_CURSOR`.  
  - Hace el primer `FETCH`.  
  - Si no hay registros, muestra mensaje de tabla vacía.  
  - Si hay registros, guarda la primera sucursal y comienza a contar.  

- **2000-PROCESO**:  
  - Itera con `FETCH`.  
  - Si fin de datos → dispara corte final.  
  - Si la sucursal es igual a la anterior → acumula cantidad.  
  - Si cambia de sucursal → ejecuta corte, resetea acumulador y continúa.  

- **2100-FETCH**:  
  - Realiza el `FETCH` del cursor hacia las estructuras DCLGEN.  
  - Evalúa `SQLCODE`:  
    - `0` → procesa registro.  
    - `+100` → fin de datos.  
    - Otro → error en FETCH.  

- **2200-CORTE**:  
  - Muestra subtotal de cuentas por sucursal.  
  - Acumula en total general.  
  - Resetea contador de cuentas.  

- **9999-FINAL**:  
  - Cierra el cursor.  
  - Muestra total general de cuentas procesadas.  

---

## ⚙️ Secuencia del Programa 
1. **Inicio**  
   - Setea fin de lectura a `N`.  
   - Abre cursor SQL.  
   - Lee primer registro.  
   - Prepara variables para el primer grupo de sucursal.  

2. **Proceso**  
   - Lee registros con `FETCH`.  
   - Agrupa por sucursal (`SUCUEN`).  
   - Ejecuta cortes de control y muestra subtotales.  

3. **Final**  
   - Ejecuta corte final.  
   - Cierra cursor.  
   - Muestra totales generales por consola.  

---

## 📊 Diagrama de Flujo 
<image src="./grafico.jpg" alt="Diagrama de Flujo del Programa">  

---

## 🎯 Resultado 

### 💬 Display (SYSOUT)  
```text
                                                                      
---------------------------------                                     
SUCURSAL: 01                                                          
CANTIDAD DE CUENTAS:  2                                               
                                                                      
---------------------------------                                     
SUCURSAL: 02                                                          
CANTIDAD DE CUENTAS:  1                                               
                                                                      
---------------------------------                                     
SUCURSAL: 03                                                          
CANTIDAD DE CUENTAS:  2                                               
                                                                      
---------------------------------                                     
SUCURSAL: 04                                                          
CANTIDAD DE CUENTAS:  2                                               
                                                                      
---------------------------------                                     
SUCURSAL: 05                                                          
CANTIDAD DE CUENTAS:  2                                               
                                                                      
---------------------------------                                     
SUCURSAL: 06                                                          
CANTIDAD DE CUENTAS:  1                                               
                                                                      
---------------------------------                                     
SUCURSAL: 07                                                          
CANTIDAD DE CUENTAS:  1                                               
                                                                      
=================================                                     
TOTAL CUENTAS:   11                                                   
```

