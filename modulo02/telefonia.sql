-- Habilitar extensión para generar UUIDs nativos
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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
    -- Integridad referencial
    CONSTRAINT fk_abonado_plan FOREIGN KEY (id_plan) REFERENCES planes_servicio(id_plan)
);

-- 3. FACTURAS
CREATE TABLE facturas (
    id_factura UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_abonado UUID NOT NULL,
    numero_factura VARCHAR(50) UNIQUE NOT NULL,
    monto_total NUMERIC(10, 2) NOT NULL,
    fecha_emision TIMESTAMP NOT NULL,
    estado_pago VARCHAR(20) DEFAULT 'PENDIENTE',
    CONSTRAINT fk_factura_abonado FOREIGN KEY (id_abonado) REFERENCES abonados(id_abonado)
);

-- 4. LLAMADAS DE VOZ
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

-- 5. USO DE DATOS
CREATE TABLE uso_datos (
    id_uso UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_abonado UUID NOT NULL,
    hora_uso TIMESTAMP NOT NULL,
    tipo_red VARCHAR(10),
    volumen_descarga_bytes BIGINT NOT NULL,
    CONSTRAINT fk_uso_abonado FOREIGN KEY (id_abonado) REFERENCES abonados(id_abonado)
);

-- Índices para mejorar el rendimiento en búsquedas comunes
CREATE INDEX idx_abonados_telefono ON abonados(numero_telefono);
CREATE INDEX idx_facturas_fecha ON facturas(fecha_emision);
CREATE INDEX idx_llamadas_fecha ON llamadas_voz(hora_inicio);




-- Iniciar transacción para que la inserción sea extremadamente rápida
BEGIN;

-- A. Insertar 3 Planes Base
INSERT INTO planes_servicio (nombre_plan, tipo_plan, costo_mensual, limite_datos_gb, limite_minutos_voz) VALUES
('Plan Básico 4G', 'PREPAGO', 50.00, 10, 500),
('Plan Avanzado 5G', 'POSTPAGO', 150.00, 50, 2000),
('Plan Ilimitado PRO', 'POSTPAGO', 250.00, 999, 9999);

-- B. Generar 5,000 Abonados (con fechas de registro aleatorias en los últimos 2 años)
INSERT INTO abonados (id_plan, numero_documento, nombres, apellidos, numero_telefono, fecha_registro)
SELECT
    (SELECT id_plan FROM planes_servicio ORDER BY random() LIMIT 1),
    (1000000 + trunc(random() * 9000000))::text,
    'Usuario_' || seq,
    'Apellido_' || seq,
    '+591' || (70000000 + seq)::text,
    NOW() - (random() * INTERVAL '2 years')
FROM generate_series(1, 5000) AS seq;

-- C. Generar 120,000 Facturas (Aprox 24 facturas por cada uno de los 5,000 abonados)
-- Distanciadas en los últimos 2 años.
INSERT INTO facturas (id_abonado, numero_factura, monto_total, fecha_emision, estado_pago)
SELECT
    a.id_abonado,
    'FAC-' || TO_CHAR(NOW() - (meses.m * INTERVAL '1 month'), 'YYYYMM') || '-' || a.numero_telefono,
    (random() * 300 + 50)::NUMERIC(10,2),
    NOW() - (meses.m * INTERVAL '1 month') - (random() * INTERVAL '5 days'),
    CASE WHEN random() > 0.1 THEN 'PAGADA' ELSE 'PENDIENTE' END
FROM abonados a
CROSS JOIN generate_series(1, 24) AS meses(m);

-- D. Generar 50,000 Registros de Llamadas Aleatorias (En los últimos 2 años)
INSERT INTO llamadas_voz (id_abonado, numero_destino, hora_inicio, duracion_segundos, tipo_llamada)
SELECT
    (SELECT id_abonado FROM abonados ORDER BY random() LIMIT 1),
    '+591' || (70000000 + trunc(random() * 9999999))::text,
    NOW() - (random() * INTERVAL '2 years'),
    trunc(random() * 3600), -- Hasta 1 hora de duración
    CASE WHEN random() > 0.5 THEN 'ON-NET' ELSE 'OFF-NET' END
FROM generate_series(1, 50000);

-- E. Generar 50,000 Registros de Uso de Datos (En los últimos 2 años)
INSERT INTO uso_datos (id_abonado, hora_uso, tipo_red, volumen_descarga_bytes)
SELECT
    (SELECT id_abonado FROM abonados ORDER BY random() LIMIT 1),
    NOW() - (random() * INTERVAL '2 years'),
    CASE WHEN random() > 0.3 THEN '4G' ELSE '5G' END,
    trunc(random() * 1073741824) -- Hasta 1 GB por sesión
FROM generate_series(1, 50000);

-- Confirmar transacción
COMMIT;