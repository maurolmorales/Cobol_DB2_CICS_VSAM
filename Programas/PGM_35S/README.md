<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 CICS - Menú de Clientes
- Tipo: Cobol CICS online (BMS + VSAM)
- Salida: VSAM
## 📚 Descripción del Programa
`PROGM35S` es un programa COBOL bajo CICS que implementa un menú de opciones de clientes.
Desde un mapa BMS (MAP2CAF), el usuario puede seleccionar distintas funciones mediante teclas de función (PF1 a PF12).

#### Objetivos del Programa
- Presentar al usuario un menú inicial con mensaje guía.
- Detectar y procesar teclas de función (PFKEYS).
- Derivar a programas específicos de Alta, Baja, Modificación y Consulta de clientes.
- Mostrar mensajes de error o confirmación en el área de mensajes del mapa.
- Permitir la salida ordenada de la transacción (PF12).
---

</br>

### 🚀 Estructura del Proyecto

```
├── src/
│   ├── PROGM35S.cbl          # Programa COBOL CICS (menú principal)
│   ├── COPY/
│   │   ├── MAP2CAF.cpy       # Copymap BMS (generado por ensamblado BMS)
│   │   ├── DFHBMSCA          # Constantes BMS
│   │   └── DFHAID            # Códigos de AID (ENTER/PF)
│
├── bms/
│   └── MAP2CAF.bms           # Definición BMS del mapa
│
├── jcl/
│   ├── ASM_BMS.jcl           # Ensamblado BMS → copia MAP2CAF + load del MAPSET
│   ├── LINK_PGM.jcl          # Linkedit del programa
│   └── RDO.csd               # Definiciones CICS: PROGRAM/TRANSACTION/MAPSET
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

***Mapa***: MAP2CAF. Campos relevantes (sufijo I = input, O = output):
- TIPDOCI, NUMDOCI (entrada de documento, para pasar a otros programas).
- MSGO (mensajes al usuario).
- FECHAO (fecha formateada por el programa).

***Teclas soportadas***:
- PF1 → Alta de cliente (PGMALCAF).
- PF2 → Baja de cliente (PGMBACAF).
- PF3 → Modificación (PGMMOCAF) → se pasa COMMAREA con tipo y número de documento.
- PF4 → Consulta individual (PGMPRCAF).
- PF5 → Limpiar mapa (reinicia pantalla con mensaje inicial).
- PF6 → Consulta general (función placeholder).
- PF12 → Salir de la transacción (envía mensaje “FIN TRANSACCION BCAF” y ejecuta RETURN).
- Cualquier otra tecla → Mensaje de error (“TECLA INVALIDA”).

---

## 🏛️ Estructura del Programa 

- **1000-INICIO**:
  - Limpia mapa, inicializa variables y copia DFHCOMMAREA en WS-COMMAREA.
  - Si EIBCALEN = 0, es la primera entrada: muestra mensaje inicial “INGRESE LA OPCION DESEADA”.
  - Caso contrario, recibe el mapa con los datos ingresados.

- **2000-PROCESO**:
  - Evalúa WS-RESP del RECEIVE MAP.
  - Si NORMAL → llama a 2500-PULSAR-TECLA.
  - Si MAPFAIL → vuelve a mostrar menú inicial.
  - Otros casos → muestra mensaje de error genérico.
- **2500-PULSAR-TECLA**:
  - Evalúa EIBAID (tecla pulsada) y deriva al párrafo correspondiente (PF1–PF12).
- **3000–4700 (PF1 a PF6)**:
  - Derivación a otros programas mediante EXEC CICS XCTL PROGRAM(...).
  - PF5 reinicia la pantalla.
  - PF6 muestra mensaje fijo “FUNCIÓN DE CONSULTA GENERAL”.
- **5500-PF12**:
  - Envía “FIN TRANSACCION BCAF”.
  - Ejecuta RETURN a CICS.
- **7000-TIME**:
  - Usa ASKTIME y FORMATTIME para mostrar fecha y hora en el mapa.
- **8000-SEND-MAPA**:
  - Arma la salida y envía mapa al usuario.
- **9999-FINAL**:
  - Ejecuta RETURN TRANSID('BCAF') COMMAREA(WS-COMMAREA).

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