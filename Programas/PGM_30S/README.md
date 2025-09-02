[( 🏠 )](/) </div>  

# 📄 Alta de Clientes con Fecha de Nacimiento Modificada  

- **Input:** Archivo de novedades (VSAM, secuencial por clave).  
- **Output:** Inserción de clientes en tabla DB2 `KC02787.TBCURCLI`.  
- **Output adicional:** Display por consola (SYSOUT) con detalle de registros y estadísticas.  

---

## 📚 Descripción del Programa  
Este programa COBOL **PGMB4CAF** procesa un archivo de novedades de clientes (VSAM).  
- Verifica si el cliente ya existe en DB2.  
- Si no existe, ajusta su fecha de nacimiento mediante un **CALL dinámico** al programa **PGMRUCAF**, que devuelve la fecha con un mes menos.  
- Inserta el registro en la tabla de clientes DB2.  
- Lleva contadores de registros leídos, insertados y erróneos.  

El proyecto incluye:  
- Programa COBOL con SQL embebido (**PGMB4CAF**).  
- Rutina llamada por CALL dinámico (**PGMRUCAF**).  
- Archivo VSAM de novedades.  
- JCLs de compilación, ejecución y BIND.  
- Copybooks de SQL (SQLCA y estructura de tabla).  

</br>  

---

### 🚀 Estructura del Proyecto  
```bash
   ├── src/
   │   ├── PGMB4CAF.cbl     # Programa principal COBOL con SQL embebido
   │   ├── PGMRUCAF.cbl     # Rutina dinámica que ajusta la fecha de nacimiento
   │   ├── COPY/
   │   │   ├── SQLCA.cpy    # Copybook estándar SQL
   │   │   ├── TBCURCLI.cpy # Copybook DCLGEN tabla clientes
   │   │   ├── TBVCLIEN.cpy # Copybook con estructura de archivo VSAM
   │
   ├── jcl/
   │   ├── compile.jcl      # Precompilación, compilación y link-edit
   │   ├── bind.jcl         # Bind del DBRM al PLAN
   │   ├── run.jcl          # Ejecución del programa
   │
   ├── README.md
```

### 📋 Archivos Involucrados 
- **Programa**: 
   - `PGMB4CAF.cbl`. Procesa archivo de novedades e inserta en DB2.
   - `PGMRUCAF.cbl`: Rutina llamada dinámicamente para ajustar fecha de nacimiento.
- **JCL**: 
  - COMPILA.jcl: Compila PGMB4CAF y PGMRUCAF con SQL embebido.
  - BIND.jcl: Genera el plan asociado a PGMB4CAF.
  - EJECUTA.jcl: Ejecuta el programa contra DB2 con archivo VSAM como entrada.
- **Archivos de datos**: 
  - KC03CAF.ARCHIVOS.NOVEDADES: Archivo VSAM Indexed de entrada, con datos de clientes.
- **Copybooks utilizados**: 
   - SQLCA.cpy: Manejo de SQLCODE.
   - TBCURCLI.cpy: DCLGEN de la tabla clientes.
   - TBVCLIEN.cpy: Layout del archivo VSAM de novedades.


---
## ▶️ Descipción del JCL 

#### 🪛 COMPILA.jcl 
Precompila, compila y link-edit del programa PGMB4CAF (con soporte DB2) y la rutina PGMRUCAF.

#### 🔗 BIND.jcl 
Genera el plan asociado al DBRM de PGMB4CAF.

#### 🛠️ EJECUTA.jcl 
Ejecuta PGMB4CAF contra DB2.
   - DDENTRA: apunta al archivo VSAM de novedades.
   - Muestra mensajes de debug por SYSOUT.

---

## 🏛️ Estructura del Programa 
- **1000-INICIO**:
   - Abre archivo de novedades.
   - Inicializa banderas y validaciones.

- **2000-PROCESO:**
   - Lee un registro de novedades.
   - Si no existe en DB2, ajusta fecha de nacimiento vía CALL PGMRUCAF.
   - Inserta en tabla TBCURCLI.
   - Actualiza contadores y muestra mensajes.

- **2100-LEER:**
   - Lectura del archivo VSAM.
   - Control de fin de archivo y errores.

- **2200-DESCOM-FECHA:**
   - Descompone fecha en campos de siglo, año, mes y día.

- **2210-COMPONER-FECHA:**
   - Reconstruye la fecha modificada (con mes ajustado).

- **9999-FINAL:**
   - Cierra archivos.
   - Muestra estadísticas.
   - Ejecuta ROLLBACK en caso de error.

- **Rutina PGMRUCAF:**
   - 1000-INICIO: Valida fecha recibida.
   - 1100-VALIDAR-AREA: Controla rangos de mes/año.
   - 2000-PROCESO: Resta un mes a la fecha (o ajusta año si es enero).
   - 9999-FINAL: Devuelve fecha ajustada y muestra mensajes.

---

## ⚙️ Secuencia del Programa 
1. **Inicio** 
   - Abrir archivo VSAM de novedades.
   - Validar apertura.
2. **Proceso** 
   - Leer registro de novedades.
   - Armar nombre completo.
   - Verificar existencia en DB2.
   - Si no existe:
      - Llamar a rutina PGMRUCAF para ajustar fecha.
      - Insertar en DB2.
   - Actualizar contadores.
3. **Final** 
   - Mostrar totales (leídos, insertados, erróneos).
   - Cerrar archivos.
   - ROLLBACK si corresponde.

---

## 📊 Diagrama de Flujo <image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa"> 

---

## 🎯 Resultado 

### 💬 Display
```TEXT
-> TIPDOC: DU                                                            
-> NRODOC: 00986557480                                                   
-> NROCLI: 501                                                           
-> NOMAPE: GUILLERMO, PUENTES                                            
-> FECNAC: 1978-12-05                                                    
-> SEXO:   M                                                             
                                                                         
FECHA PRE CALL:  1978-12-05                                              
FECHA POST CALL: 1978-11-05                                              
REGISTRO INGRESADO OK                                                    
---------------------------------                                        
-> TIPDOC: PA                                                            
-> NRODOC: 00984556390                                                   
-> NROCLI: 503                                                           
-> NOMAPE: TOMAS, CRUCERO                                                
-> FECNAC: 1983-07-12                                                    
-> SEXO:   M                                                             
                                                                         
FECHA PRE CALL:  1983-07-12                                              
FECHA POST CALL: 1983-06-12                                              
REGISTRO INGRESADO OK                                                    
---------------------------------                                        
-> TIPDOC: PE                                                            
-> NRODOC: 00982356440                                                   
-> NROCLI: 502                                                           
-> NOMAPE: ESTEBAN, TRABAJOS                                             
-> FECNAC: 1995-02-11                                                    
-> SEXO:   M                                                             
                                                                         
FECHA PRE CALL:  1995-02-11                                              
FECHA POST CALL: 1995-01-11                                              
REGISTRO INGRESADO OK                                                    
---------------------------------                                        
TOTAL DE REGISTROS: 003                                                  
TOTAL DE GRABADOS: 003                                                   
TOTAL DE ERRORES: 000 
```