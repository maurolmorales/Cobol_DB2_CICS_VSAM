<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 CICS - Baja de Clientes
- Tipo: Cobol CICS online (BMS + VSAM)
- Salida: VSAM

## 📚 Descripción del Programa
`PROGM38S` es un programa COBOL bajo CICS que permite realizar la baja lógica/física de clientes en el archivo maestro PERSOCAF (VSAM KSDS).
La interacción se da mediante un mapa BMS (MAP4CAF) donde el usuario ingresa tipo y número de documento.

#### Objetivos del Programa
- Mostrar una pantalla inicial solicitando datos de documento.
- Validar los campos de entrada: tipo de documento y número de documento.
- Confirmar la existencia del cliente en PERSOCAF.
- Ejecutar la baja (DELETE) en caso de confirmación.
- Informar mensajes de éxito o error en el área de mensajes del mapa.
- Permitir limpieza de pantalla (PF3) y salida controlada a menú principal (PF12).

---

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│   ├── PROGM38S.cbl          # Programa COBOL CICS (baja de clientes)
│   ├── COPY/
│   │   ├── MAP4CAF.cpy       # Copymap BMS (generado por ensamblado BMS)
│   │   ├── DFHBMSCA          # Constantes BMS
│   │   ├── DFHAID            # Códigos de AID
│   │   └── CPPERSON.cpy      # Layout del registro maestro de personas
│
├── bms/
│   └── MAP4CAF.bms           # Definición BMS del mapa de baja
│
├── vsam/
│   └── PERSOCAF.def          # Definición/IDCAMS del KSDS (opcional)
│
├── jcl/
│   ├── ASM_BMS.jcl           # Ensamblado BMS → copia MAP4CAF + load del MAPSET
│   ├── LINK_PGM.jcl          # Linkedit del programa
│   ├── IDCAMS.jcl            # Define/Alter/Print del KSDS PERSOCAF
│   └── RDO.csd               # Definiciones CICS: PROGRAM/TRANSACTION/FILE/MAPSET
│
└── README.md

```
</br>

### 📋 Archivos Involucrados

- **Programa**: `PGMALCAF.cbl` Programa fuente.
- **JCL**: \
`COMPILA.jcl`:
  - Usa un procedimiento COMPDB2 para compilar programas con SQL embebido.
  - ALUMLIB apunta al lugar donde se genera el objeto compilado.
  - GOPGM debe coincidir con el nombre del programa (PGMALCAF).

  `BIND.jcl`: 
  - Hace el bind del módulo (PGMALCAF) al plan CURSOCAF.
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

## 🗂️ Archivo Maestro VSAM: PERSOCAF

- Tipo: KSDS
- Key: offset 1, length 13 (Tipo Doc 2 + Nro Doc 11)
- Largo registro: 160 bytes
- Layout (parcial)
  - PER-CLAVE:
    - PER-TIP-DOC    PIC X(02)
    - PER-NRO-DOC    PIC 9(11)

---

##  🖥️ Pantalla (BMS)

***Mapa***: MAP3CAF. Campos relevantes (sufijo I = input, O = output):
- Ingreso: TIPDOCI, NUMDOCI, NOMAPEI, ANIOI, MESI, DIAI, SEXOI.
- Salida: MSGO (mensajes), FECHAO (fecha formateada DD/MM/YYYY).

***Teclas soportadas***:
- ENTER → valida y, si todo OK, intenta WRITE.
- PF3 → limpia pantalla y muestra “INGRESE LOS DATOS Y PRESIONE ENTER”.
- PF12 → FIN TRANSACCION y RETURN a CICS.

---

## 🏛️ Estructura del Programa 

- **1000-INICIO**:
  - Limpia mapa y copia DFHCOMMAREA.
  - Si EIBCALEN = 0 → mensaje inicial “INGRESE LOS DATOS Y PRESIONE ENTER”.
- **2000-PROCESO**:
  - RECEIVE MAP → llena variables de entrada.
  - Maneja RESP: NORMAL, MAPFAIL, OTHER.
  - Llama a 3000-TECLAS.
- **3000-TECLAS**:
  - Evalúa EIBAID.
  - ENTER → 3100-ENTER (validación + lectura).
  - PF3 → 3200-PF3 (limpia).
  - PF4 → 3400-PF4 (ejecuta DELETE).
  - PF12 → 3300-PF12 (XCTL a PGMMECAF).
  - Caso contrario → mensaje de tecla inválida.
- **3100-ENTER**:
  - Llama a 3150-VALIDAR.
  - Si validación correcta → 5000-READ (lectura previa en VSAM).
- **3150-VALIDAR**:
  - Reglas:
    - Tipo de documento debe ser válido (DU, PA, PE).
    - Número debe ser numérico y distinto de cero.
- **5000-READ**:
  - READ en PERSOCAF con clave ingresada.
    RESP:
    - NOTFND → mensaje inexistente.
    - NORMAL → muestra “CLIENTE ENCONTRADO”.
    - OTHER → error genérico.
- **3400-PF4 (Baja)**:
  - Si cliente válido → ejecuta DELETE en PERSOCAF.
    RESP:
    - NORMAL → “CLIENTE BORRADO OK”.
    - NOTFND → “TIPO Y NÚMERO DOCUMENTO INEXISTENTES”.
    - OTHER → “PROBLEMA CON ARCHIVO PERSONA”.
    - Caso inválido → mensaje “DATOS INGRESADOS INCORRECTOS”.
- **7000-TIME**:
  - ASKTIME + FORMATTIME → fecha/hora al mapa.
- **8000-SEND-MAPA**:
  - Envío del mapa actualizado al usuario.
- **9999-FINAL**:
  - RETURN TRANSID('ECAF') COMMAREA(WS-COMMAREA).

---


## 🎯 Resultado
<image src="./Print_1.png" alt="Diagrama de Flujo del Programa 1"> </br>
<image src="./Print_2.png" alt="Diagrama de Flujo del Programa 2"> </br>
<image src="./Print_3.png" alt="Diagrama de Flujo del Programa 3"> </br>
<image src="./Print_4.png" alt="Diagrama de Flujo del Programa 4"> </br>
<image src="./Print_5.png" alt="Diagrama de Flujo del Programa 5"> </br>

### 💻️ Display 

```TEXT
--------------------------------------
       BAJA DE CLIENTES (ECAF)
--------------------------------------
TIPDOC: DU
NRODOC: 00000012345
--------------------------------------
CLIENTE ENCONTRADO
--------------------------------------
PF4 → Para ejecutar la baja
PF3 → Limpiar pantalla
PF12 → Volver al menú
--------------------------------------
CLIENTE BORRADO OK
                         
```


<div style="text-align: right;">

[( 🏠 )](/)

</div>