# 📄 Corte de Control e Impresión

## Descripción

**PGMIMCAF** es un programa COBOL desarrollado en la **Clase 11 Asíncrona** del curso de Desarrollo COBOL.  
Su objetivo es procesar un archivo de clientes en formato **QSAM**, realizar un **corte de control** por tipo de documento, generar listados agrupados e imprimir subtotales. La salida se genera en un archivo de tipo **FBA**, apto para impresión paginada.

---

## ⚙️ Características principales

- ✅ **Corte de control:** Agrupa registros por tipo de documento y genera subtotales.
- ✅ **Impresión paginada:** Genera encabezados de página con información de sucursal, fecha y número de página.
- ✅ **Archivos secuenciales:**  
  - Entrada: archivo QSAM.  
  - Salida: archivo FBA con formato de 132 caracteres por línea.
- ✅ **Variables de control:** Cuenta registros leídos, impresos y totales por grupo.

---

## 🗃️ Archivos procesados

| Archivo   | Descripción                   | Formato |
|-----------|-------------------------------|---------|
| ENTRADA   | Novedades de clientes         | QSAM (93 bytes por registro) |
| LISTADO   | Listado agrupado con totales  | FBA (132 bytes por línea)    |

---

## 📑 Layouts de registros

### ➤ Entrada: `REG-CLIENTES`

```cobol
01 REG-CLIENTES.
   03 CLIS-TIP-DOC     PIC X(02).
   03 CLIS-NRO-DOC     PIC 9(11).
   03 CLIS-SUC         PIC 9(02).
   03 CLIS-TIPO        PIC 9(02).
   03 CLIS-NRO         PIC 9(03).
   03 CLIS-IMPORTE     PIC S9(09)V99 COMP-3.
   03 CLIS-AAAAMMDD    PIC 9(08).
   03 CLIS-LOCALIDAD   PIC X(15).
   03 FILLER           PIC X(01).
```
---
## ➤ Salida: WS-REG-LISTADO
Cada línea incluye:

- Tipo y número de documento
- Sucursal
- Tipo y número de cliente
- Importe
- Fecha
- Localidad
---
## 🧩 Lógica de procesamiento
1. Inicialización
    - Obtiene fecha del sistema.
    - Abre archivos de entrada y salida.
    - Inicializa contadores y variables de corte.
2. Lectura secuencial
    - Lee registros de entrada uno por uno.
    - Imprime cada registro en el listado formateado.
    - Agrupa registros por tipo de documento.
3. Corte de control
    - Al detectar un cambio en el tipo de documento, imprime subtotal del grupo anterior.
    - Se muestra información del corte en consola.
4. Impresión paginada
    - Cada página admite hasta 60 líneas.
    - Si se alcanza el límite, imprime encabezado de nueva página con información de sucursal, fecha y número de página.
5. Finalización
    - Muestra totales de registros leídos e impresos.
    - Cierra archivos y valida estados.
---
## ✅ Variables de control destacadas
- WS-TIPO-DOC-ANT: Guarda el tipo de documento anterior para corte.
- WS-TIPO-DOC-CANT: Contador de registros por grupo.
- WS-LEIDOS-FILE1: Total de registros leídos.
- WS-IMPRESOS: Total de registros impresos.
- WS-CUENTA-LINEA y WS-CUENTA-PAGINA: Controlan la paginación.
---
## 🖨️ Formato de salida
- Formato: FBA (Fixed Blocked ASCII), 132 caracteres por línea.
- Contenido: Registros detallados con separación de campos.
- Encabezado de página: Incluye sucursal, fecha y número de página.
- Pie de corte: Muestra subtotal por grupo de tipo de documento.
---
## 🚩 Recomendaciones
- Revisar COPY CPCLIENS para validar la estructura de datos.
- Configurar correctamente los DD (DDENTRA y DDLISTA) en el JCL.
- Verificar la configuración de impresión para archivos FBA.
---
## 👨‍💻 Autor
Clase 11 Asíncrona - Desarrollo COBOL <br />
Programa: PGMIMCAF <br />
Funcionalidad: Corte de control e impresión paginada
