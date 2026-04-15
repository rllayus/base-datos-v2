-- Limpieza previa
DROP TABLE IF EXISTS uso_datos CASCADE;
DROP TABLE IF EXISTS llamadas_voz CASCADE;
DROP TABLE IF EXISTS facturas CASCADE;
DROP TABLE IF EXISTS compras_paquetes CASCADE;
DROP TABLE IF EXISTS bolsas_saldo CASCADE;
DROP TABLE IF EXISTS catalogo_paquetes CASCADE;
DROP TABLE IF EXISTS abonados CASCADE;
DROP TABLE IF EXISTS planes_servicio CASCADE;

-- 1. PLANES DE SERVICIO
CREATE TABLE planes_servicio (
    id_plan UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_plan VARCHAR(100) NOT NULL,
    tipo_plan VARCHAR(50) NOT NULL,
    costo_mensual NUMERIC(10, 2) NOT NULL,
    limite_datos_gb INT,
    limite_minutos_voz INT,
    esta_activo BOOLEAN DEFAULT TRUE
);

-- 2. ABONADOS
CREATE TABLE abonados (
    id_abonado UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_plan UUID NOT NULL,
    numero_documento VARCHAR(50),
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    numero_telefono VARCHAR(20) UNIQUE NOT NULL,
    correo_electronico VARCHAR(150),
    estado_linea VARCHAR(20) DEFAULT 'ACTIVA',
    fecha_registro TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_abonado_plan FOREIGN KEY (id_plan) REFERENCES planes_servicio(id_plan)
);

-- 3. CATÁLOGO DE PAQUETES
CREATE TABLE catalogo_paquetes (
    id_paquete UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_paquete VARCHAR(100) NOT NULL,
    costo NUMERIC(10, 2) NOT NULL,
    volumen_datos_mb INT DEFAULT 0,
    minutos_voz INT DEFAULT 0,
    vigencia_dias INT NOT NULL,
    esta_activo BOOLEAN DEFAULT TRUE
);

-- 4. BOLSAS DE SALDO (OCS)
CREATE TABLE bolsas_saldo (
    id_bolsa UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_abonado UUID NOT NULL UNIQUE,
    saldo_datos_mb NUMERIC(15, 2) DEFAULT 0.00,
    saldo_minutos_voz NUMERIC(10, 2) DEFAULT 0.00,
    fecha_expiracion TIMESTAMP,
    ultima_actualizacion TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_saldo_abonado FOREIGN KEY (id_abonado) REFERENCES abonados(id_abonado)
);

-- 5. COMPRAS DE PAQUETES
CREATE TABLE compras_paquetes (
    id_compra UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_abonado UUID NOT NULL,
    id_paquete UUID NOT NULL,
    fecha_compra TIMESTAMP NOT NULL DEFAULT NOW(),
    monto_pagado NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_compra_abonado FOREIGN KEY (id_abonado) REFERENCES abonados(id_abonado),
    CONSTRAINT fk_compra_paquete FOREIGN KEY (id_paquete) REFERENCES catalogo_paquetes(id_paquete)
);

-- 6. FACTURAS
CREATE TABLE facturas (
    id_factura UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_abonado UUID NOT NULL,
    numero_factura VARCHAR(50) UNIQUE NOT NULL,
    monto_total NUMERIC(10, 2) NOT NULL,
    fecha_emision TIMESTAMP NOT NULL,
    estado_pago VARCHAR(20) DEFAULT 'PENDIENTE',
    CONSTRAINT fk_factura_abonado FOREIGN KEY (id_abonado) REFERENCES abonados(id_abonado)
);

-- 7. LLAMADAS DE VOZ
CREATE TABLE llamadas_voz (
    id_llamada UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_abonado UUID NOT NULL,
    numero_destino VARCHAR(20) NOT NULL,
    hora_inicio TIMESTAMP NOT NULL,
    duracion_segundos INT NOT NULL,
    costo_facturado NUMERIC(10, 2) DEFAULT 0.00,
    tipo_llamada VARCHAR(50),
    CONSTRAINT fk_llamada_abonado FOREIGN KEY (id_abonado) REFERENCES abonados(id_abonado)
);

-- 8. USO DE DATOS
CREATE TABLE uso_datos (
    id_uso UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_abonado UUID NOT NULL,
    hora_uso TIMESTAMP NOT NULL,
    tipo_red VARCHAR(10),
    volumen_descarga_bytes BIGINT NOT NULL,
    CONSTRAINT fk_uso_abonado FOREIGN KEY (id_abonado) REFERENCES abonados(id_abonado)
);

-- Índices Estratégicos
CREATE INDEX idx_abonados_telefono ON abonados(numero_telefono);
CREATE INDEX idx_facturas_fecha ON facturas(fecha_emision);
CREATE INDEX idx_llamadas_fecha ON llamadas_voz(hora_inicio);
CREATE INDEX idx_compras_fecha ON compras_paquetes(fecha_compra);


DO $$
DECLARE
    -- Variables para almacenar arreglos de UUIDs generados y poder referenciarlos
    arr_planes UUID[];
    arr_paquetes UUID[];
    arr_abonados UUID[];
BEGIN
    -- A. Insertar 3 Planes y capturar sus UUIDs
    WITH planes_insertados AS (
        INSERT INTO planes_servicio (nombre_plan, tipo_plan, costo_mensual, limite_datos_gb, limite_minutos_voz) VALUES
        ('Plan Básico 4G', 'PREPAGO', 50.00, 10, 500),
        ('Plan Avanzado 5G', 'POSTPAGO', 150.00, 50, 2000),
        ('Plan Ilimitado PRO', 'POSTPAGO', 250.00, 999, 9999)
        RETURNING id_plan
    )
    SELECT array_agg(id_plan) INTO arr_planes FROM planes_insertados;

    -- B. Insertar 3 Paquetes y capturar sus UUIDs
    WITH paquetes_insertados AS (
        INSERT INTO catalogo_paquetes (nombre_paquete, costo, volumen_datos_mb, minutos_voz, vigencia_dias) VALUES
        ('Bolsita WhatsApp 1 Día', 2.00, 200, 0, 1),
        ('Combo Noche 1GB + 30min', 10.00, 1024, 30, 2),
        ('Súper Combo Semanal', 30.00, 5120, 150, 7)
        RETURNING id_paquete
    )
    SELECT array_agg(id_paquete) INTO arr_paquetes FROM paquetes_insertados;

    -- C. Generar 5,000 Abonados seleccionando un plan aleatorio del arreglo
    WITH abonados_insertados AS (
        INSERT INTO abonados (id_plan, numero_documento, nombres, apellidos, numero_telefono, fecha_registro)
        SELECT
            arr_planes[trunc(random() * 3 + 1)::INT],
            (1000000 + trunc(random() * 9000000))::text,
            'Usuario_' || seq,
            'Apellido_' || seq,
            '+591' || (70000000 + seq)::text,
            NOW() - (random() * INTERVAL '2 years')
        FROM generate_series(1, 5000) AS seq
        RETURNING id_abonado
    )
    SELECT array_agg(id_abonado) INTO arr_abonados FROM abonados_insertados;

    -- D. Generar 5,000 Bolsas de Saldo (1 por abonado)
    INSERT INTO bolsas_saldo (id_abonado, saldo_datos_mb, saldo_minutos_voz, fecha_expiracion)
    SELECT
        unnest(arr_abonados), -- Desenvolvemos el arreglo de UUIDs de abonados
        (random() * 5000)::NUMERIC(15,2),
        (random() * 500)::NUMERIC(10,2),
        NOW() + (random() * INTERVAL '30 days');

    -- E. Generar 20,000 Compras de Paquetes
    INSERT INTO compras_paquetes (id_abonado, id_paquete, fecha_compra, monto_pagado)
    SELECT
        arr_abonados[trunc(random() * 5000 + 1)::INT],
        arr_paquetes[trunc(random() * 3 + 1)::INT],
        NOW() - (random() * INTERVAL '2 years'),
        (random() * 30)::NUMERIC(10,2)
    FROM generate_series(1, 20000);

    -- F. Generar 50,000 Llamadas
    INSERT INTO llamadas_voz (id_abonado, numero_destino, hora_inicio, duracion_segundos, tipo_llamada)
    SELECT
        arr_abonados[trunc(random() * 5000 + 1)::INT],
        '+591' || (70000000 + trunc(random() * 9999999))::text,
        NOW() - (random() * INTERVAL '2 years'),
        trunc(random() * 3600),
        CASE WHEN random() > 0.5 THEN 'ON-NET' ELSE 'OFF-NET' END
    FROM generate_series(1, 50000);

    -- G. Generar 50,000 Registros de Datos
    INSERT INTO uso_datos (id_abonado, hora_uso, tipo_red, volumen_descarga_bytes)
    SELECT
        arr_abonados[trunc(random() * 5000 + 1)::INT],
        NOW() - (random() * INTERVAL '2 years'),
        CASE WHEN random() > 0.3 THEN '4G' ELSE '5G' END,
        trunc(random() * 1073741824)
    FROM generate_series(1, 50000);
END $$;

-- Generar 12 facturas por cada abonado (1 por mes)
INSERT INTO facturas (id_abonado, numero_factura, monto_total, fecha_emision, estado_pago)
SELECT
    a.id_abonado,
    -- Generamos un número de factura único basado en el año, mes y teléfono
    'FAC-' || TO_CHAR(NOW() - (meses.m * INTERVAL '1 month'), 'YYYYMM') || '-' || SUBSTRING(a.numero_telefono FROM 5),
    -- Monto aleatorio entre 50.00 y 250.00
    (random() * 200 + 50)::NUMERIC(10,2),
    -- Fecha de emisión: primer día del mes respectivo +/- 2 días aleatorios
    NOW() - (meses.m * INTERVAL '1 month') - (random() * INTERVAL '2 days'),
    -- El 85% de las facturas aparecerán como PAGADAS
    CASE WHEN random() > 0.15 THEN 'PAGADA' ELSE 'PENDIENTE' END
FROM abonados a
CROSS JOIN generate_series(1, 12) AS meses(m);

-- Verificación: Contar cuántas facturas se crearon
SELECT count(*) as total_facturas FROM facturas;