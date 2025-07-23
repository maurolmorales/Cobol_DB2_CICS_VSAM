# 📄 Sumatoria por Filtro de Campo
  - ENTRADA: Archivo QSAM. 
  - SALIDA: Sysout Display
## 📚 Descripción del Programa
`PGMPRUAR` es un programa COBOL que lee secuencialmente un archivo de clientes (`CLIENTES`), identifica los registros con tipo de documento **DU**, acumula sus saldos y muestra estadísticas básicas:  
- Total de registros leídos  
- Cantidad de clientes con tipo DU  
- Total de saldos de los clientes DU

---
### 🚀 Estructura del Proyecto
```
├── src/
│ ├── PGMPRUAR.cbl # Programa COBOL 
│ ├── COPY/
│   ├── CPCLI  # Copybook (embebido para tener de referencia)
│
├── jcl/
│ ├── COMPILA.jcl   # JCL para precompilar
│ ├── EJECUTA.jcl   # JCL para ejecutar
│
├── archivos/
│ ├── CLIENTES  # archivo QSAM de entrada de datos.
|
├── README.md
```
---

## 🏛️ Estructura del Programa 

  - **1000-INICIO**
    - Inicializa el indicador de fin de archivo (`WS-FIN-CLI`) como no alcanzado.
    - Abre el archivo `CLIENTES`.
    - Si el OPEN falla (`WS-FILE-CLI` ≠ `'00'`), muestra mensaje de error, setea retorno 9999 y marca fin del proceso.
  - **2000-PROCESO**
    - Llama al párrafo `2500-LEER` para leer un registro del archivo.
    - Si el campo `CLI-TIP-DOC` es igual a `'DU'`:
      - Suma el `CLI-SALDO` al acumulador `WS-TOTALIZADOR`.
      - Aumenta en 1 el contador WS-CANT-DU.
  - **2500-LEER**
    - Usa `READ ... INTO` para cargar un registro del archivo `CLIENTES` en la estructura `REG-CLIENTE`.
    - Evalúa el `WS-FILE-CLI`:
      - `'00'`: lectura exitosa, suma 1 al contador de registros leídos (`WS-CANT-LEIDOS`).
      - `'10'`: fin de archivo, activa `WS-FIN-CLI`.
      - Otros códigos: error de lectura, muestra mensaje, setea código de retorno 9999 y activa fin de archivo.
  - **9999-FINAL**   
    - Cierra el archivo `CLIENTES`.
    - Si el cierre falla (`WS-FILE-CLI` ≠ `'00'`), muestra mensaje de error y marca retorno 9999.
    - Muestra estadísticas finales:
      - Cantidad de registros leídos.
      - Cantidad de documentos tipo `'DU'`.
      - Total acumulado de saldos para `'DU'`.
---

## ⚙️ Secuencia del programa
1. Inicio del programa
    - Inicializa el indicador de fin de archivo (`WS-FIN-CLI` ← `'N'`).
2. Apertura del archivo
    - Abre el archivo CLIENTES.
    - Si hay error al abrir, muestra mensaje y termina el programa.
3. Bucle de procesamiento
    - Mientras no sea fin de archivo (WS-FIN-CLI = `'N'`):
      - Lee un registro del archivo en `REG-CLIENTE`.
      - Si la lectura fue exitosa (`WS-FILE-CLI = '00'`), suma 1 al contador `WS-CANT-LEIDOS`.
      - Si `CLI-TIP-DOC = 'DU'`:
        - Suma el `CLI-SALDO` al acumulador `WS-TOTALIZADOR`.
        - Incrementa el contador `WS-CANT-DU`.
      - Si llega fin de archivo (`WS-FILE-CLI = '10'`), se sale del bucle.
      - Si hay otro error de lectura, muestra mensaje y termina.
4. Cierre del archivo
    - Cierra el archivo `CLIENTES`.
    - Si hay error al cerrar, muestra mensaje.
5. Muestra resumen por pantalla
    - Total de registros leídos.
    - Cantidad de `'DU'` encontrados.
    - Total acumulado de saldos para `'DU'`.
6. Fin del programa
    - `GOBACK` al sistema o programa llamador.


---
## 🎯 Resultado

### 💬 Display 


