# Programa COBOL/DB2 de carga de datos desde archivo VSAM
<br/>

## ♛ Descripción general (PGMB2CAF)

Este programa COBOL con SQL embebido realiza la carga de registros a una tabla de DB2 a partir de un archivo secuencial VSAM.
Se encarga de leer datos del archivo NOVEDADES, formatear la información y realizar las inserciones correspondientes en la tabla KC02787.TBCURCLI. Además, controla errores durante la carga e informa totales de registros procesados.

<br/>

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
- Se ejecuta con un JCL que llama a IKJEFT01 con RUN PROGRAM(PGMB2CAF)
- El programa usa el plan CURSOCAF y carga registros desde KC03CAF.NOVECLI.KSDS.VSAM

<br/>

## 📂 Requisitos previos

- Archivo VSAM KC03CAF.NOVECLI.KSDS.VSAM con registros cargados y estructura correcta
- COPY TBVCLIEN alineado al layout real del archivo VSAM
- COPY TBCURCLI con definición compatible con la tabla DB2
- La tabla KC02787.TBCURCLI debe existir en la base de datos con sus constraints definidos
- Plan CURSOCAF correctamente bindeado

<br/>

## 📅 Ejemplo de salida esperada

```txt
-> TIPDOC: DU
-> NRODOC: 00302649362
-> NROCLI: 456
-> NOMAPE: ANTONIO, STARK
-> FECNAC: 1990-05-14
-> SEXO:   M
OK

TOTAL DE REGISTROS: 003
TOTAL DE GRABADOS: 003
TOTAL DE ERRORES: 000
```

<br/>

## 📄 Autor

Este programa fue desarrollado en el marco del curso de COBOL/DB2. Su estructura sirve también como modelo base para programas batch con acceso a DB2 mediante SQL embebido.
