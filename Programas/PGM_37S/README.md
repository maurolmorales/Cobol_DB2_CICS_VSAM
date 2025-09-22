<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 CICS - Consulta de Clientes
- Tipo: Cobol CICS online (BMS + VSAM)
- Salida: VSAM
## 📚 Descripción del Programa
`PROGM37S` es un programa COBOL bajo CICS que implementa la consulta individual de clientes.
A través de un mapa BMS (MAP1CAF), el usuario ingresa tipo y número de documento.
El programa valida los datos, accede al archivo maestro PERSOCAF (VSAM KSDS) y muestra en pantalla la información del cliente o un mensaje de error.

#### Objetivos del Programa
- Recibir tipo y número de documento desde pantalla.
- Validar formato y existencia del documento ingresado.
- Realizar búsqueda en el archivo maestro PERSOCAF.
- Mostrar datos del cliente en el mapa BMS en caso de éxito.
- Informar mensajes claros en caso de error (documento inválido, no encontrado, error de archivo, etc.).
- Permitir navegación con teclas de función: limpiar (PF3) y salir (PF12).

---

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│   ├── PROGM37S.cbl          # Programa COBOL CICS (consulta individual)
│   ├── COPY/
│   │   ├── MAP1CAF.cpy       # Copymap BMS
│   │   ├── DFHBMSCA          # Constantes BMS
│   │   ├── DFHAID            # Códigos de AID
│   │   └── CPPERSON.cpy      # Layout del registro maestro de personas
│
├── bms/
│   └── MAP1CAF.bms           # Definición BMS del mapa de consulta
│
├── jcl/
│   ├── ASM_BMS.jcl           # Ensamblado BMS → copia MAP1CAF + load del MAPSET
│   ├── LINK_PGM.jcl          # Linkedit del programa
│   └── RDO.csd               # Definiciones CICS: PROGRAM/TRANSACTION/MAPSET/FILE
│
└── README.md
```
</br>

### 📋 Archivos Involucrados

- **Programa**: `PROGM37S.cbl` Programa fuente.
- **JCL**: \
`COMPILA.jcl`:
  - Usa un procedimiento COMPDB2 para compilar programas con SQL embebido.
  - ALUMLIB apunta al lugar donde se genera el objeto compilado.
  - GOPGM debe coincidir con el nombre del programa (PROGM37S).

  `BIND.jcl`: 
  - Hace el bind del módulo (PROGM37S) al plan CURSOCAF.
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

***Mapa***: MAP1CAF. Campos relevantes (sufijo I = input, O = output):
- TIPDOCI → tipo de documento (DU, PA, PE).
- NUMDOCI → número de documento.
- TIPDOCO, NUMDOCO, NOMAPEO, DIAO, MESO, ANIOO, SEXOO.
- MSGO → área de mensajes (ej. “CLIENTE ENCONTRADO”, “DOCUMENTO INVÁLIDO”).
- FECHAO → fecha actual (formateada con ASKTIME + FORMATTIME).

***Teclas soportadas***:
- ENTER → Validación y búsqueda en VSAM.
- PF3 → Limpiar mapa y reiniciar mensaje.
- PF12 → Salida de la transacción → XCTL a PGMMECAF.
- Otra tecla → Mensaje de error (“TECLA INVALIDA”).
---

## 🏛️ Estructura del Programa 

- **1000-INICIO**:
  - Limpia mapa y copia DFHCOMMAREA en WS-COMMAREA.
  - Si es la primera entrada (EIBCALEN = 0), muestra mensaje inicial “INGRESE LOS DATOS Y PRESIONE ENTER”.

- **2000-PROCESO**:
  - Ejecuta RECEIVE MAP.
  - Evalúa respuesta (NORMAL, MAPFAIL u otro).
  - Si NORMAL → deriva a procesamiento de teclas (3000).

- **3000-TECLAS**:
  Evalúa EIBAID.
  - Si ENTER → va a validación y lectura.
  - Si PF3 → limpia mapa.
  - Si PF12 → sale a PGMMECAF.
  - Si otro → mensaje de tecla inválida.

- **3100-ENTER**:
  - Llama a validación (3150).
  - Si cliente válido → lectura en VSAM (5000-READ).
  - Caso contrario → muestra mensaje de error.
- **3150-VALIDAR**:
  - Valida tipo de documento contra tabla de valores (DU, PA, PE).
  - Verifica que número sea numérico y distinto de cero.
- **5000-READ**:
  - Hace EXEC CICS READ sobre PERSOCAF con clave ingresada.
  - Si NOTFND → mensaje de inexistente.
  - Si NORMAL → mueve datos de cliente al mapa (nombre, fecha de alta, sexo, etc.).
  - Si error → mensaje genérico “PROBLEMA CON ARCHIVO PERSONA”.
- **7000-TIME**:
  - Obtiene fecha y hora actual y las muestra en el mapa.
- **8000-SEND-MAPA**:
  - Envía mapa al usuario con los datos o mensajes correspondientes.
- **9999-FINAL**:
  - Ejecuta RETURN TRANSID('ACAF') COMMAREA(WS-COMMAREA).

---


## 🎯 Resultado

### 💻️ Display 
```TEXT
--------------------------------------
     CONSULTA DE CLIENTES (ACAF)
--------------------------------------
TIPDOC: DU
NRODOC: 00000012345
NOMBRE: JUAREZ PEREZ CAROLINA
FECHA ALTA: 15/08/2020
SEXO: F
--------------------------------------
CLIENTE ENCONTRADO
--------------------------------------

```


<div style="text-align: right;">

[( 🏠 )](/)

</div>