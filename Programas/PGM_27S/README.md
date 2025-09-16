<div style="text-align: right;">

[( 🏠 )](/)

</div>

# Carga de Novedades a DB desde Archivo VSAM
  - Entrada: VSAM
  - Salida: Insert DB2

## 📚 Descripción del programa
Este programa COBOL (`PROGM27S`) con SQL embebido realiza la carga de registros a una tabla de DB2 a partir de un archivo secuencial VSAM.
Se encarga de leer datos del archivo `NOVEDADES`, formatear la información y realizar las inserciones correspondientes en la tabla `TBCURCLI`. Además, controla errores durante la carga e informa totales de registros procesados.

---
## 🚀 Estructura del proyecto
```
├── programa/
│ └── PROGM27S.cbl 
│
├── jcl/
│ ├── COMPILA.jcl # JCL para compilar
│ └── BIND.jcl # JCL de definición del archivo VSAM de entrada
│ └── EJECUTA.jcl # JCL para ejecución
│
├── data/
│ ├── NOVEDADES: NOVECLI.KSDS.VSAM # archivo de tres registros
│
├── README.md
```

## ✨ Funciones principales
- Apertura del archivo VSAM (KSDS) DDENTRA
- Lectura secuencial de registros (READ ... INTO)
- Extracción de campos del cliente: tipo y número de documento, nombre, apellido, sexo, fecha de nacimiento, etc.
- Concatenación de nombre y apellido con separador ", " para el campo NOMAPE
- Inserción de datos en tabla DB2 con EXEC SQL INSERT INTO
- Control de errores (SQLCODE) y contadores de estado (WS-GRABADOS, WS-ERRORES)
- Rollback si ocurre algún error
- Mensajes informativos a través de DISPLAY

<br/>

## ⚙ Componentes del ciclo de vida del programa
### COMPILACIÓN

- Se utiliza el JCL con EXEC COMPDB2
- El procedimiento COMPDB2 compila el programa COBOL con SQL embebido
- Se genera el programa objeto y el DBRM
### BIND
- El programa es bindeado mediante un JCL que ejecuta IKJEFT01 y comandos DB2 (BIND PLAN...)
- El DBRM es asociado al PLAN de ejecución (CURSOCAF)
### EJECUCIÓN
- Se ejecuta con un JCL que llama a IKJEFT01 con RUN PROGRAM(PROGM27S)
- El programa usa el plan CURSOCAF y carga registros desde KC03CAF.NOVECLI.KSDS.VSAM


---

## 🏛️ Estructura del Programa
División de procedimientos:

- **1000-INICIO**: Abre el archivo NOVEDADES.
  - Inicializa el indicador de fin de lectura como falso (WS-NO-FIN-LECTURA).
  - En caso de error al abrir el archivo, muestra mensaje de error, fija código de retorno 9999, y realiza cierre mediante 9999-FINAL.

- **2000-PROCESO**: Llama al párrafo 2100-LEER para leer un registro del archivo.
  - Si la lectura es exitosa:
    - Arma el nombre y apellido combinados.
    - Transfiere campos del registro leídos a variables individuales.
    - Muestra los datos por DISPLAY.
    - Inserta los datos en la tabla `TBCURCLI` vía SQL INSERT.
    - Controla el resultado de la operación SQL:
      - Si no encontró, lo informa.
      - Si fue exitoso, suma a grabados.
      - Si hubo error, lo muestra y lo cuenta como error.

- **2100-LEER**: Realiza la lectura del archivo `NOVEDADES` al área `WK-TBCLIE`.
  - Evalúa el código de estado `FS-NOVEDADES`:
    - `'00'`: lectura correcta, incrementa contador de registros.
    - `'10'`: fin del archivo, marca fin de lectura.
    - `OTHER`: error de lectura, lo muestra y finaliza lectura.

- **9999-FINAL**: 
  - Muestra estadísticas del procesamiento: total leídos, grabados, errores.
  - Cierra el archivo NOVEDADES.
  - Si falla el cierre, muestra error y ajusta código de retorno.

---

## 📊 Diagrama de Flujo
<image src="./GRAFICO.png" alt="Diagrama de Flujo del Programa">


---

## 🎯 Formato del archivo de salida y Display
El archivo de salida `LISTADO` contiene líneas formateadas con información agrupada. Ejemplo de líneas que se generan:

#### 💬 DISPLAY
```txt
-> TIPDOC: DU                                         
-> NRODOC: 00186567890                                
-> NROCLI: 565                                        
-> NOMAPE: CAROLINA, DANVERS                          
-> FECNAC: 1975-12-05                                 
-> SEXO:   F                                          
REGISTRO GRABADO: 01                                  
                                                      
-> TIPDOC: LE                                         
-> NRODOC: 00174567892                                
-> NROCLI: 026                                        
-> NOMAPE: ESTEBAN, ROGERS                            
-> FECNAC: 1990-05-14                                 
-> SEXO:   M                                          
REGISTRO GRABADO: 02                                  
                                                      
-> TIPDOC: PA                                         
-> NRODOC: 00186569890                                
-> NROCLI: 455                                        
-> NOMAPE: SAMUEL, WILSON                             
-> FECNAC: 1985-08-20                                 
-> SEXO:   M                                          
REGISTRO GRABADO: 03                                  
TOTAL DE REGISTROS: 003                               
TOTAL DE GRABADOS: 03                                 
TOTAL DE ERRORES: 00                                  
```
#### 🗄️ Respuesta DB2
```TEXT
---------+---------+---------+---------+---------+---------
TIPDOC         NRODOC  NROCLI  NOMAPE                                           
---------+---------+---------+---------+---------+---------
DU              1111.      1.  PEREZ, JUAN                                       
...      
LE         174567892.     26.  ESTEBAN, ROGERS                                  
PA         186569890.    455.  SAMUEL, WILSON                                   
DU         186567890.    565.  CAROLINA, DANVERS                                
DSNE610I NUMBER OF ROWS DISPLAYED IS 18                                         
DSNE616I STATEMENT EXECUTION WAS SUCCESSFUL, SQLCODE IS 100                     
---------+---------+---------+---------+---------+---------
---------+---------+---------+---------+---------+---------
DSNE617I COMMIT PERFORMED, SQLCODE IS 0                                         
DSNE616I STATEMENT EXECUTION WAS SUCCESSFUL, SQLCODE IS 0                       
---------+---------+---------+---------+---------+---------
DSNE601I SQL STATEMENTS ASSUMED TO BE BETWEEN COLUMNS 1 AND 72                  
DSNE620I NUMBER OF SQL STATEMENTS PROCESSED IS 1                                
DSNE621I NUMBER OF INPUT RECORDS READ IS 62                                     
DSNE622I NUMBER OF OUTPUT RECORDS WRITTEN IS 95                                 
```
<br/>


<div style="text-align: right;">

[( 🏠 )](/)

</div>