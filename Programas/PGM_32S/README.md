[( 🏠 )](/) </div> 


# 📄 Apareo de Novedades con Tablas DB2

* **Entrada**: `NOVCTA` QSAM novedades de cuentas (LRECL=23, RECFM=FB).
* **Tablas DB2**:
  * `KC02803.TBCURCTA` — tabla de cuentas (maestro).
  * `KC02803.TBCURCLI` — tabla de clientes (datos personales).
* **Salida**: mensajes vía `DISPLAY` (informes de apareo, totales de control, errores).

---

## 📚 Descripción del Programa

El programa COBOL `PROGM32S` realiza un **apareo** entre un archivo de novedades (`NOVCTA`) y las tablas `TBCURCTA` (cuentas) y `TBCURCLI` (clientes) de DB2.

### Funcionalidad principal:

* Leer secuencialmente el archivo `NOVCTA` (ordenado por `TIPCUEN`, `NROCUEN`).
* Recorrer con cursor `INNERJOIN` las cuentas en `TBCURCTA`, con `LEFT JOIN` hacia `TBCURCLI` para traer el nombre del cliente.
* **Apareo por clave**: `TIPCUEN` + `NROCUEN`.
* Resultados posibles:

  * ✅ **Apareo OK**: sumar el saldo de la novedad al saldo de la cuenta, mostrar datos completos por `DISPLAY`.
  * ⚠️ **Novedad sin tabla**: mostrar `NOVEDAD NO ENCONTRADA`.
  * ⚠️ **Cuenta sin novedad**: mostrar `CUENTA SIN NOVEDAD`.
  * ⚠️ **Cliente no encontrado**: si `NROCLI` de cuenta no existe en `TBCURCLI`, mostrar `cliente no encontrado`.

### Totales finales mostrados por `DISPLAY`:

* Registros leídos desde archivo (`LEÍDOS ARCHIVO`).
* Registros apareados (`ENCONTRADOS`).
* Registros no apareados (`NO ENCONTRADOS`).

---

### 🚀 Estructura del Proyecto

```
├── src/
│   ├── PROGM32S.cbl           # Programa COBOL batch con SQL embebido
│   ├── COPY/
│   │   ├── SQLCA.cpy          # Copybook SQLCA estándar
│   │   ├── DCLTBCURCTA.cpy    # Layout generado por DCLGEN para tabla cuentas
│   │   ├── DCLTBCURCLI.cpy    # Layout generado por DCLGEN para tabla clientes
│   │   └── NOVCTA.cpy         # Layout del archivo de novedades
│
├── jcl/
│   ├── COMPILA.jcl            # JCL para compilar y precompilar con DB2 (DSNHPC)
│   ├── BIND.jcl               # JCL para bindear el plan/package asociado
│   └── RUN.jcl                # JCL para ejecutar PROGM32S
│
├── data/
│   ├── NOVCTA.dat             # Archivo secuencial de entrada (23 bytes)
│   └── SYSOUT.log             # Captura de sysout de ejecución
│
├── README.md
```

---

### 📋 Archivos y recursos involucrados

* **Programa**: `PROGM32S.cbl` — Programa COBOL batch con SQL embebido.
* **Copybooks**:

  * `SQLCA.cpy` (manejo de `SQLCODE`).
  * `DCLTBCURCTA.cpy` y `DCLTBCURCLI.cpy` (declaraciones de tablas DB2 por DCLGEN).
  * `NOVCTA.cpy` (layout de archivo de novedades; en el código aparece inline pero se puede extraer).
* **JCL**:

  * **COMPILA.jcl**: compila el programa con precompilador DB2 (`DSNHPC`), apunta a copylib con copybooks.
  * **BIND.jcl**: realiza bind del DBRM generado al plan/package.
  * **RUN.jcl**: ejecuta `PROGM32S`, asignando `DDENTRA` al archivo `NOVCTA`.

---

## 🏛️ Estructura del Programa

* **MAIN-PROGRAM-I/F**: controla la ejecución general (`INICIO`, `PROCESO`, `FINAL`).
* **1000-INICIO**: inicializa variables, abre archivo y cursor SQL, prepara primera lectura (`READ NOVEDADES` + `FETCH`).
* **2000-PROCESO**: ciclo de apareo hasta fin de archivo y cursor.
* **3000-LEER-NOVED**: lectura secuencial del archivo `NOVCTA`.
* **4000-LEER-FETCH**: `FETCH` del cursor `INNERJOIN` hacia estructuras `DCLTBCURCTA` y `DCLTBCURCLI`.
* **5000-PROCESAR-MAESTRO**: lógica de apareo correcto (sumatoria de saldo, displays informativos, contadores).
* **9999-FINAL**: cierre de archivo y cursor, displays de totales.

---

## ▶️ Secuencia de Ejecución

1. **Inicio**

   * Abrir archivo `NOVCTA`.
   * Abrir cursor `INNERJOIN` contra `TBCURCTA` + `TBCURCLI`.
   * Leer primer registro de cada fuente.

2. **Proceso de apareo**

   * Mientras queden registros en ambas fuentes:

     * Comparar claves (`TIPCUEN`, `NROCUEN`).
     * Si son iguales → procesar apareo (`5000-PROCESAR-MAESTRO`).
     * Si archivo < tabla → `NOVEDAD NO ENCONTRADA`.
     * Si tabla < archivo → `CUENTA SIN NOVEDAD`.

3. **Finalización**

   * Mostrar estadísticas de control.
   * Cerrar archivo y cursor.
---

## 📊 Diagrama de Flujo <image src="./grafico.jpg" alt="Diagrama de Flujo del Programa"> 

---

## 🎯 Resultado esperado

### 💬 Display
```text
-------------------                                                             
APAREO OK:                                                                      
TIPO DE CUENTA: 01                                                              
NRO CUENTA:             123                                                     
NROCLI:              10                                                         
$:         $25,40 = 0013540 + -      $110,00                                    
NOMBRE CLIENTE:AMASO FLORES JUANA INES                                          
SALDO ACTUALIZADO CTA         $25,40                                            
-------------------                                                             
-------------------                                                             
NOVEDAD NO ENCONTRADA                                                           
-------------------                                                             
-------------------                                                             
CUENTA SIN NOVEDAD                                                              
-------------------                                                             
-------------------                                                             
CUENTA SIN NOVEDAD                                                              
-------------------                                                             
-------------------                                                             
CUENTA SIN NOVEDAD                                                              
-------------------                                                             
-------------------                                                             
CUENTA SIN NOVEDAD                                                              
-------------------                                                             
-------------------                                                             
CUENTA SIN NOVEDAD                                                              
-------------------                                                             
-------------------                                                             
CUENTA SIN NOVEDAD                                                              
-------------------                                                             
-------------------                                                             
NOVEDAD NO ENCONTRADA                                                           
-------------------                                                             
-------------------                                                             
NOVEDAD NO ENCONTRADA          
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
-------------------                                                        
CUENTA SIN NOVEDAD                                                         
-------------------                                                        
TOTAL DE LEÍDOS ARCHIVO: 017                                               
TOTAL DE ENCONTRADOS: 001                                                  
TOTAL DE NO ENCONTRADOS: 015                                                                                                
```
