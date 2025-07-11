# 📄 Sumatoria por filtro de campo

## Descripción

`PGMPRUAR` es un programa COBOL que lee secuencialmente un archivo de clientes (`CLIENTES`), identifica los registros con tipo de documento **DU**, acumula sus saldos y muestra estadísticas básicas:  
- Total de registros leídos  
- Cantidad de clientes con tipo DU  
- Total de saldos de los clientes DU

---

## Archivo de entrada

- Asignado con `SELECT CLIENTES ASSIGN DDENTRA`.
- Estructura principal:
  - `CLI-TIP-DOC`: Tipo de documento (DU, etc.)
  - `CLI-SALDO`: Saldo del cliente
  - Otros campos: número de documento, sucursal, cuenta, fecha, nombre.

---

## Principales pasos del programa

1. **Abrir archivo**: Control de error con `FILE STATUS`.
2. **Leer registros**: Sumar saldo si es tipo **DU**.
3. **Mostrar resultados**: Estadísticas en pantalla.
4. **Cerrar archivo**: Validar cierre correcto.

---

## Ejemplo de salida

```txt
CANTIDAD REGISTROS LEIDOS:    65         
CANTIDAD DE DU:               55         
TOTAL DE SALDOS =  $   97.442.823,60     
```


---

## Notas

- Usa `SPECIAL-NAMES DECIMAL-POINT IS COMMA`.
- Se recomienda definir el registro con `COPY CPCLI` para mayor consistencia.
- Asignar `DDENTRA` en el JCL o entorno.

---

**Versión:** 1.0  
**Autor:** Desarrollador COBOL  

