<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 CICS - Alta de Clientes
- Tipo: Cobol CICS online (BMS + VSAM)
- Salida: VSAM
## 📚 Descripción del Programa
`PGMALCAF` es un programa COBOL bajo CICS que permite dar de alta clientes desde un mapa BMS (MAP3CAF).
Al presionar ENTER, valida los datos ingresados y realiza un WRITE sobre un `VSAM KSDS` maestro de personas (PERSOCAF).
El registro maestro incluye clave primaria compuesta por Tipo de Documento (2) + Número de Documento (11) ⇒ 13 bytes.

#### Objetivos del Programa
- Mostrar una pantalla de entrada con los campos del cliente.
- Validar: tipo y número de documento, nombre/apellido, fecha de nacimiento y sexo.
- Persistir el alta en VSAM (WRITE FILE).
- Informar al usuario el resultado (éxito/errores) en el área de mensajes del mapa.

---

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│   ├── PGMALCAF.cbl          # Programa COBOL CICS
│   ├── COPY/
│   │   ├── MAP3CAF.cpy       # Copymap BMS (generado por ensamblado BMS)
│   │   ├── DFHBMSCA          # Constantes BMS
│   │   └── DFHAID            # Códigos de AID (ENTER/PF)
│
├── bms/
│   └── MAP3CAF.bms           # Definición BMS del mapa
│
├── vsam/
│   └── PERSOCAF.def          # Definición/IDCAMS del KSDS (opcional)
│
├── jcl/
│   ├── ASM_BMS.jcl           # Ensamblado BMS → copia MAP3CAF + load del MAPSET
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
  - Limpia mapa de salida, toma `DFHCOMMAREA` a `WS-COMMAREA`.
  - Si `EIBCALEN = 0 `→ primer ingreso: setea mensaje inicial, hora/fecha y SEND MAP.

- **2000-PROCESO**:
  - RECEIVE MAP → `WS-RESP`.
  - Copia a `WS-USER-DATA` (TIPDOCI + NUMDOCI) para usar como RIDFLD.
  - Deriva por tecla en 3000-TECLAS.

- **3000-TECLAS**:
  - **ENTER** → `3100-ENTER`.
  - **PF3** → `3200-PF3` (limpia pantalla y mensaje inicial).
  - **PF12** → `3300-PF12` (fin transacción).

- **3100-ENTER**:
  - Llama `3150-VALIDAR`. Si **CLIENTEOK**, va a `5000-WRITE`; si no, reenvía mapa con mensaje de error.

- **3150-VALIDAR**:
  - Setea `CLIENTEOK` y llama `3700-VERIF-FECHA`.
  - Evalúa reglas: tipo doc, nro doc, nombre, fecha, sexo.

- **3700-VERIF-FECHA**:
  - Arma validación básica de AAAA/MM/DD.

- **5000-WRITE**:
  - Mueve campos del mapa a `REG-PERSONA` y ejecuta `EXEC CICS WRITE FILE(PERSOCAF)` con `RIDFLD(WS-USER-DATA)` (13 bytes).
  - Manejo de RESP: DUPREC (ya existe), NORMAL (alta OK), OTHER (error archivo).
  - Reenvía mapa con MSGO correspondiente.

- **7000-TIME**:
  - `ASKTIME` + `FORMATTIME` → muestra fecha/hora en mapa.

- **9999-FINAL**:
  - `RETURN TRANSID('DCAF') COMMAREA(WS-COMMAREA)`.

---


## 🎯 Resultado

### 💻️ Display 
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
>>> CUENTA SIN NOVEDAD                  
>>> CUENTA SIN NOVEDAD                  
>>> CUENTA SIN NOVEDAD                  
>>> CUENTA SIN NOVEDAD                  
--------------------------------------  
CLIENTES ENCONTRADOS EN TABLA CLIENTES  
TIPDOC: PA                              
NRODOC: 00186569890                     
NROCLI: 455                             
NOMAPE: SAMUEL, WILSON                  
SUCUEN: 05                              
-------------------                     
>>> CUENTA SIN CLIENTE EN TBCURCLI      
--------------------------------------  
CLIENTES ENCONTRADOS EN TABLA CLIENTES               
TIPDOC: DU                                           
NRODOC: 00186567890                                  
NROCLI: 565                                          
NOMAPE: CAROLINA, DANVERS                            
SUCUEN: 02                                           
-------------------                                  
>>> CUENTA SIN CLIENTE EN TBCURCLI                   
==============================================       
ENCONTRADOS:      015                                
LEIDOS TBCURCLI:  018                                
LEIDOS TBCURCTA:  025                                
NO ENCONTRADOS:   010                                 
```


<div style="text-align: right;">

[( 🏠 )](/)

</div>