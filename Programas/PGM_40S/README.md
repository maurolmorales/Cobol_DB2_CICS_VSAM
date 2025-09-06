<div style="text-align: right;">

[( 🏠 )](/)

</div>

# 📄 Listado de Cuentas con Clientes (LEFT JOIN DB2)  

- **Input:** Tablas DB2 `KC02803.TBCURCTA` y `KC02803.TBCURCLI`.  
- **Output:** Archivo secuencial de salida `LISTADO` con formato de informe.  
- **Output adicional:** Mensajes y estadísticas por consola (SYSOUT).  

---

## 📚 Descripción del Programa  
Este programa COBOL **PGMB8CAF** accede a las tablas **TBCURCTA** (mandatoria) y **TBCURCLI**, realizando un **LEFT OUTER JOIN por NROCLI**.  
- Selecciona y lista datos de clientes y cuentas mediante cursor SQL.  
- Muestra en archivo de salida los campos: **TIPDOC, NRODOC, NROCLI, NOMAPE y SUCUEN**.  
- Informa cuando existen cuentas sin cliente asociado (campo NOMAPE nulo).  
- Genera estadísticas de registros:  
  - Total leídos.  
  - Total encontrados.  
  - Total no encontrados.  

El proyecto incluye:  
- Programa COBOL con SQL embebido (**PGMB8CAF**).  
- Archivo secuencial de salida (`LISTADO`).  
- JCLs de compilación, ejecución y BIND.  
- Copybooks de SQL (SQLCA y DCLGEN de tablas).  

</br>  

---

### 🚀 Estructura del Proyecto  
```bash
├── src/
│   ├── PGMB8CAF.cbl     # Programa COBOL con SQL embebido y LEFT JOIN
│   ├── COPY/
│   │   ├── SQLCA.cpy    # Copybook estándar SQL
│   │   ├── TBCURCLI.cpy # Copybook DCLGEN tabla clientes
│   │   ├── TBCURCTA.cpy # Copybook DCLGEN tabla cuentas
│
├── jcl/
│   ├── compile.jcl      # Precompilación, compilación y link-edit
│   ├── bind.jcl         # Bind del DBRM al PLAN
│   ├── run.jcl          # Ejecución del programa
│
├── README.md
```

---

### 📋 Archivos Involucrados 
- **Programa**: `PGMB8CAF.cbl`: Realiza LEFT JOIN de clientes y cuentas, genera listado y estadísticas.
- **JCL**: 
  - COMPILA.jcl: Compila el programa con SQL embebido.
  - BIND.jcl: Genera el plan asociado al DBRM de PGMB8CAF.
  - EJECUTA.jcl: Ejecuta el programa contra DB2 y genera el archivo LISTADO.
- **Archivos de datos**: 
  - LISTADO: Archivo secuencial de salida con registros formateados.
- **Copybooks utilizados**: 
  - SQLCA.cpy: Manejo de SQLCODE.
  - TBCURCLI.cpy: DCLGEN de la tabla clientes.
  - TBCURCTA.cpy: DCLGEN de la tabla cuentas.

---
## ▶️ Descipción del JCL 

#### 🪛 COMPILA.jcl 
  Precompila, compila y link-edit del programa PGMB8CAF.

#### 🔗 BIND.jcl 
  Genera el plan asociado al DBRM del programa PGMB8CAF.

#### 🛠️ EJECUTA.jcl 
  Ejecuta PGMB8CAF contra DB2.
  - DDLISTA: define el archivo de salida LISTADO.
  - Muestra mensajes y estadísticas por SYSOUT.

---

## 🏛️ Estructura del Programa 
- **1000-INICIO**:  
  - Inicializa variables.
  - Abre el archivo de salida LISTADO.
  - Abre el cursor SQL ITEM_CURSOR.
  - Escribe título, separadores y encabezados en el archivo.
  - Realiza primer FETCH.

- **2000-PROCESO**
  - Controla fin de datos (+100).
  - Procesa registros encontrados (cliente + cuenta).
  - Procesa registros no encontrados (cuenta sin cliente).
  - Incrementa contadores.
  - Repite FETCH.

- **4000-LEER-FETCH**
  - Realiza FETCH del cursor en DCLTBCURCLI y DCLTBCURCTA.
  - Maneja casos: éxito (0), fin de datos (+100), cliente no encontrado (-305), otros errores.

- **5000-PROCESAR-MAESTRO**
  - Copia datos de cliente/cuenta al layout del archivo de salida.
  - Graba línea en LISTADO.

- **9999-FINAL**
  - Cierra cursor y archivo.
  - Muestra estadísticas:
    - Leídos.
    - Encontrados.
    - No encontrados.

---

## ⚙️ Secuencia del Programa 
1. **Inicio** 
  - Abrir archivo LISTADO.
  - Abrir cursor SQL.
  - Escribir título y encabezados.
  - Primer FETCH.
2. **Proceso** 
  - Por cada fila del JOIN:
    - Si cliente existe: grabar en archivo.
    - Si cliente no existe: mensaje "CUENTA SIN CLIENTE EN TBCURCLI".
    - Actualizar contadores.
3. **Final** 
  - Cerrar cursor y archivo.
  - Mostrar estadísticas en SYSOUT.

---

## 📊 Diagrama de Flujo <image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa"> 

---


## 🎯 Formato del archivo de salida y Display
El archivo de salida `LISTADO` contiene líneas formateadas con información agrupada. Ejemplo de líneas que se generan:

#### 💬 DISPLAY

```text
CUENTA SIN CLIENTE EN TBCURCLI                          
CUENTA SIN CLIENTE EN TBCURCLI                          
CUENTA SIN CLIENTE EN TBCURCLI                          
*******************************          
LEIDOS:           014                                   
ENCONTRADOS:      011                                   
NO ENCONTRADOS:   003                                   
```
</br>

#### 💾 Archivo QSAM LISTADO
```text
           CLIENTES ENCONTRADOS EN TABLA CLIENTES                             
-------------------------------------------------------------------           
| TIPDOC |    NRODOC    |  NROCLI |             NOMAPE             |          
-------------------------------------------------------------------           
|     DU |          111 |      10 | AMASO FLORES JUANA INES        |          
|     DU |          135 |      11 | COMOMIRO ESTEBAN JOSE          |          
|     DU |          555 |      13 | PERENCIO CARMEN                |          
|     DU |          666 |      15 | PAZ JUAN PEDRO                 |          
|     PA |          234 |      16 | PERA FEDERICO                  |          
|     PA |          333 |      17 | PACIENCIA NOEMI                |          
|     PA |          456 |      18 | PRIETO JOSE                    |          
|     PE |          234 |      20 | PEREZ MARCELA                  |          
|     PE |          456 |      21 | PRUDENCIO MARIA JOSE           |          
|     PE |          789 |      22 | EQUINOCCIO JACINTO             |          
|     PE |          999 |      23 | PEREYRA LUCENA MARTIN          |          
```

<div style="text-align: right;">

[( 🏠 )](/)

</div>