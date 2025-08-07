<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 Apareamiento - Consulta DB2 con Cursores 
- Entrada: SELECT DB2
- Salida: sysout display
## 📚 Descripción del Programa
Este programa COBOL batch realiza un **apareamiento entre clientes (TBCURCLI)** y **cuentas (TBCURCTA)** almacenadas en tablas DB2, utilizando cursores para recorrer ambas fuentes de datos ordenadas por número de cliente (`NROCLI`).
- Leer secuencialmente las tablas `TBCURCLI` y `TBCURCTA` mediante cursores.

#### Objetivos del Programa
- Realizar un **apareamiento** entre ambas fuentes por campo `NROCLI`.
- Informar los clientes que tienen cuentas asociadas.
- Detectar y reportar registros no apareados:
  - Cuentas sin cliente.
  - Clientes sin cuentas.
---

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│ ├── PGMB7CAF.cbl # Programa COBOL 
│ ├── COPY/
│ │ ├── `SQLCA`: Comunicación con DB2.
│ │ ├── `DCLTBCURCLI`, `DCLTBCURCTA`: Estructuras generadas con DCLGEN.
│
├── jcl/
│ ├── COMPILA.jcl   # JCL para precompilar
| ├── BIND.jcl      # Bind plan CURSOCAF, miembro PGMB7CAF
│ ├── EJECUTA.jcl   # JCL para ejecutar
│
├── README.md
```
</br>

### 📋 Archivos Involucrados

- **Programa**: `PGMB7CAF.cbl` Programa fuente.
- **JCL**: \
`COMPILA.jcl`:
  - Usa un procedimiento COMPDB2 para compilar programas con SQL embebido.
  - ALUMLIB apunta al lugar donde se genera el objeto compilado.
  - GOPGM debe coincidir con el nombre del programa (PGMB7CAF).

  `BIND.jcl`: 
  - Hace el bind del módulo (PGMB7CAF) al plan CURSOCAF.
  - Usa DSNTIAD bajo IKJEFT01 para enviar los comandos al entorno DB2.
  - Se asume que el DBRMLIB fue generado durante la compilación.

  `EJECUTA.jcl`: 
  - Ejecuta el programa bajo TSO mediante IKJEFT01.
  - Usa el plan CURSOCAF generado previamente.
  - La librería PGMLIB contiene el load module generado tras la compilación.

- **Copybooks utilizados**:
  - `SQLCA`: Comunicación con DB2.
  - `DCLTBCURCLI`, `DCLTBCURCTA`: Estructuras generadas con DCLGEN.
---

## 🏛️ Estructura del Programa 
- **1000-INICIO**: 
  - Abre los dos cursores SQL (`TBCURCLI` y `TBCURCTA`).
  - Si no hubo errores, realiza la **primera lectura** de cada cursor.
  - Marca la lectura como activa (`WS-NO-FIN-LECTURA`).

- **2000-PROCESO**: \
Es el corazón del programa (apareamiento):
  - Si ambos cursores llegaron al final → termina lectura.
  - Si hay datos:
  - Si los `NROCLI` coinciden → cliente con cuenta → se procesa y se avanza en cuentas.
  - Si el cliente viene "después" → cuenta sin cliente.
  - Si el cliente viene "antes" → cliente sin cuenta.

- **2100-LEER-TBCURCLI** : \
Hace la lectura de un registro del cursor `TBCURCLI` (clientes). Según el código SQL:
  - Si se leyó correctamente → guarda datos en variables de trabajo.
  - Si es +100 → fin de cursor (marca fin de cliente).
  - Si hay error → muestra mensaje y corta lectura.

- **4000-LEER-TBCURCTA** : \
Igual que el párrafo anterior, pero para la tabla `TBCURCTA` (cuentas).
  - Guarda `NROCLI` y `SUCUEN`.
  - Si llega al final, lo marca.
  - Maneja errores si los hay.

- **5000-PROCESAR-MAESTRO** : \
Muestra por consola la información de un cliente que tiene cuenta asociada.
  - Muestra datos: `TIPDOC`, `NRODOC`, `NROCLI`, `NOMAPE`, `SUCUEN`.
  - Incrementa contador `WS-ENCONTRADOS-CANT`.

- **9999-FINAL – Cierre**
  - Cierra ambos cursores.
  - Muestra resumen de ejecución con los contadores acumulados.

---


## 🎯 Resultado

### 💬 Display 
```TEXT
>>> CUENTA SIN CLIENTE EN TBCURCLI             
--------------------------------------         
CLIENTES ENCONTRADOS EN TABLA CLIENTES         
TIPDOC: DU                                     
NRODOC: 00000000111                            
NROCLI: 010                                    
NOMAPE: AMASO FLORES JUANA INES                
SUCUEN: 01                                     
-------------------                            
>>> CUENTA SIN CLIENTE EN TBCURCLI             
--------------------------------------         
CLIENTES ENCONTRADOS EN TABLA CLIENTES         
TIPDOC: DU                                     
NRODOC: 00000000135                            
NROCLI: 011                                    
NOMAPE: COMOMIRO ESTEBAN JOSE                  
SUCUEN: 01                                     
-------------------                            
>>> CUENTA SIN CLIENTE EN TBCURCLI             
>>> CUENTA SIN CLIENTE EN TBCURCLI             
--------------------------------------    

...

-------------------                                   
>>> CUENTA SIN CLIENTE EN TBCURCLI                    
--------------------------------------                
CLIENTES ENCONTRADOS EN TABLA CLIENTES                
TIPDOC: PE                                            
NRODOC: 00000000999                                   
NROCLI: 023                                           
NOMAPE: PEREYRA LUCENA MARTIN                         
SUCUEN: 07                                            
-------------------                                   
>>> CUENTA SIN CLIENTE EN TBCURCLI                    
>>> CUENTA SIN NOVEDAD                                
>>> CUENTA SIN NOVEDAD                                
>>> CUENTA SIN NOVEDAD                                
==============================================        
ENCONTRADOS:      011                                 
LEIDOS TBCURCLI:  015                                 
LEIDOS TBCURCTA:  014                                 
NO ENCONTRADOS:   003                                 
```


<div style="text-align: right;">

[( 🏠 )](/)

</div>