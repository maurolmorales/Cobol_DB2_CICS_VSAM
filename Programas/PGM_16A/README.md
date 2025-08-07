<div style="text-align: right;">

[( 🏠 )](/)

</div>

# 🧾 Consulta DB2 con Doble Corte de Control
  - Entrada: DB2
## 📚 Descripción del programa

Este programa COBOL (`PGMBMLM`) realiza un procesamiento batch que:
  - Utilizar SQL embebido en COBOL para acceder a datos de DB2.
  - Aplicar corte de control por campo `SUCUEN` (Sucursal-Cuenta).
  - Acumular cantidad de cuentas por sucursal y mostrar un total general al finalizar.


--- 

## 🚀 Estructura del proyecto
```
├── programa/
│   └── PGMBMLM.cbl
│
├── jcl/
│   ├── COMPILA.jcl   # Compilación con procedimiento COMPDB2
│   ├── BIND.jcl      # Bind plan CURSOCAF, miembro PGMBMLM
│   └── EJECUTA.jcl   # Ejecución del programa
│
├── README.md
```

### 📋 Archivos involucrados

- **Programa**: `PGMBMLM.cbl` (fuente principal en COBOL con SQL embebido).
- **JCL**:
  - `COMPILA.jcl`: Compila el programa usando `COMPDB2`.
  - `BIND.jcl`: Genera el plan `CURSOCAF` asociado al programa.
  - `EJECUTA.jcl`: Ejecuta el programa contra DB2, generando la salida.

- **Copybooks utilizados**:
  - `DCLTBCURCLI`: estructura de cliente. (`NOMAPE`). 
  - `DCLTBCURCTA`: estructura de cuenta (`TIPCUEN`, `NROCUEN`, `SALDO`, etc.).


---

## 🏛️ Estructura del Programa  
División de procedimientos:

- **1000-INICIO**:  
  - Inicializa indicadores.
  - Abre el cursor DB2 `ITEM_CURSOR`.
  - Valida apertura correcta.

- **2000-PROCESO**:  
  - Realiza el procesamiento principal del programa.
  - Lee los registros con `FETCH`.
  - Aplica lógica de corte de control:
    - Si cambia el valor de `SUCUEN`, realiza el corte.
    - Acumula la cantidad de cuentas por sucursal.

- **2100-FETCH**:  
  - Extrae los datos del cursor y los guarda en variables de trabajo.
  - Controla el fin de datos (`SQLCODE +100`).
  - Maneja errores SQL.

- **2200-CORTE**:  
  - Imprime cantidad de cuentas por sucursal.
  - Suma al total general.
  - Reinicia el contador para la siguiente sucursal.

- **9999-FINAL**:  
  - Cierra el cursor DB2.
  - Muestra el total general acumulado.
  - Valida cierre exitoso del cursor.

---

## ⚙️ Secuencia del programa

1. **Inicio**
    - Inicializa la bandera de fin de lectura como "no alcanzado" (`WS-FIN-LECTURA `= N).
    - Abre el cursor `ITEM_CURSOR` que une las tablas de cuentas (`TBCURCTA`) y clientes (`TBCURCLI`), filtrando solo cuentas con saldo mayor a cero.
    - Si hay un error al abrir el cursor, lo informa y salta a finalización.

2. **Proceso**
  - A. `2100-FETCH-I`: Obtener datos del cursor:
    - Trae un registro (`JOIN` entre cuenta y cliente).
    - Si `SQLCODE = 0`: Mueve los campos relevantes a variables intermedias.
    - Si `SQLCODE = +100`: Marca fin de lectura.
    - Si `SQLCODE ≠ 0`: Muestra error y también marca fin.
  - B. Lógica de control de cortes  
    - Se agrupan y cuentan las cuentas por sucursal (`CTA-SUCUEN`).
    - Cada vez que cambia la sucursal, se dispara el corte de control (`2200-CORTE-I`).
    - Se acumula un total general de cuentas.

3. **Final**
    - Cierra el cursor `ITEM_CURSOR`.
    - Si hubo error al cerrar, lo informa.
    - Muestra en pantalla el total general de cuentas procesadas.
---

## 🎯 Resultado

#### 💬 Display 
```texto
---------------------------------             
SUCURSAL: 01                                  
CANTIDAD DE CUENTAS:  2                       
                                              
---------------------------------             
SUCURSAL: 02                                  
CANTIDAD DE CUENTAS:  1                       
                                              
---------------------------------             
SUCURSAL: 03                                  
CANTIDAD DE CUENTAS:  2                       
                                              
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
                                              
====================================          
TOTAL GENERAL DE CUENTAS:   11                
```


<div style="text-align: right;">

[( 🏠 )](/)

</div>
