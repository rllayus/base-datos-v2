
/******************************************************************************
   NAME:
   PURPOSE:   Script que para crear usuario y base de datos en Postgres

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/05/2025   RICARDO LAREDO       1. Creación de Base de Datos
******************************************************************************/

CREATE USER user_01 WITH
LOGIN  -- Indica que este usuario(rol) puede autenticarse
NOSUPERUSER -- Indica que este usuario no es un superusuario
INHERIT -- Indica que este rol herede los privilegios de los roles a los que pertenece.
NOCREATEDB -- Indica que este usuario no puede crear una base de datos
NOCREATEROLE -- Indica que este usuario no debe o puede crear roles
NOREPLICATION; --Indica que este usuario no puede iniciar el proceso de replicación ni activar el modo de copia de seguridad

/***
  Esta sentencia permite cambiar o definir contraseña a un usuario
 */
ALTER USER user_01 WITH PASSWORD '123456';
/**
  Sentencia para crear una base de datos y asigna a un usuario como dueño
 */
CREATE DATABASE my_db_01 WITH OWNER user_01;
/**
  Sentencia a asignar todos los privilegios de una base de datos a un usuario
 */
GRANT ALL PRIVILEGES ON DATABASE my_db_01 TO user_01;
/**********************************************************************************************************************/
 -- Crear un usuario con permiso de sólo lectura a la tabla persona
    CREATE USER user_reporte WITH
    LOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION;

    ALTER USER user_reporte WITH PASSWORD '123456';

-- Autenticarse con el usuario admin y ejecutar la sentencia
    GRANT SELECT ON TABLE my_user TO user_reporte;

/**********************************************************************************************************************/
/**
  Sentencia para eliminar una base de datos
 */
drop database my_db_01;

/**
  Sentencia para eliminar un rol, esta sentencia igualmente elimina al usuario porque son lo mismo
 */
drop role user_reporte;