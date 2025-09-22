<div style="text-align: right;">

[( 🏠 )](/)

</div>

# 🧾 Consulta DB2 con Cursor e Impresión
- Salida: QSAM

## 📚 Descripción del programa

Este programa COBOL (`DPROGM28S`) realiza un procesamiento batch que:

- Abre un cursor SQL en DB2 (`CURSOR_CLI`) para obtener información de cuentas con saldo mayor a cero.
- Recupera datos desde las tablas `TBCURCTA` (cuentas) y `TBCURCLI` (clientes) con un `JOIN`.
- Imprime la información de los clientes en un archivo secuencial (`LISTADO`) con formato tabular.
- Inserta títulos, subtítulos y separadores en la salida.
- Pagina el informe, reiniciando encabezados cada cierto número de líneas.
---

## 🚀 Estructura del proyecto
```
├── programa/
│   └── DPROGM28S.cbl
│
├── jcl/
│   ├── COMPILA.jcl   # Compilación con procedimiento COMPDB2
│   ├── BIND.jcl      # Bind plan CURSOCAF, miembro DPROGM28S
│   └── EJECUTA.jcl   # Ejecución del programa
│
├── data/
│   └── LISTADO       # Salida con clientes y saldos
│
├── README.md
```

### 📋 Archivos involucrados

- **Programa**: `DPROGM28S.cbl` (fuente principal en COBOL con SQL embebido).
- **JCL**:
  - `COMPILA.jcl`: Compila el programa usando `COMPDB2`.
  - `BIND.jcl`: Genera el plan `CURSOCAF` asociado al programa.
  - `EJECUTA.jcl`: Ejecuta el programa contra DB2, generando la salida.
- **Archivos de datos**:
  - `KC03CAF.ARCHIVOS.LISTADO`: Archivo QSAM de salida con registros de clientes con saldo positivo.

- **Copybooks utilizados**:
  - `DCLTBCURCLI`: estructura de cliente (`NROCLI`, `NOMAPE`, etc.). 
  - `DCLTBCURCTA`: estructura de cuenta (`TIPCUEN`, `NROCUEN`, `SALDO`, etc.).


---

### ▶️ Descipción del JCL

#### 🪛 `COMPILA.jcl`

Compila el programa utilizando un procedure (COMPDB2) y define la librería de copys:

```jcl
//STEP1      EXEC COMPDB2,
//                ALUMLIB=USUARIO.CURSOS,
//                GOPGM=DPROGM28S
//PC.SYSLIB  DD   DSN=USUARIO.CURSOS.DCLGEN,DISP=SHR
//COB.SYSLIB DD   DSN=ORIGEN.ALU9999.COPYLIB,DISP=SHR
```

#### 🔗 `BIND.jcl`
Asocia el programa compilado a un `PLAN` en DB2:

```jcl
//DSN SYSTEM(DBDG)
//RUN PROGRAM(DSNTIAD) PLAN(DSNTIA13) -
//    LIB('DSND10.DBDG.RUNLIB.LOAD')
//BIND PLAN(CURSOCAF) MEMBER(DPROGM28S) +
//    CURRENTDATA(NO) ACT(REP) ISO(CS) ENCODING(EBCDIC)
//END
```

#### 🛠️ `EJECUTA.jcl`
Ejecuta el programa, grabando la salida en `USUARIO.ARCHIVOS.LISTADO`:

```jcl
//EJECMLM EXEC PGM=IKJEFT01,DYNAMNBR=20
//SYSTSIN DD *
  DSN SYSTEM(DBDG)
  RUN PROGRAM(DPROGM28S) PLAN(CURSOCAF) +
      LIB('KC03CAF.CURSOS.PGMLIB')
  END
//DDLISTA DD DSN=KC03CAF.ARCHIVOS.LISTADO, ...
```
---
## 🏛️ Estructura del Programa  
División de procedimientos:

- **1000-INICIO**:  
  Apertura del archivo de salida (`LISTADO`) y del cursor DB2 (`CURSOR_CLI`).  
  Inicializa variables, fecha y número de página.  
  Realiza la primera lectura (`FETCH`) desde el cursor.  
  Si hay registros, imprime títulos y subtítulos.

- **2000-PROCESO**:  
  Bucle principal.  
  Por cada registro retornado por el cursor:
  - Se formatea la línea de salida con los datos del cliente.
  - Se graba la línea en el archivo QSAM `LISTADO`.
  - Se controla el paginado para reimprimir encabezados.

- **4000-LEER-FETCH**:  
  Realiza el `FETCH` del cursor `CURSOR_CLI`.  
  Mapea los datos del cursor a variables locales.  
  Maneja errores SQL y marca fin de lectura (`+100`).

- **6000-GRABAR-SALIDA**:  
  Escribe un registro formateado en el archivo `LISTADO`.  
  Si se supera el límite de líneas por página, imprime títulos nuevamente.

- **6500-IMPRIMIR-TITULOS**:  
  Imprime el título principal con la fecha y el número de página.

- **6600-IMPRIMIR-SUBTITULOS**:  
  Imprime el encabezado de columnas para cada página del listado.

- **9999-FINAL**:  
  Cierra el cursor DB2 y el archivo de salida.  
  Muestra por pantalla (`DISPLAY`) la cantidad total de registros leídos e impresos.

---

## ⚙️ Secuencia del programa

1. **Inicio**
   - Se abre el archivo de salida `LISTADO`.
   - Se inicializa la fecha y el número de página.
   - Se abre el cursor `CURSOR_CLI`.
   - Se realiza el primer `FETCH`.

2. **Proceso**
   - Se realiza un bucle de lectura (`FETCH`) de registros desde el cursor.
   - Se imprime cada registro en el archivo `LISTADO`, formateado.
   - Se controla la cantidad de líneas impresas para reimprimir títulos y subtítulos.

3. **Final**
   - Se cierra el cursor SQL.
   - Se cierra el archivo `LISTADO`.
   - Se muestran por `DISPLAY` la cantidad de registros leídos e impresos.

---

## 📊 Diagrama de Flujo
<image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">

---
## 🎯 Resultado

#### 🖨️ Impresión Archivo QSAM Listado
```texto

        LISTADO DE CLIENTES CON SALDO MAYOR A CERO  7- 8-2025    NUMERO PAGINA: 1
-------------------------------------------------------------------------------------------------------------
 | TIPCUEN | NROCUEN | SUCUEN | NROCLI |              NOMAPE              |      SALDO       |    FECSAL    |
-------------------------------------------------------------------------------------------------------------
 |       1 |     123 |      1 |     10 |   AMASO FLORES JUANA INES        |    $      135,40 |   2025-06-01 |
 |       2 |     111 |      1 |     11 |   COMOMIRO ESTEBAN JOSE          |    $      115,00 |   2025-06-01 |
...
 |       1 |    3266 |      3 |     26 |   ESTEBAN, ROGERS                |    $      130,00 |   2025-08-07 |
 |       3 |     563 |      5 |    455 |   SAMUEL, WILSON                 |    $       60,00 |   2025-07-05 |
 |       2 |     777 |      2 |    565 |   CAROLINA, DANVERS              |    $      120,00 |   2025-05-02 |


```
</br>

#### 💬 DISPLAY 
```TEXT
CANTIDAD LEIDOS:        15   
CANTIDAD IMPRESOS:      15   
```

<div style="text-align: right;">

[( 🏠 )](/)

</div>

