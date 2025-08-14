-- Creación de las secuencias
CREATE SEQUENCE cliente_id_seq START 1;
CREATE SEQUENCE sucursal_id_seq START 1;
CREATE SEQUENCE almacen_id_seq START 1;
CREATE SEQUENCE trabajador_id_seq START 1;
CREATE SEQUENCE articulo_id_seq START 1;
CREATE SEQUENCE nota_venta_id_seq START 1;
CREATE SEQUENCE detalle_venta_id_seq START 1;
CREATE SEQUENCE responsable_atencion_id_seq START 1;
CREATE SEQUENCE factura_id_seq START 1;
CREATE SEQUENCE detalle_factura_id_seq START 1;
CREATE SEQUENCE datos_facturacion_id_seq START 1;
CREATE SEQUENCE detalle_almacen_id_seq START 1;

-- Creación de la tabla 'Cliente'
CREATE TABLE Cliente (
    id INT PRIMARY KEY DEFAULT nextval('cliente_id_seq'),
    nombre VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(255),
    nit VARCHAR(50),
    fecha_nacimiento DATE
);

-- Creación de la tabla 'Sucursal'
CREATE TABLE Sucursal (
    id INT PRIMARY KEY DEFAULT nextval('sucursal_id_seq'),
    nombre VARCHAR(255) NOT NULL
);

-- Creación de la tabla 'Almacen'
CREATE TABLE Almacen (
    id INT PRIMARY KEY DEFAULT nextval('almacen_id_seq'),
    nombre VARCHAR(255) NOT NULL,
    sucursal_id INT REFERENCES Sucursal(id)
);

-- Creación de la tabla 'Trabajador'
CREATE TABLE Trabajador (
    id INT PRIMARY KEY DEFAULT nextval('trabajador_id_seq'),
    nombre VARCHAR(255) NOT NULL,
    ci VARCHAR(20) NOT NULL UNIQUE,
    cargo VARCHAR(50) NOT NULL CHECK (cargo IN ('CAJERO', 'PELUQUERO', 'CONSERJE'))
);

-- Creación de la tabla 'Articulo'
CREATE TABLE Articulo (
    id INT PRIMARY KEY DEFAULT nextval('articulo_id_seq'),
    nombre_servicio VARCHAR(255) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('PRODUCTO', 'SERVICIO'))
);

-- Creación de la tabla 'Nota_Venta'
CREATE TABLE Nota_Venta (
    id INT PRIMARY KEY DEFAULT nextval('nota_venta_id_seq'),
    cliente_id INT REFERENCES Cliente(id),
    fecha DATE NOT NULL,
    importe_total DECIMAL(10, 2),
    sucursal_id INT REFERENCES Sucursal(id)
);

-- Creación de la tabla 'Detalle_Venta'
CREATE TABLE Detalle_Venta (
    id INT PRIMARY KEY DEFAULT nextval('detalle_venta_id_seq'),
    articulo_id INT REFERENCES Articulo(id),
    nota_venta_id INT REFERENCES Nota_Venta(id),
    cantidad INT NOT NULL,
    sub_total DECIMAL(10, 2),
    descuento DECIMAL(10, 2),
    total DECIMAL(10, 2)
);

-- Creación de la tabla 'Responsable_Atencion'
CREATE TABLE Responsable_Atencion (
    id INT PRIMARY KEY DEFAULT nextval('responsable_atencion_id_seq'),
    nota_venta_id INT REFERENCES Nota_Venta(id),
    trabajador_id INT REFERENCES Trabajador(id),
    comentario TEXT
);

-- Creación de la tabla 'Factura'
CREATE TABLE Factura (
    id INT PRIMARY KEY DEFAULT nextval('factura_id_seq'),
    razon_social VARCHAR(255) NOT NULL,
    nit VARCHAR(50) NOT NULL,
    metodo_pago VARCHAR(50),
    nota_venta_id INT REFERENCES Nota_Venta(id)
);

-- Creación de la tabla 'Detalle_Factura'
CREATE TABLE Detalle_Factura (
    id INT PRIMARY KEY DEFAULT nextval('detalle_factura_id_seq'),
    articulo_id INT REFERENCES Articulo(id),
    factura_id INT REFERENCES Factura(id),
    cantidad INT NOT NULL,
    sub_total DECIMAL(10, 2),
    descuento DECIMAL(10, 2),
    total DECIMAL(10, 2)
);

-- Creación de la tabla 'Datos_Facturacion'
CREATE TABLE Datos_Facturacion (
    id INT PRIMARY KEY DEFAULT nextval('datos_facturacion_id_seq'),
    nit VARCHAR(50) NOT NULL,
    razon_social VARCHAR(255) NOT NULL,
    cliente_id INT REFERENCES Cliente(id)
);

-- Creación de la tabla 'detalle_almacen'
CREATE TABLE Detalle_Almacen (
    id INT PRIMARY KEY DEFAULT nextval('detalle_almacen_id_seq'),
    almacen_id INT REFERENCES Almacen(id),
    articulo_id INT REFERENCES Articulo(id)
);

-- Insertar datos en la tabla 'Sucursal'
INSERT INTO Sucursal (nombre) VALUES
('Sucursal Central'),
('Sucursal Norte');

-- Insertar datos en la tabla 'Almacen'
INSERT INTO Almacen (nombre, sucursal_id) VALUES
('Almacen Principal', 1),
('Almacen Secundario', 1),
('Almacen Norte', 2);

-- Insertar datos en la tabla 'Cliente'
INSERT INTO Cliente (nombre, telefono, email, nit, fecha_nacimiento) VALUES
('Juan Perez', '77712345', 'juan.perez@email.com', '123456789', '1990-05-15'),
('Maria Lopez', '77798765', 'maria.lopez@email.com', '987654321', '1985-11-20'),
('Carlos Sanchez', '77755555', 'carlos.sanchez@email.com', '112233445', '1992-03-01');

-- Insertar datos en la tabla 'Trabajador'
INSERT INTO Trabajador (nombre, ci, cargo) VALUES
('Ana Gomez', '1234567', 'CAJERO'),
('Pedro Fernandez', '7654321', 'PELUQUERO'),
('Laura Morales', '9876543', 'PELUQUERO'),
('Luis Rojas', '1122334', 'CONSERJE');

-- Insertar datos en la tabla 'Articulo'
INSERT INTO Articulo (nombre_servicio, precio, tipo) VALUES
('Corte de Pelo Dama', 50.00, 'SERVICIO'),
('Corte de Pelo Caballero', 30.00, 'SERVICIO'),
('Shampoo', 25.00, 'PRODUCTO'),
('Acondicionador', 28.00, 'PRODUCTO'),
('Tratamiento Capilar', 80.00, 'SERVICIO');

-- Insertar datos en la tabla 'Detalle_Almacen'
INSERT INTO Detalle_Almacen (almacen_id, articulo_id) VALUES
(1, 3),
(1, 4),
(2, 3),
(3, 3),
(3, 4);

-- Generar notas de venta y sus detalles para un año (desde hace 365 días hasta hoy)
DO $$
DECLARE
    -- Declaración de variables, sin asignación inicial.
    start_date DATE;
    end_date DATE;
    current_day DATE; -- Renombrado de la variable
    cliente_id_random INT;
    sucursal_id_random INT;
    articulo_id_random INT;
    cantidad_random INT;
    precio_articulo DECIMAL(10, 2);
    nota_venta_id_inserted INT;
    sub_total_inserted DECIMAL(10, 2);
BEGIN
    -- Asignación de valores dentro del bloque BEGIN.
    start_date := CURRENT_DATE - INTERVAL '365 days';
    end_date := CURRENT_DATE;
    current_day := start_date; -- Asignación del valor inicial a la nueva variable

    WHILE current_day <= end_date LOOP
        -- Generar entre 1 y 5 notas de venta por día
        FOR i IN 1..floor(random() * 5) + 1 LOOP
            cliente_id_random := floor(random() * 3) + 1; -- Asumiendo 3 clientes
            sucursal_id_random := floor(random() * 2) + 1; -- Asumiendo 2 sucursales

            INSERT INTO Nota_Venta (cliente_id, fecha, importe_total, sucursal_id)
            VALUES (cliente_id_random, current_day, 0, sucursal_id_random) -- Usando la nueva variable
            RETURNING id INTO nota_venta_id_inserted;

            -- Generar entre 1 y 3 detalles de venta para cada nota
            FOR j IN 1..floor(random() * 3) + 1 LOOP
                articulo_id_random := floor(random() * 5) + 1; -- Asumiendo 5 artículos
                cantidad_random := floor(random() * 3) + 1; -- Cantidad entre 1 y 3

                SELECT precio INTO precio_articulo FROM Articulo WHERE id = articulo_id_random;
                sub_total_inserted := precio_articulo * cantidad_random;

                INSERT INTO Detalle_Venta (articulo_id, nota_venta_id, cantidad, sub_total, descuento, total)
                VALUES (articulo_id_random, nota_venta_id_inserted, cantidad_random, sub_total_inserted, 0, sub_total_inserted);
            END LOOP;

            -- Actualizar el importe_total de la nota de venta
            UPDATE Nota_Venta
            SET importe_total = (SELECT SUM(total) FROM Detalle_Venta WHERE nota_venta_id = nota_venta_id_inserted)
            WHERE id = nota_venta_id_inserted;

            -- Insertar un responsable de atención
            INSERT INTO Responsable_Atencion (nota_venta_id, trabajador_id, comentario)
            VALUES (nota_venta_id_inserted, floor(random() * 4) + 1, 'Atención al cliente');
        END LOOP;
        current_day := current_day + INTERVAL '1 day'; -- Incrementando la nueva variable
    END LOOP;
END $$;


-- Generar facturas para algunas de las notas de venta creadas
DO $$
DECLARE
    nota_venta_record RECORD;
    cliente_record RECORD;
    factura_id_inserted INT;
BEGIN
    FOR nota_venta_record IN SELECT * FROM Nota_Venta LOOP
        IF random() < 0.5 THEN
            SELECT * INTO cliente_record FROM Cliente WHERE id = nota_venta_record.cliente_id;

            INSERT INTO Factura (razon_social, nit, metodo_pago, nota_venta_id)
            VALUES (cliente_record.nombre, cliente_record.nit, 'Efectivo', nota_venta_record.id)
            RETURNING id INTO factura_id_inserted;

            INSERT INTO Detalle_Factura (articulo_id, factura_id, cantidad, sub_total, descuento, total)
            SELECT articulo_id, factura_id_inserted, cantidad, sub_total, descuento, total
            FROM Detalle_Venta
            WHERE nota_venta_id = nota_venta_record.id;
        END IF;
    END LOOP;
END $$;



DO $$
DECLARE
    -- Definimos las variables para el bucle y los valores aleatorios
    i BIGINT;
    max_nota_venta_id BIGINT;
    max_articulo_id BIGINT;
    random_nota_venta_id BIGINT;
    random_articulo_id BIGINT;
    random_cantidad INT;
    precio_articulo DECIMAL(10, 2);
    sub_total DECIMAL(10, 2);
BEGIN
    -- Obtenemos el ID máximo de las tablas referenciadas
    -- Es crucial que estas tablas ya tengan datos
    SELECT MAX(id) INTO max_nota_venta_id FROM Nota_Venta;
    SELECT MAX(id) INTO max_articulo_id FROM Articulo;

    -- Verificamos si las tablas tienen datos
    IF max_nota_venta_id IS NULL OR max_articulo_id IS NULL THEN
        RAISE EXCEPTION 'Las tablas Nota_Venta o Articulo no contienen registros.';
    END IF;

    -- Inicia el bucle para insertar 20 millones de registros
    FOR i IN 1..20000000 LOOP
        -- Generamos IDs y cantidades aleatorias
        random_nota_venta_id := (SELECT floor(random() * max_nota_venta_id) + 1)::BIGINT;
        random_articulo_id := (SELECT floor(random() * max_articulo_id) + 1)::BIGINT;
        random_cantidad := (floor(random() * 5) + 1)::INT; -- Cantidad entre 1 y 5

        -- Obtenemos el precio del artículo para calcular los totales
        SELECT precio INTO precio_articulo FROM Articulo WHERE id = random_articulo_id;

        -- Calculamos el subtotal y total (sin descuento para simplificar)
        sub_total := precio_articulo * random_cantidad;

        -- Insertamos el nuevo registro
        INSERT INTO Detalle_Venta (articulo_id, nota_venta_id, cantidad, sub_total, descuento, total)
        VALUES (random_articulo_id, random_nota_venta_id, random_cantidad, sub_total, 0, sub_total);
    END LOOP;

    -- Opcional: Mostramos un mensaje al finalizar
    RAISE NOTICE 'Se han insertado 20,000,000 de registros en Detalle_Venta.';
END $$;