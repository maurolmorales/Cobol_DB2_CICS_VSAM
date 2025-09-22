<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 CICS - Modificación de Clientes
- Tipo: Cobol CICS online (BMS + VSAM)
- Salida: VSAM
## 📚 Descripción del Programa
`PROGM39S` es un programa COBOL bajo CICS que permite modificar los datos de un cliente existente en el archivo maestro PERSOCAF (VSAM KSDS).
La interacción se da mediante un mapa BMS (MAP5CAF) donde el usuario ingresa tipo/número de documento junto con datos personales a actualizar.

#### Objetivos del Programa
- Mostrar pantalla inicial solicitando clave y datos modificables.
- Validar los campos de entrada: documento, nombre/apellido, fecha, sexo.
- Confirmar existencia del cliente en PERSOCAF.
- Ejecutar la modificación (REWRITE) si las validaciones son correctas.
- Informar mensajes de éxito o error en el área de mensajes.
- Permitir limpieza de pantalla (PF3) y salida controlada a menú (PF12).
---

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│   ├── PROGM39S.cbl          # Programa COBOL CICS (modificación de clientes)
│   ├── COPY/
│   │   ├── MAP5CAF.cpy       # Copymap BMS (generado por ensamblado BMS)
│   │   ├── DFHBMSCA          # Constantes BMS
│   │   ├── DFHAID            # Códigos de AID
│   │   └── CPPERSON.cpy      # Layout del registro maestro de personas
│
├── bms/
│   └── MAP5CAF.bms           # Definición BMS del mapa de modificación
│
├── vsam/
│   └── PERSOCAF.def          # Definición/IDCAMS del KSDS (opcional)
│
├── jcl/
│   ├── ASM_BMS.jcl           # Ensamblado BMS → copymap + load del MAPSET
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
  - Limpia mapa y copia DFHCOMMAREA.  - Si EIBCALEN = 0 → mensaje inicial “INGRESE LOS DATOS Y PRESIONE ENTER”.

- **2000-PROCESO**:
  - RECEIVE MAP → llena variables de entrada.
  - Maneja RESP: NORMAL, MAPFAIL, OTHER.
  - Llama a 3000-TECLAS.
- **3000-TECLAS**:
  - Evalúa EIBAID:
    - ENTER → 3100-ENTER (validar y leer registro).
    - PF3 → 3200-PF3 (limpiar).
    - PF4 → 3400-PF4 (XCTL menú).
    - PF12 → 3300-PF12 (XCTL menú).
    - Caso contrario → mensaje inválido.
- **3100-ENTER**:
  - Llama a 3150-VALIDAR.
  - Si datos correctos (CLIENTEOK) → 5000-READ.
- **3150-VALIDAR**:
  - Reglas:
    - Tipo de documento válido (DU, PA, PE).
    - Número documento numérico y distinto de cero.
    - Nombre y apellido obligatorios.
    - Fecha válida (3700-VERIF-FECHA).
    - Sexo válido (F, M o O).
- **3700-VERIF-FECHA**:
  - Chequea que fecha sea numérica y dentro de rangos válidos.
  - Controla meses de 30/31 días y febrero (máx. 28).
  - Rango de años: 1950–2020.
- **5000-READ**:
  - READ UPDATE en PERSOCAF con la clave ingresada.
    RESP:
    - NORMAL → llama a 5000-REWRITE.
    - NOTFND → mensaje “TIPO Y NÚMERO DOCUMENTO INEXISTENTES”.
    - OTHER → “PROBLEMA CON ARCHIVO PERSONA”.
- **5000-REWRITE**:
  - Reemplaza los datos del registro con los ingresados.
  - REWRITE en PERSOCAF.
    RESP:
    - NORMAL → “CLIENTE MODIFICADO CON ÉXITO”.
    - NOTFND → mensaje de inexistencia.
    - OTHER → error en archivo.
- **3200-PF3**:
  - Limpieza de mapa y mensaje inicial.
- **3400-PF4 / 3300-PF12**:
  - XCTL a PGMMECAF (menú principal).
- **7000-TIME**:
  - ASKTIME + FORMATTIME → fecha/hora al mapa.
- **8000-SEND-MAPA**:
  - Envía mapa actualizado al usuario.
- **9999-FINAL**:
  - RETURN TRANSID('FCAF') COMMAREA(WS-COMMAREA).
---


## 🎯 Resultado

### 💻️ Display 

```TEXT
--------------------------------------
     MODIFICACIÓN DE CLIENTES (FCAF)
--------------------------------------
TIPDOC: DU   NRODOC: 00000012345
NOMBRE/APELLIDO: JUAN PEREZ
FECHA NAC.: 12/05/1980
SEXO: M
--------------------------------------
CLIENTE MODIFICADO CON ÉXITO
--------------------------------------
PF3 → Limpiar pantalla
PF4 → Salir a Menú
PF12 → Volver al Menú Principal
--------------------------------------
                               
```


<div style="text-align: right;">

[( 🏠 )](/)

</div>