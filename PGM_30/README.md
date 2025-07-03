# 📄 Actualizador de Clientes

## 📌 Descripción

**PGMB4CAF** es un programa COBOL con SQL embebido que procesa un archivo de **Novedades Validadas de Clientes** (VSAM) para dar de alta registros en la tabla **`TBCURCLI`** en DB2.

Este programa:
- Lee novedades validadas.
- Verifica si ya existen registros con la misma clave primaria.
- Completa la fecha de nacimiento usando una **rutina externa** (`PGMRUCAF`) que calcula la fecha de proceso restándole un mes.
- Inserta los registros nuevos en la tabla DB2.
- Registra y muestra estadísticas de procesamiento.

---

## 📂 Estructura del proyecto

```
PGMB4CAF/
├── PGMB4CAF.cbl # Programa principal COBOL con SQL embebido
├── PGMRUCAF.cbl # Rutina de fecha (llamada dinámica)
├── TBVCLIEN.cpy # COPYBOOK del archivo de novedades
├── TBCURCLI.dclgen # COPYBOOK de la tabla DB2
├── JCL/
│ ├── COMPILA.jcl # JCL de compilación y link de la rutina
│ ├── BIND.jcl # JCL de definición del archivo VSAM de entrada
│ ├── EXECUTE.jcl # JCL de ejecución

```


---

## ⚙️ Archivos involucrados

| Archivo | Descripción |
|---------|--------------|
| **VSAM Input:** | `USUARIO.ARCHIVO.KSDS.VSAM` – Archivo de novedades validadas. |
| **Tabla DB2:** | `TBCURCLI` – Tabla destino para INSERT. |
| **Rutina:** | `PGMRUCAF` – Calcula fecha de proceso menos un mes. |
| **COPYBOOKS:** | `TBVCLIEN` y `TBCURCLI` – Layout de VSAM y tabla DB2. |

---

## 🔑 Clave primaria

- La clave primaria para evitar duplicados es: **TIPDOC + NRODOC**

---

## 🚦 Lógica del proceso

1. **Apertura** del archivo VSAM de novedades.
2. **Lectura secuencial** de cada registro.
3. **Verificación** en DB2 si ya existe (`SELECT`).
4. Si no existe:
   - **Llamada dinámica** a `PGMRUCAF` para ajustar la fecha.
   - **Formateo** de `YYYY-MM-DD`.
   - **INSERT** en la tabla DB2.
5. **Registro de errores**: claves duplicadas u otros SQLCODE.
6. **Muestra estadísticas**:
   - Registros leídos.
   - Registros insertados.
   - Registros erróneos.
7. **ROLLBACK** al final para test (opcional).
8. **Cierre** de archivos.

---

## 📊 Variables de control

- `WS-NOVE-LEIDAS-CANT` → Cantidad de registros leídos.
- `WS-NOVE-INSERT-CANT` → Cantidad de registros insertados.
- `WS-NOVE-ERRONEA-CANT` → Cantidad de registros erróneos.

---

## 🗄️ Requisitos de ejecución

- **Compilar** el programa con precompilador DB2.
- Asegurar que el archivo VSAM esté definido y cargado.
- Compilar la rutina `PGMRUCAF` y disponerla para llamada dinámica.
- Definir correctamente los DDNAME en el JCL:
  - `DDENTRA` para VSAM de entrada.
  - `DDSALID` para la tabla DB2.
  - `SYSIN` para comandos DB2 (`RUN`).

---

## ✅ Resultados esperados

Ejemplo de salida por `DISPLAY`:
