-- =====================================================================================
-- PROYECTO: CORE BANCARIO - SISTEMAS DISTRIBUIDOS Y BASES DE DATOS
-- DESCRIPCIÓN: Script consolidado de Tablas, Stored Procedures y Data Seeding
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- FASE 1: PREPARACIÓN DEL ENTORNO
-- -------------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Limpieza preventiva (Cuidado: Borra todo en el esquema actual)
DROP TABLE IF EXISTS planilla_detalle CASCADE;
DROP TABLE IF EXISTS planilla_cabecera CASCADE;
DROP TABLE IF EXISTS movimientos CASCADE;
DROP TABLE IF EXISTS prestamos_plan_pagos CASCADE;
DROP TABLE IF EXISTS transferencias CASCADE;
DROP TABLE IF EXISTS prestamos CASCADE;
DROP TABLE IF EXISTS aml_alertas CASCADE;
DROP TABLE IF EXISTS cuentas CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS entidades_externas CASCADE;

-- -------------------------------------------------------------------------------------
-- FASE 2: DEFINICIÓN DE DATOS (DDL)
-- -------------------------------------------------------------------------------------

-- 1. Clientes y Cumplimiento
CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_documento VARCHAR(50) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    categoria VARCHAR(20) DEFAULT 'REGULAR', -- 'ESTUDIANTE', 'DOCENTE', 'VIP', 'EMPRESA'
    estado_kyc VARCHAR(20) DEFAULT 'APROBADO',
    nivel_riesgo_aml VARCHAR(20) DEFAULT 'BAJO',
    fecha_registro TIMESTAMP DEFAULT (CURRENT_TIMESTAMP - INTERVAL '1 year')
);

CREATE TABLE aml_alertas (
    id SERIAL PRIMARY KEY,
    cliente_id UUID REFERENCES clientes(id),
    tipo_alerta VARCHAR(50) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'ABIERTA',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Cuentas Bancarias
CREATE TABLE cuentas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES clientes(id),
    numero_cuenta VARCHAR(50) UNIQUE NOT NULL,
    moneda VARCHAR(5) NOT NULL, -- BOB, USD, USDT
    saldo DECIMAL(18, 8) DEFAULT 0.00000000 CHECK (saldo >= 0),
    estado VARCHAR(20) DEFAULT 'ACTIVA',
    fecha_apertura TIMESTAMP DEFAULT (CURRENT_TIMESTAMP - INTERVAL '1 year')
);

-- 3. Entidades Externas
CREATE TABLE entidades_externas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo_identificador VARCHAR(50),
    tipo_entidad VARCHAR(20) NOT NULL
);

-- 4. Motor de Préstamos
CREATE TABLE prestamos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES clientes(id),
    cuenta_desembolso_id UUID REFERENCES cuentas(id),
    monto_principal DECIMAL(18, 8) NOT NULL,
    tasa_interes_anual DECIMAL(5, 2) NOT NULL,
    plazo_meses INT NOT NULL,
    fecha_desembolso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'VIGENTE'
);

CREATE TABLE prestamos_plan_pagos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prestamo_id UUID REFERENCES prestamos(id),
    numero_cuota INT NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    monto_cuota DECIMAL(18, 8) NOT NULL,
    componente_capital DECIMAL(18, 8) NOT NULL,
    componente_interes DECIMAL(18, 8) NOT NULL,
    estado_pago VARCHAR(20) DEFAULT 'PENDIENTE'
);

-- 5. Transacciones y Movimientos (Ledger Inmutable)
CREATE TABLE transferencias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cuenta_origen_id UUID REFERENCES cuentas(id),
    cuenta_destino_id UUID REFERENCES cuentas(id),
    entidad_externa_id INT REFERENCES entidades_externas(id),
    tipo VARCHAR(30) NOT NULL,
    monto DECIMAL(18, 8) NOT NULL,
    moneda VARCHAR(5) NOT NULL,
    estado VARCHAR(20) DEFAULT 'COMPLETADA',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE movimientos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cuenta_id UUID REFERENCES cuentas(id),
    transferencia_id UUID REFERENCES transferencias(id),
    tipo_movimiento VARCHAR(10) NOT NULL, -- CREDITO, DEBITO
    monto DECIMAL(18, 8) NOT NULL,
    saldo_posterior DECIMAL(18, 8) NOT NULL,
    descripcion VARCHAR(255) NOT NULL, -- <--- CAMPO CORREGIDO Y AÑADIDO
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Módulo de Planillas (Procesamiento Batch)
CREATE TABLE planilla_cabecera (
    id SERIAL PRIMARY KEY,
    cuenta_empresa_id UUID REFERENCES cuentas(id),
    monto_total DECIMAL(18,8),
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planilla_detalle (
    id SERIAL PRIMARY KEY,
    cabecera_id INT REFERENCES planilla_cabecera(id),
    cuenta_destino_numero VARCHAR(50),
    monto DECIMAL(18,8),
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    mensaje_error TEXT
);

-- Índices de Rendimiento
CREATE INDEX idx_cuentas_cliente ON cuentas(cliente_id);
CREATE INDEX idx_cuentas_numero ON cuentas(numero_cuenta);
CREATE INDEX idx_movimientos_cuenta ON movimientos(cuenta_id);


DO $$
DECLARE
    v_trans_id UUID;
    v_saldo_origen DECIMAL(18,8); v_saldo_destino DECIMAL(18,8);
    cuentas_bob UUID[]; len_bob INT;
    idx_origen INT; idx_destino INT;
    r_origen UUID; r_destino UUID; v_monto DECIMAL(18,8);
    r_cliente_id UUID; v_prestamo_id UUID;
    v_cuota DECIMAL(18,8); v_saldo_restante DECIMAL(18,8); v_interes_mes DECIMAL(18,8);
    v_capital_mes DECIMAL(18,8); v_fecha_vencimiento DATE; v_estado_pago VARCHAR(20);
    v_tasa_mensual DECIMAL(18,8); v_fecha_desembolso TIMESTAMP;
BEGIN
    RAISE NOTICE '1. Generando 20,000 Clientes...';
    INSERT INTO clientes (numero_documento, nombres, apellidos, email, categoria)
    SELECT 'DOC-' || lpad(i::text, 7, '0'), 'Nombre_' || i, 'Apellido_' || i, 'cliente_' || i || '@test.com', 'REGULAR'
    FROM generate_series(1, 20000) AS i;

    RAISE NOTICE '2. Generando 20,000 Cuentas fondeadas...';
    INSERT INTO cuentas (cliente_id, numero_cuenta, moneda, saldo)
    SELECT id, 'CTA-' || substring(id::text from 1 for 8) || '-' || trunc(random() * 1000),
        CASE (random() * 2)::int WHEN 0 THEN 'BOB' WHEN 1 THEN 'USD' ELSE 'USDT' END, 100000.00
    FROM clientes;

    SELECT array_agg(id) INTO cuentas_bob FROM cuentas WHERE moneda = 'BOB';
    len_bob := array_length(cuentas_bob, 1);

    RAISE NOTICE '3. Simulando 50,000 Transferencias...';
    FOR i IN 1..50000 LOOP
        idx_origen := floor(random() * len_bob + 1)::int;
        idx_destino := floor(random() * len_bob + 1)::int;
        WHILE idx_origen = idx_destino LOOP idx_destino := floor(random() * len_bob + 1)::int; END LOOP;

        r_origen := cuentas_bob[idx_origen]; r_destino := cuentas_bob[idx_destino];
        v_monto := (random() * 499 + 1)::numeric(18,8);

        INSERT INTO transferencias (cuenta_origen_id, cuenta_destino_id, tipo, monto, moneda)
        VALUES (r_origen, r_destino, 'TRANSFERENCIA', v_monto, 'BOB') RETURNING id INTO v_trans_id;

        UPDATE cuentas SET saldo = saldo - v_monto WHERE id = r_origen RETURNING saldo INTO v_saldo_origen;
        INSERT INTO movimientos (cuenta_id, transferencia_id, tipo_movimiento, monto, saldo_posterior, descripcion)
        VALUES (r_origen, v_trans_id, 'DEBITO', v_monto, v_saldo_origen, 'Transferencia enviada (Seed)');

        UPDATE cuentas SET saldo = saldo + v_monto WHERE id = r_destino RETURNING saldo INTO v_saldo_destino;
        INSERT INTO movimientos (cuenta_id, transferencia_id, tipo_movimiento, monto, saldo_posterior, descripcion)
        VALUES (r_destino, v_trans_id, 'CREDITO', v_monto, v_saldo_destino, 'Transferencia recibida (Seed)');
    END LOOP;

    RAISE NOTICE '4. Generando 2,000 Préstamos con Amortización Francesa...';
    FOR i IN 1..2000 LOOP
        idx_origen := floor(random() * len_bob + 1)::int;
        r_origen := cuentas_bob[idx_origen];
        SELECT cliente_id INTO r_cliente_id FROM cuentas WHERE id = r_origen;

        v_monto := 100000.00 + (random() * 400000.00)::numeric(18,2);
        v_tasa_mensual := (12.00 / 100.0) / 12.0; -- Tasa fija 12% anual para simplificar prueba
        v_fecha_desembolso := CURRENT_TIMESTAMP - (random() * 180 || ' days')::interval;

        INSERT INTO prestamos (cliente_id, cuenta_desembolso_id, monto_principal, tasa_interes_anual, plazo_meses, fecha_desembolso)
        VALUES (r_cliente_id, r_origen, v_monto, 12.00, 12, v_fecha_desembolso) RETURNING id INTO v_prestamo_id;

        v_cuota := v_monto * (v_tasa_mensual * power(1 + v_tasa_mensual, 12)) / (power(1 + v_tasa_mensual, 12) - 1);
        v_saldo_restante := v_monto;

        FOR mes IN 1..12 LOOP
            v_fecha_vencimiento := (v_fecha_desembolso + (mes || ' months')::interval)::date;
            v_interes_mes := v_saldo_restante * v_tasa_mensual;
            v_capital_mes := v_cuota - v_interes_mes;

            IF mes = 12 THEN v_capital_mes := v_saldo_restante; v_cuota := v_capital_mes + v_interes_mes; END IF;
            v_saldo_restante := v_saldo_restante - v_capital_mes;
            v_estado_pago := CASE WHEN v_fecha_vencimiento < CURRENT_DATE THEN 'PAGADO' ELSE 'PENDIENTE' END;

            INSERT INTO prestamos_plan_pagos (prestamo_id, numero_cuota, fecha_vencimiento, monto_cuota, componente_capital, componente_interes, estado_pago)
            VALUES (v_prestamo_id, mes, v_fecha_vencimiento, v_cuota, v_capital_mes, v_interes_mes, v_estado_pago);
        END LOOP;
    END LOOP;

    RAISE NOTICE '¡Base de Datos Core Bancario inicializada y lista para el trabajo práctico!';
END $$;


CREATE OR REPLACE PROCEDURE sp_pago_planilla(
    p_numero_cuenta_origen VARCHAR,
    p_numeros_cuenta_destino VARCHAR[],
    p_monto_por_empleado DECIMAL(18,8)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cuenta_origen_id UUID;
    v_saldo_actual_origen DECIMAL(18,8);
    v_moneda_origen VARCHAR(5);
    v_total_planillado DECIMAL(18,8);

    v_numero_cuenta_dest VARCHAR;
    v_cuenta_dest_id UUID;
    v_moneda_dest VARCHAR(5);
    v_trans_id UUID;
    v_saldo_origen_post DECIMAL(18,8);
    v_saldo_destino_post DECIMAL(18,8);
    v_cantidad_empleados INT;
BEGIN
    -- 1. Calcular el total requerido para la planilla
    v_cantidad_empleados := array_length(p_numeros_cuenta_destino, 1);

    IF v_cantidad_empleados IS NULL OR v_cantidad_empleados = 0 THEN
        RAISE EXCEPTION 'El arreglo de cuentas destino está vacío.';
    END IF;

    v_total_planillado := p_monto_por_empleado * v_cantidad_empleados;

    -- 2. Resolver el UUID de la empresa, bloquear la fila y validar fondos
    SELECT id, saldo, moneda INTO v_cuenta_origen_id, v_saldo_actual_origen, v_moneda_origen
    FROM cuentas
    WHERE numero_cuenta = p_numero_cuenta_origen
    FOR UPDATE;

    IF v_cuenta_origen_id IS NULL THEN
        RAISE EXCEPTION 'La cuenta origen proporcionada (%) no existe.', p_numero_cuenta_origen;
    END IF;

    IF v_saldo_actual_origen < v_total_planillado THEN
        RAISE EXCEPTION 'Fondos insuficientes en la cuenta %. Se requieren % % pero solo hay % %',
                        p_numero_cuenta_origen, v_total_planillado, v_moneda_origen, v_saldo_actual_origen, v_moneda_origen;
    END IF;

    -- 3. Procesar el arreglo de números de cuenta
    FOREACH v_numero_cuenta_dest IN ARRAY p_numeros_cuenta_destino LOOP

        -- Buscar la cuenta del empleado
        SELECT id, moneda INTO v_cuenta_dest_id, v_moneda_dest
        FROM cuentas
        WHERE numero_cuenta = v_numero_cuenta_dest;

        -- Al usar RAISE EXCEPTION aquí, PostgreSQL hace un ROLLBACK automático de TODO.
        IF v_cuenta_dest_id IS NULL THEN
            RAISE EXCEPTION 'Error: La cuenta destino % no existe. Planilla abortada.', v_numero_cuenta_dest;
        END IF;

        IF v_moneda_dest != v_moneda_origen THEN
            RAISE EXCEPTION 'Error: La cuenta destino % opera en %, pero la planilla es en %. Conflicto de moneda.',
                            v_numero_cuenta_dest, v_moneda_dest, v_moneda_origen;
        END IF;

        -- Registrar Transferencia
        INSERT INTO transferencias (cuenta_origen_id, cuenta_destino_id, tipo, monto, moneda, estado)
        VALUES (v_cuenta_origen_id, v_cuenta_dest_id, 'PAGO_PLANILLA', p_monto_por_empleado, v_moneda_origen, 'COMPLETADA')
        RETURNING id INTO v_trans_id;

        -- Debitar a la empresa
        UPDATE cuentas SET saldo = saldo - p_monto_por_empleado WHERE id = v_cuenta_origen_id
        RETURNING saldo INTO v_saldo_origen_post;

        INSERT INTO movimientos (cuenta_id, transferencia_id, tipo_movimiento, monto, saldo_posterior, descripcion)
        VALUES (v_cuenta_origen_id, v_trans_id, 'DEBITO', p_monto_por_empleado, v_saldo_origen_post, 'Pago Planilla a: ' || v_numero_cuenta_dest);

        -- Acreditar al empleado
        UPDATE cuentas SET saldo = saldo + p_monto_por_empleado WHERE id = v_cuenta_dest_id
        RETURNING saldo INTO v_saldo_destino_post;

        INSERT INTO movimientos (cuenta_id, transferencia_id, tipo_movimiento, monto, saldo_posterior, descripcion)
        VALUES (v_cuenta_dest_id, v_trans_id, 'CREDITO', p_monto_por_empleado, v_saldo_destino_post, 'Abono Planilla de: ' || p_numero_cuenta_origen);

    END LOOP;

    -- Si llegamos hasta aquí sin que ningún RAISE EXCEPTION se haya disparado,
    -- el motor hace el COMMIT de toda la transacción de forma implícita y segura.
    RAISE NOTICE 'Planilla procesada exitosamente para % empleados.', v_cantidad_empleados;

END;
$$;


DO $$
DECLARE
    -- Variables para almacenar los datos de prueba
    v_cuenta_empresa VARCHAR;
    v_empleados_array VARCHAR[];
BEGIN
    -- 1. Obtener la cuenta de la empresa (Tomamos una cuenta en BOB con buen saldo)
    -- En un caso real, el usuario ya sabe su número de cuenta.
    SELECT numero_cuenta INTO v_cuenta_empresa
    FROM cuentas
    WHERE moneda = 'BOB' AND saldo > 50000
    LIMIT 1;

    -- 2. Construir el arreglo de cuentas destino (empleados)
    -- Seleccionamos 3 números de cuenta aleatorios en BOB distintos a la empresa
    SELECT array_agg(numero_cuenta) INTO v_empleados_array
    FROM (
        SELECT numero_cuenta
        FROM cuentas
        WHERE moneda = 'BOB' AND numero_cuenta != v_cuenta_empresa
        LIMIT 3
    ) AS subquery;

    RAISE NOTICE 'Iniciando pago de planilla...';
    RAISE NOTICE 'Cuenta Empresa: %', v_cuenta_empresa;
    RAISE NOTICE 'Cuentas Empleados: %', v_empleados_array;

    -- 3. EJECUCIÓN DEL PROCEDIMIENTO ALMACENADO
    -- Utilizamos la instrucción CALL pasando el monto fijo (Ej: 3500.00)
    CALL sp_pago_planilla(
        v_cuenta_empresa,
        v_empleados_array,
        3500.00
    );

END $$;