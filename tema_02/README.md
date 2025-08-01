# DISEÑO DE BASE DE DATOS LOGICO

* **1. Modelo ER**
* **2. Relación de uno a muchos**
* **3. Relación de muchos a muchos**
* **4. Representación física de un diseño lógico**


## 1. Modelo ER
Para realizar el moddelo ER utilizaremos [dbdesigner](https://erd.dbdesigner.net/) que nos permite modelar 

```sql
    CREATE USER user_reporte WITH
    LOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
```
Con la sentencia anterior hemos creado un usuario que 
* podrá hacer login pero no será super usuario
* Heredará los privilegios del rol padre
* No podrá crear Base de Datos
* No podrá crear roles o usuarios
* y no podrá iniciar el proceso de réplica o backup de seguridad.

Para que definamos una contraseña para el usuario se debe ejecutar la siguiente sentencia
```sql
    ALTER USER user_01 WITH PASSWORD '123456';
```

## 2. Creación de base de datos
Ahora que hemos definido un usuario y contraseña es hora de crear una base de datos y asignar como propietario al usuario 
que acabamos de crear, para ello ejecutaremos la siguiente sentencia.
```sql
    CREATE DATABASE my_db_01 WITH OWNER user_01;
```

## 3. Asignación de permiso a un usuario
Ahora que hemos creado la Base de Datos es hora de definir los privilegios que el usuario propietario tendrá sobre la 
base de datos;
Se supone que el nuevo usuario como es **OWNER** debiera tener todos los privilegios, por lo que le asignaremos esto.
```sql
    GRANT ALL PRIVILEGES ON DATABASE my_db_01 TO user_01;
```
La sentencia anterior otorga todos los privilegios al usuario **user_01**, pero este usuario no le podriamos otorgar por 
ejemplo al personal de soporte o desarrollo, porque existe la posibilidad ya sea por voluntad o involuntariamente realicen
modificaciones, inserciones  o peor aún elminaciones a nivel de la base de datos.  
Por esto, lo recomendable es crear un usuario para cada persona que vaya a ingresar al motor de base de dato bajo el 
principio del mínimo privilegio(PoLP) o *Principle of Least Privilege*

Para esto crearemos un rol llamado **user_reporte** que tendrá permiso de sóplo **lectura**  a la tabla **my_user** para
ello primero nos conectaremos a la base de datos con el usuario **owner** y crearemos una tabla y poblaremos de registros
a la tabla; para ello use el script [create_table.sql](create_table.sql)

Ahora que ya existe la tabla, creemos el usuario **user_reporte**; esta sentencia debe ser ejecutado autenticado como 
usurio *postgres*. 
```sql
    CREATE USER user_reporte WITH
    LOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION;

    ALTER USER user_reporte WITH PASSWORD '123456';
```
Ahora que está creado el usuario, es hora de darle los permisos de lectura a la tabla my_user, para ello; primero debemos
autenticarnos con el usuario owner de la base de datos, en este caso es **user_01**, una vez autenticado, se debe ejecutar
el siguiente sentencia.

```sql
       GRANT SELECT ON TABLE my_user TO user_reporte;
```
Para verificar si ha hecho efecto la configuración, conectese a la base de datos con el nuevo usuario e intente hacer una 
insersión, el resultado esperao es que se genere un error que indique que no tenemos permiso.

## 4. Práctica en clases

Cree una nueva base de datos llamado **spa_db** con las siguientes tablas:
* _user
* ventas

Juan Perez que es un administrador del usuario de la organización necesita revisar la cantidad de usuario que hay en el 
sistema y necesita eliminar usuario.

Ada Sofia que es la encargada comercial necesita acceder a hacer consultas a la tabla ventas y a ninguna otra tabla más.

---
## Práctica en clases
Se requiere crear una base de datos para la empresa **Coca Cola** con las siguientes consideraciones
* La cuenta **Owner** sólo debe ser utilizado para la administración de la Base de Datos
* Se debe crear un usuario para la aplicación de pedidos que le permita realizar INSERT, UPDATE, DELETE y que permita crear tablas, secuencias
* Para el sistema de reportes se debe crear un usuario que sólo pueda leer datos

## Optimización de base de datos
Para optimizar la base de datos se debe configurar parámetros del motor de base de datos, para saber que parámetos se debe modificar 
es mejor utilizar el sitio [PGTune](https://pgtune.leopard.in.ua/)
Se debe colocar los parámetros solicitados y el sitio web generará los valores a configurar. 
Los valores generadors se debe ejecutar con el usuario root 

psql -h localhost -U postgres -p 5432 -d postgres