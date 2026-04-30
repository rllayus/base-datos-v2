# Content for the README.md
readme_content = """# Guía de Configuración de Apache Cassandra

Este documento proporciona una guía completa para la instalación, configuración y administración de un nodo de **Apache Cassandra**, integrando pasos para sistemas operativos locales y entornos de contenedores (Docker).

---

## Configuración en Docker (Puertos)

Al levantar el contenedor (vía Docker Desktop o CLI), es vital mapear los puertos correctamente para permitir la comunicación del clúster y el acceso de clientes:

| Puerto Host | Puerto Contenedor | Descripción |
| :--- | :--- | :--- |
| **7000** | 7000 | Comunicación entre nodos (Gossip). |
| **7001** | 7001 | Comunicación entre nodos vía SSL. |
| **7199** | 7199 | Monitoreo JMX y herramientas como `nodetool`. |
| **9042** | 9042 | **Puerto Nativo CQL** (Necesario para `cqlsh`). |
| **9160** | 9160 | Puerto Thrift (Legacy). |

### Comando de ejecución rápido:
```bash
docker run --name cassandra-server -p 9042:9042 -p 7000:7000 -p 7001:7001 -p 7199:7199 -d cassandra:latest
```
### 2. Configuración a Nivel de Sistema Operativo
Una vez el servicio esté corriendo, realice los siguientes ajustes (directamente en la terminal del sistema o dentro del contenedor) para preparar el entorno de administración:

```bash
apt update
apt install vim
```


### 3. Gestión de Base de Datos (CQLSH)
Habilitar la autenticación en cassandra.yaml editanto el archivo siguiente
```bash
vim /etc/cassandra/cassandra.yaml
```
Busca la línea que dice authenticator: AllowAllAuthenticator y cámbiala por:

```bash
authenticator: PasswordAuthenticator
```
Para que el motor reconozca que ahora requiere contraseñas, debes reiniciar el servicio. Si lo estás corriendo en Docker con el nombre que usamos en el README, ejecuta:

```bash
docker restart cassandra-server
```

Para ingresar a la consola de comandos de la base de datos:
```bash
cqlsh
```

Acceso con usuario
```bash
cqlsh -u usuario -p password
```

Crea tu usuario

```bash
CREATE ROLE mi_usuario WITH PASSWORD = 'mi_password' AND LOGIN = true;
```

Comandos de Administración inicial:

```bash
-- Crear el Keyspace (Base de Datos)
CREATE KEYSPACE test3_db WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- Para salir de la consola y volver al SO
exit
```
