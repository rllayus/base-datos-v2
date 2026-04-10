-- SOLUCIÓN: NORMALIZACIÓN A 3RA FORMA NORMAL (3NF)

-- 1. Crear tabla de Departamentos (Para cumplir 3NF - Elimina dependencia transitiva)
CREATE TABLE departamentos (
    id_departamento INT PRIMARY KEY,
    nombre_departamento VARCHAR(50),
    ubicacion_oficina VARCHAR(50)
);

-- 2. Crear tabla de Empleados (Para cumplir 2NF y 3NF)
CREATE TABLE empleados (
    id_empleado INT PRIMARY KEY,
    nombre_empleado VARCHAR(100),
    id_departamento INT,
    FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento)
);

-- 3. Crear tabla de Teléfonos (Para cumplir 1NF - Elimina valores multi-valuados)
CREATE TABLE empleado_telefonos (
    id_telefono SERIAL PRIMARY KEY,
    id_empleado INT,
    numero_telefono VARCHAR(20),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

-- 4. Crear tabla de Proyectos (Para cumplir 2NF)
CREATE TABLE proyectos (
    id_proyecto INT PRIMARY KEY,
    nombre_proyecto VARCHAR(100)
);

-- 5. Crear tabla de Herramientas (Para cumplir 1NF)
CREATE TABLE herramientas (
    id_herramienta SERIAL PRIMARY KEY,
    nombre_herramienta VARCHAR(50)
);

-- 6. Tabla Intermedia: Asignación de Proyectos (Rompe la relación Muchos a Muchos y guarda Horas)
CREATE TABLE asignacion_proyectos (
    id_empleado INT,
    id_proyecto INT,
    horas_trabajadas INT,
    PRIMARY KEY (id_empleado, id_proyecto),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    FOREIGN KEY (id_proyecto) REFERENCES proyectos(id_proyecto)
);

CREATE TABLE proyecto_herramientas (
    id_proyecto INT,
    id_herramienta INT,
    PRIMARY KEY (id_proyecto, id_herramienta),
    FOREIGN KEY (id_proyecto) REFERENCES proyectos(id_proyecto),
    FOREIGN KEY (id_herramienta) REFERENCES herramientas(id_herramienta)
);

-- ==========================================================
-- MIGRACIÓN DE DATOS (Ejemplos de cómo pasar los datos)
-- ==========================================================

-- Insertar Departamentos únicos
INSERT INTO departamentos (id_departamento, nombre_departamento, ubicacion_oficina)
SELECT DISTINCT departamento_id, nombre_departamento, ubicacion_oficina
FROM reporte_proyectos;

-- Insertar Empleados únicos
INSERT INTO empleados (id_empleado, nombre_empleado, id_departamento)
SELECT DISTINCT id_empleado, nombre_empleado, departamento_id
FROM reporte_proyectos;

-- Insertar Proyectos únicos
INSERT INTO proyectos (id_proyecto, nombre_proyecto)
SELECT DISTINCT id_proyecto, nombre_proyecto
FROM reporte_proyectos;

-- Insertar Asignaciones
INSERT INTO asignacion_proyectos (id_empleado, id_proyecto, horas_trabajadas)
SELECT id_empleado, id_proyecto, horas_trabajadas
FROM reporte_proyectos;
