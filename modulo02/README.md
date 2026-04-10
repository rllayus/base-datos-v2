# PROGRAMACION EN BASE DE DATOS

* **0. Vistas en PL/SQL**
* **1. Bloque anónimo o Bloque DO en PL/SQL**
* **2. Manejo de excepciones y logs en programación en PL/SQL**
* **3. Control de Flujo en PL/SQL**
* **4. Manejo de buclesen PL/SQL**
* **5. Procedimientos almacenados PL/SQL**
* **6. Funciones almacenados PL/SQL**
* **7. Triggers en PL/SQL**
* **8. Indices en PL/SQL**


## 0. Vistas en PL/SQL 
Son consultas en memoria

```sql
    CREATE OR REPLACE VIEW V_PLANILLA AS 
           SELECT * FROM ESTUDIANTES;
```
## 1. Bloque anónimo en PL/SQL 
Los bloques anónimos se ejecutan a través de la sentencia DO. Son fragmentos de código temporal que no se guardan en la base de datos. Son ideales para tareas de mantenimiento rápido, pruebas de lógica o scripts de migración de un solo uso.

## 2. Creación de base de datos
Ahora que hemos definido un usuario y contraseña es hora de crear una base de datos y asignar como propietario al usuario 
que acabamos de crear, para ello ejecutaremos la siguiente sentencia.
```sql
    CREATE DATABASE my_db_01 WITH OWNER user_01;
```
### Sintaxis
```sql
    DO $$ 
DECLARE
    v_estudiantes_activos INT;
    v_carrera_target VARCHAR := 'SIS';
BEGIN
    -- 1. Hacemos un cálculo rápido al vuelo
    SELECT COUNT(*) INTO v_estudiantes_activos
    FROM estudiante e
    INNER JOIN carrera c ON e.id_carrera = c.id_carrera
    WHERE c.sigla = v_carrera_target;

    -- 2. Evaluamos e imprimimos el resultado en consola
    IF v_estudiantes_activos > 0 THEN
        RAISE NOTICE 'Hay % estudiantes activos en la carrera %.', v_estudiantes_activos, v_carrera_target;
    ELSE
        RAISE WARNING 'No se encontraron estudiantes en la carrera %.', v_carrera_target;
    END IF;

END $$ LANGUAGE plpgsql;
```
