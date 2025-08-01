CREATE VIEW V_DATOSCLIENTE AS
    SELECT c.nombre AS nombre_cliente, lnt.numero_telefono, hll.fecha_hora_inicio, hll.costo_llamada FROM clientes AS c
        INNER JOIN lineas_telefonicas AS lnt ON c.cliente_id = lnt.cliente_id
        INNER JOIN historial_llamadas AS hll ON lnt.linea_id = hll.linea_origen_id
        WHERE hll.tipo_llamada = 'Saliente';

CREATE OR REPLACE FUNCTION registrar_navegacion(
    p_linea_id INT,
    p_fecha_hora_inicio TIMESTAMP,
    p_megabytes_consumidos DECIMAL(10,2),
    p_ip_destino VARCHAR,
    p_url_accedida TEXT
) RETURNS VOID AS
$$
DECLARE
    paquete_encontrado_id INT;
BEGIN
    SELECT lp.linea_paquete_id INTO paquete_encontrado_id
    FROM lineas_paquetes lp
    WHERE lp.linea_id = p_linea_id
      AND lp.estado_paquete = 'Activo'
      AND lp.paquete_id IN (1, 2, 4)
      AND lp.fecha_expiracion > CURRENT_TIMESTAMP
    ORDER BY lp.fecha_activacion DESC
    LIMIT 1;

    IF paquete_encontrado_id IS NOT NULL THEN
        RAISE NOTICE 'Paquete encontrado: %', paquete_encontrado_id;
        UPDATE lineas_paquetes
        SET megas_restantes = megas_restantes - p_megabytes_consumidos
        WHERE linea_paquete_id = paquete_encontrado_id;

        UPDATE lineas_paquetes
        SET estado_paquete = 'Consumido'
        WHERE linea_paquete_id = paquete_encontrado_id
          AND megas_restantes <= 0;

    END IF;
    INSERT INTO historial_navegacion (
        linea_id,
        fecha_hora_inicio,
        megabytes_consumidos,
        ip_destino,
        url_accedida
    ) VALUES (
                 p_linea_id,
                 p_fecha_hora_inicio,
                 p_megabytes_consumidos,
                 p_ip_destino,
                 p_url_accedida
             );
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION comprar_paquete(
    p_linea_id INT,
    p_paquete_id INT
) RETURNS VOID AS
$$
DECLARE
    v_saldo_actual DECIMAL(10,2);
    v_precio_paquete DECIMAL(10,2);
    v_vigencia_dias INT;
    v_megas_incluidos DECIMAL(10,2);
    v_minutos_incluidos INT;
    v_sms_incluidos INT;
    v_tiene_paquete_activo BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM lineas_paquetes lp
        WHERE lp.linea_id = p_linea_id
          AND lp.estado_paquete = 'Activo'
          AND lp.fecha_expiracion > CURRENT_TIMESTAMP
    ) INTO v_tiene_paquete_activo;
    IF v_tiene_paquete_activo THEN
        RAISE EXCEPTION 'La línea % ya tiene un paquete activo vigente.', p_linea_id;
    END IF;
    SELECT precio, vigencia_dias, megas_incluidos, minutos_incluidos, sms_incluidos
    INTO v_precio_paquete, v_vigencia_dias, v_megas_incluidos, v_minutos_incluidos, v_sms_incluidos
    FROM paquetes
    WHERE paquete_id = p_paquete_id
      AND activo = TRUE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El paquete con ID % no existe o está inactivo.', p_paquete_id;
    END IF;
    SELECT saldo_actual INTO v_saldo_actual
    FROM lineas_telefonicas
    WHERE linea_id = p_linea_id;
    IF v_saldo_actual < v_precio_paquete THEN
        RAISE EXCEPTION 'Saldo insuficiente. Se requieren %.2f pero hay %.2f.', v_precio_paquete, v_saldo_actual;
    END IF;
    INSERT INTO lineas_paquetes (
        linea_id,
        paquete_id,
        fecha_activacion,
        fecha_expiracion,
        minutos_restantes,
        sms_restantes,
        megas_restantes
    ) VALUES (
                 p_linea_id,
                 p_paquete_id,
                 CURRENT_TIMESTAMP,
                 CURRENT_TIMESTAMP + (v_vigencia_dias || ' days')::INTERVAL,
                 v_minutos_incluidos,
                 v_sms_incluidos,
                 v_megas_incluidos
             );
    UPDATE lineas_telefonicas
    SET saldo_actual = saldo_actual - v_precio_paquete
    WHERE linea_id = p_linea_id;
END;
$$ LANGUAGE plpgsql;
