--Ejercicio 3: Vista que muestre nombre del cliente, numero de telefono, fecha de la llamada, duracion,
--costo de las llamadas cuyo tipo_llamada sea igual a 'Saliente'.Debe asegurarse de escribir igual sus
-- indices si es que los necesitara

CREATE OR REPLACE VIEW VIEW_LLAMADAS_CLIENTES AS
    SELECT
        c.cliente_id,
        c.nombre AS nombre_cliente,
        c.apellido AS apellido_cliente,
        lt.numero_telefono,
        hl.fecha_hora_inicio AS fecha_de_la_llamada,
        hl.duracion_segundos,
        hl.costo_llamada
    FROM
        clientes c
    INNER JOIN
            lineas_telefonicas lt ON c.cliente_id = lt.cliente_id
    INNER JOIN
        historial_llamadas hl ON lt.linea_id = hl.linea_origen_id
 WHERE hl.tipo_llamada = 'Saliente';


SELECT COUNT(*) FROM VIEW_LLAMADAS_CLIENTES WHERE numero_telefono= '70100010';
SELECT COUNT(*) FROM VIEW_LLAMADAS_CLIENTES;
SELECT * FROM VIEW_LLAMADAS_CLIENTES;

--EJERCICIO 4 PROCEDIMIENTO ALMACENADO PARA REGISTRAR EL HISTORIAL DE NAVEGACION DE UNA LINEA,
--TOMANDO EN CUENTA QUE SI LA LINEA TIENE COMPRADO UN PAQUETE  CON ID 1,2, O 4,
-- SE DEBE HACER UN DESCUENTO DEL SALDO DEL PAQUETE y dar los megas consumidos.
-- En caso de que el cliente tenga 2 o
-- mas paquetes de los seleccionados, ordenarlo de forma

CREATE OR REPLACE PROCEDURE P_registro_historial_navegacion(
    p_linea_id INT,
    p_megabytes_consumidos DECIMAL(10,2),
    p_ip_destino VARCHAR(45),
    p_url_accedida TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_linea_paquete_id BIGINT;
    v_megas_restantes_paquete DECIMAL(10,2);
    v_megas_a_descontar DECIMAL(10,2);
BEGIN

    SELECT
        lp.linea_paquete_id,
        lp.megas_restantes
    INTO
        v_linea_paquete_id,
        v_megas_restantes_paquete
    FROM
        lineas_paquetes lp
    JOIN
        paquetes p ON lp.paquete_id = p.paquete_id
    WHERE
        lp.linea_id = p_linea_id
        AND lp.estado_paquete = 'Activo'
        AND lp.fecha_expiracion > NOW()
        AND lp.megas_restantes > 0
        AND p.paquete_id IN (1, 2, 4)
    ORDER BY
        lp.fecha_expiracion ASC
    LIMIT 1;

    IF v_linea_paquete_id IS NOT NULL THEN
        v_megas_a_descontar := LEAST(p_megabytes_consumidos, v_megas_restantes_paquete);

        UPDATE lineas_paquetes
        SET
            megas_restantes = megas_restantes - v_megas_a_descontar,
            estado_paquete = CASE
                                 WHEN (megas_restantes - v_megas_a_descontar) <= 0 THEN 'Consumido'
                                 ELSE 'Activo'
                             END
        WHERE
            linea_paquete_id = v_linea_paquete_id;

    END IF;

    INSERT INTO historial_navegacion (
        linea_id,
        fecha_hora_inicio,
        megabytes_consumidos,
        ip_destino,
        url_accedida
    ) VALUES (
        p_linea_id,
        NOW(),
        p_megabytes_consumidos,
        p_ip_destino,
        p_url_accedida
    );

END;
$$;

CALL P_registro_historial_navegacion(2,10.0,
                                     '172.217.160.142', 'google2.com' );

SELECT * FROM historial_navegacion WHERE linea_id=2 AND url_accedida='google2.com';

--EJERCICO 5
--PROCEDIMIENTO ALMACENADO PARA QUE UN CLIENTE PUEDA COMPRAR UN PAQUETE DE DATOS,
-- CONSIDERAR QUE SI YA TIENE EL PAQUETE ADQUIRIDO Y ESTA VIGENTE NO DEBE PODER ADQUIRIR OTRO
CREATE OR REPLACE PROCEDURE comprar_paquete_datos(
    p_linea_id INT,
    p_paquete_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existente INT;
    v_fecha_actual TIMESTAMP := now();
    v_vigencia_dias INT;
BEGIN
    -- Verificar si ya tiene el paquete activo y vigente
    SELECT COUNT(*) INTO v_existente
    FROM lineas_paquetes
    WHERE linea_id = p_linea_id
      AND paquete_id = p_paquete_id
      AND estado_paquete = 'Activo'
      AND fecha_expiracion > v_fecha_actual;

    IF v_existente > 0 THEN
        RAISE EXCEPTION 'Ya tiene este paquete activo y ESTA  vigente.';
    END IF;

    -- Obtener los datos del paquete
    SELECT vigencia_dias INTO v_vigencia_dias
    FROM paquetes
    WHERE paquete_id = p_paquete_id AND activo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El paquete no existe o no está activo.';
    END IF;

    -- Insertar la compra del paquete
    INSERT INTO lineas_paquetes (
        linea_id,
        paquete_id,
        fecha_activacion,
        fecha_expiracion,
        minutos_restantes,
        sms_restantes,
        megas_restantes,
        estado_paquete
    )
    SELECT
        p_linea_id,
        p_paquete_id,
        v_fecha_actual,
        v_fecha_actual + (vigencia_dias || ' days')::INTERVAL,
        minutos_incluidos,
        sms_incluidos,
        megas_incluidos,
        'Activo'
    FROM paquetes
    WHERE paquete_id = p_paquete_id;

    RAISE NOTICE 'Paquete comprado exitosamente.';

END;
$$;

CALL comprar_paquete_datos('2', 2);

SELECT * FROM lineas_paquetes WHERE linea_id=2 AND paquete_id=2;
select numero_telefono from lineas_telefonicas where linea_id='2';
