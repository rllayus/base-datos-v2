--vista que muestre el nombre del cliente, numero de telefono, fecha de llamada, duracion de la llamada, costo de la llamada cuyo tipo_llamda seaigual a "Saliente" y escribir sus indices

CREATE OR REPLACE VIEW vista_llamadas_salientes AS
SELECT
    c.nombre AS nombre_cliente,
    lt.numero_telefono,
    hl.fecha_hora_inicio,
    hl.duracion_segundos,
    hl.costo_llamada
FROM
    historial_llamadas hl
        INNER JOIN lineas_telefonicas lt ON hl.linea_origen_id = lt.linea_id
        INNER JOIN clientes c ON lt.cliente_id = c.cliente_id
WHERE
    hl.tipo_llamada = 'Saliente';

CREATE INDEX idx_historial_llamadas_tipo_llamada ON historial_llamadas(tipo_llamada, fecha_hora_inicio, duracion_segundos, costo_llamada);

CREATE INDEX idx_clientes_nombre ON clientes(nombre);

CREATE INDEX idx_lineas_telefonicas_numero ON lineas_telefonicas(numero_telefono);

SELECT COUNT(*) AS total_registros
FROM vista_llamadas_salientes
WHERE numero_telefono = '70030003';

CALL registrar_historial_navegacion(9, 100, '192.168.0.0', 'google.tech');
SELECT * FROM historial_navegacion WHERE linea_id=9
ORDER BY navegacion_id desc ;

SELECT * from lineas_paquetes WHERE linea_id=9 and paquete_id=2;

--Procedimiento almacenado para registrar el historial de navegacion de una linea, tomando en cuenta que si la linea tiene comprado un paquete con ID 1,2 o 4 se debe hacer un descuento del saldo del paquete
CREATE OR REPLACE PROCEDURE registrar_historial_navegacion(
    p_linea_id INT,
    p_megabytes_consumidos DECIMAL(10,2),
    p_ip_destino VARCHAR(15),
    p_url_accedida VARCHAR(255)
) LANGUAGE plpgsql
AS $$
DECLARE
    v_paquete_id INT;
    v_megas_restantes DECIMAL(10,2);
BEGIN
    -- Buscar paquete
    SELECT paquete_id, megas_restantes
    INTO v_paquete_id, v_megas_restantes
    FROM lineas_paquetes
    WHERE linea_id = p_linea_id
      AND estado_paquete = 'Activo'
      AND paquete_id IN (1,2,4)
    LIMIT 1;

    -- historial navegacion
    INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida)
    VALUES (p_linea_id, NOW(), p_megabytes_consumidos, p_ip_destino, p_url_accedida);

    -- descontar megas
    IF v_paquete_id IS NOT NULL THEN
        UPDATE lineas_paquetes
        SET megas_restantes = GREATEST(0, v_megas_restantes - p_megabytes_consumidos)
        WHERE linea_id = p_linea_id
          AND paquete_id = v_paquete_id
          AND estado_paquete = 'Activo';
    END IF;
END;
$$;



create procedure registrar_historial_navegacion2(IN p_linea_id integer, IN p_megabytes_consumidos numeric, IN p_ip_destino character varying, IN p_url_accedida character varying)
    language plpgsql
as
$$
DECLARE
    v_paquete_id INT;
    v_megas_restantes DECIMAL(10,2);
BEGIN
    --Encontrar el paquete 1 , 2, 4
    SELECT paquete_id, megas_restantes
    INTO v_paquete_id, v_megas_restantes
    FROM lineas_paquetes
    WHERE linea_id = p_linea_id
      AND estado_paquete = 'Activo'
      AND paquete_id IN (1,2,4)
    ORDER BY fecha_activacion
    LIMIT 1;

    -- Insertar al registro de navegacion
    INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida)
    VALUES (p_linea_id, NOW(), p_megabytes_consumidos, p_ip_destino, p_url_accedida);

    -- Reducir megas restantes
    IF v_paquete_id IS NOT NULL THEN
        UPDATE lineas_paquetes
        SET megas_restantes = GREATEST(0, v_megas_restantes - p_megabytes_consumidos)
        WHERE linea_id = p_linea_id
          AND paquete_id = v_paquete_id
          AND estado_paquete = 'Activo';
    END IF;
END;
$$;
SELECT * FROM historial_navegacion WHERE linea_id = 4 ORDER BY fecha_hora_inicio DESC;

SELECT * FROM lineas_paquetes WHERE linea_id =9 AND paquete_id = 2;

    SELECT linea_id, cliente_id
    FROM lineas_telefonicas
    WHERE linea_id = 9
      AND estado_linea = 'Activa'
    LIMIT 1;

CALL comprar_paquete_datos(7, 2);
--Procedimiento almacenado para que un cliente pueda comparar un paquete de datos, considerar que si ya tiene el paquete adquirido y esta vigente no debe poder adquirir otro
create procedure comprar_paquete_datos(IN p_cliente_id integer, IN p_paquete_id integer)
    language plpgsql
as
$$
DECLARE
    v_linea_id INT;
    v_paquete_activo INT;
    v_minutos INT;
    v_sms INT;
    v_megas DECIMAL(10,2);
    v_vigencia INT;
    v_fecha_expiracion TIMESTAMP;
BEGIN
    -- Obtener la linea del cliente
    SELECT linea_id INTO v_linea_id
    FROM lineas_telefonicas
    WHERE cliente_id = p_cliente_id
      AND estado_linea = 'Activa'
    LIMIT 1;

    IF v_linea_id IS NULL THEN
        RAISE EXCEPTION 'No hay linea activa para el cliente %', p_cliente_id;
    END IF;

    -- Buscar paquete activo
    SELECT 1 INTO v_paquete_activo
    FROM lineas_paquetes
    WHERE linea_id = v_linea_id
      AND paquete_id = p_paquete_id
      AND estado_paquete = 'Activo'
      AND fecha_expiracion > NOW()
    LIMIT 1;

    IF v_paquete_activo IS NOT NULL THEN
        RAISE EXCEPTION 'El paquete ya esta activo para la linea %', v_linea_id;
    END IF;

    -- Obtener los detalles del paquete
    SELECT minutos_incluidos, sms_incluidos, megas_incluidos, vigencia_dias
    INTO v_minutos, v_sms, v_megas, v_vigencia
    FROM paquetes
    WHERE paquete_id = p_paquete_id
      AND activo = TRUE;
    v_fecha_expiracion :='2025-09-12 13:31:37.836262';

    -- Asignar el paquete a la linea
    INSERT INTO lineas_paquetes (
        linea_id, paquete_id, fecha_activacion, fecha_expiracion,
        minutos_restantes, sms_restantes, megas_restantes, estado_paquete
    ) VALUES (
                 v_linea_id, p_paquete_id, NOW(), v_fecha_expiracion,
                 v_minutos, v_sms, v_megas, 'Activo'
             );
END;
$$;





SELECT * FROM lineas_paquetes WHERE linea_id IN (
    SELECT linea_id FROM lineas_telefonicas WHERE cliente_id = 4
);