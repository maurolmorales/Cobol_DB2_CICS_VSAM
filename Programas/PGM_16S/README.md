<div style="text-align: right;">

[( 🏠 )](/)

</div>


# 📄 Programa COBOL con SQL Embebido - Corte de Control por Sucursal

Este repositorio contiene un ejemplo de programa COBOL Batch con SQL embebido (Embedded SQL) para IBM Mainframe.  
El programa se conecta a DB2, abre un cursor para recorrer registros de cuentas, realiza un **corte de control** por sucursal (`SUCUEN`), contabiliza la cantidad de cuentas por sucursal y muestra un total general.

---


## 🚀 ¿Qué hace este programa?

- Declara un cursor `ITEM_CURSOR` que consulta la tabla de cuentas **`TBCURCTA`** y une información de clientes **`TBCURCLI`** mediante un `INNER JOIN`.
- Recupera datos como:
  - Tipo de cuenta (`TIPCUEN`)
  - Número de cuenta (`NROCUEN`)
  - Sucursal (`SUCUEN`)
  - Número de cliente (`NROCLI`)
  - Nombre y apellido (`NOMAPE`)
  - Saldo (`SALDO`)
  - Fecha de saldo (`FECSAL`)
- Filtra cuentas con saldo positivo (`SALDO > 0`).
- Realiza un **corte de control**: agrupa por sucursal, cuenta cuántas cuentas tiene cada sucursal y muestra totales.
- Imprime totales por sucursal y total general. 

--- 
## 🚀 Estructura del proyecto
```
├── src/
│ ├── PGMBMLM.cbl # Programa COBOL con SQL embebido y JOIN
│ ├── COPY/
│ │ ├── SQLCA.cpy # Copybook estándar para manejo de SQLCODE
│ │ ├── TBCURCTA.cpy # Copybook DCLGEN tabla cuentas
│ │ ├── TBCURCLI.cpy # Copybook DCLGEN tabla clientes
│
├── jcl/
│ ├── compile.jcl # JCL para precompilar, compilar y link-edit
│ ├── bind.jcl # JCL para hacer el BIND del DBRM al PLAN
│ ├── run.jcl # JCL para ejecutar el load module
│
├── README.md
```
---

## ⚙️ ¿Cómo funciona?

1. **Precompilación y compilación**
   - Usa la `PROC` **`COMPCOTE`** para:
     - Precompilar (`DSNHPC`): traduce el SQL embebido en llamadas DB2.
     - Compilar (`IGYCRCTL`): traduce COBOL a módulo objeto.
     - Link-edit (`IEWL`): genera el *load module* en tu `PGMLIB`.

2. **BIND**
   - Crea o actualiza un **PLAN** (`CURSOCAF`) que asocia el *package* con el DB2 catalog.
   - Necesario cada vez que cambies el SQL.

3. **Ejecución**
   - Usa `IKJEFT01` para abrir una sesión `TSO` en batch.
   - Corre `DSN` para conectar al sistema DB2.
   - Ejecuta `RUN PROGRAM(PGMBMLM) PLAN(CURSOCAF)`.

---
## ✅ Salida por SYSOUT:


```COBOL
---------------------------------                           
SUCURSAL: 01                                                
CANTIDAD DE CUENTAS:  3                                     
                                                            
---------------------------------                           
SUCURSAL: 02                                                
CANTIDAD DE CUENTAS:  2                                     
                                                            
---------------------------------                           
SUCURSAL: 03                                                
CANTIDAD DE CUENTAS:  3                                     
                                                            
---------------------------------                           
SUCURSAL: 04                                                
CANTIDAD DE CUENTAS:  2                                     
                                                            
---------------------------------                           
SUCURSAL: 05                                                
CANTIDAD DE CUENTAS:  2                                     
                                                            
---------------------------------                           
SUCURSAL: 06                                                
CANTIDAD DE CUENTAS:  1                                     
                                                            
---------------------------------                           
SUCURSAL: 07                                                
CANTIDAD DE CUENTAS:  1                                     
                                                            
=================================                           
TOTAL CUENTAS:   14                                         

```
---
## 📌 Puntos importantes

- **ORDER BY SUCUEN** en el `CURSOR` garantiza que el corte de control por sucursal sea consistente.
- **FETCH** debe coincidir exactamente en cantidad y orden de columnas con el `SELECT`.
- Usa COPYBOOKs generados con `DCLGEN` (`TBCURCTA` y `TBCURCLI`) para mapear las columnas de DB2.
- Muestra códigos `SQLCODE` para debugging y manejo de errores.

---

## 📚 Notas

- **Corte de control**: Implementado manualmente en la sección `2000-PROCESO` y `2200-CORTE` del programa COBOL.
- **Debug**: Todos los códigos SQL (`SQLCODE`) se muestran con `DISPLAY` para facilitar la identificación de errores.
- **Retorno**: Usa `RETURN-CODE` para finalizar con código 0 o 9999 en caso de error.

---

## 🧩 Créditos

Ejemplo didáctico para prácticas COBOL DB2 en batch.  
Adaptable a tus datasets, tablas y configuración de `PLAN`.



**¡Mainframe is not dead! 🚂**



<div style="text-align: right;">

[( 🏠 )](/)

</div>