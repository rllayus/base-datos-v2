
CREATE TABLE reporte_proyectos (
    id_empleado INT,
    nombre_empleado VARCHAR(100),
    telefono_contacto VARCHAR(200),
    departamento_id INT,
    nombre_departamento VARCHAR(50),
    ubicacion_oficina VARCHAR(50),
    id_proyecto INT,
    nombre_proyecto VARCHAR(100),
    horas_trabajadas INT,
    herramientas_usadas VARCHAR(255),
    PRIMARY KEY (id_empleado, id_proyecto)
);

INSERT INTO reporte_proyectos VALUES
(101, 'Juan Perez', '70712345, 4251234', 10, 'Sistemas', 'Piso 3', 1, 'App Movil', 40, 'Android Studio, Firebase'),
(101, 'Juan Perez', '70712345, 4251234', 10, 'Sistemas', 'Piso 3', 2, 'E-commerce', 20, 'PHP, MySQL'),
(102, 'Ana Gomez', '78900011', 20, 'Contabilidad', 'Piso 1', 1, 'App Movil', 10, 'Excel, Jira'),
(103, 'Carlos Ruiz', '60011223', 10, 'Sistemas', 'Piso 3', 3, 'Seguridad Network', 30, 'Wireshark, Nmap');

SELECT * FROM reporte_proyectos;