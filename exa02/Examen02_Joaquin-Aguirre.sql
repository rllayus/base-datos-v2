---Ejercicio 3
CREATE INDEX idx_historial_llamadas_tipo_llamada ON historial_llamadas(tipo_llamada);
CREATE INDEX idx_historial_llamadas_linea_origen_id ON historial_llamadas(linea_origen_id);
CREATE INDEX idx_lineas_telefonicas_cliente_id ON lineas_telefonicas(cliente_id);

CREATE OR REPLACE VIEW llamadas_por_cliente AS
SELECT
    c.nombre,
    lt.numero_telefono,
    hl.fecha_hora_inicio,
    hl.duracion_segundos,
    hl.costo_llamada,
    hl.tipo_llamada
FROM clientes c
INNER JOIN lineas_telefonicas lt ON c.cliente_id = lt.cliente_id
INNER JOIN historial_llamadas hl ON lt.linea_id = hl.linea_origen_id
WHERE hl.tipo_llamada = 'Saliente';

SELECT * FROM llamadas_por_cliente;


---Ejercicio 4------------------------------------------------------------------------------------------------
SELECT linea_paquete_id, linea_id, paquete_id, megas_restantes, estado_paquete
FROM lineas_paquetes
WHERE estado_paquete = 'Activo'
  AND megas_restantes <= 0;
UPDATE lineas_paquetes
SET estado_paquete = 'Inactivo'
WHERE estado_paquete = 'Activo'
  AND megas_restantes <= 0;


CREATE OR REPLACE PROCEDURE registrar_historial_navegacion(
    p_linea_id INT,
    p_megabytes_consumidos DECIMAL(10,2),
    p_ip_destino VARCHAR,
    p_url TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    paquete_id INT;
    paquete_megas_restantes DECIMAL(10,2);
    linea_paquete_id BIGINT;
BEGIN
    SELECT linea_paquete_id, paquete_id, megas_restantes
    INTO linea_paquete_id, paquete_id, paquete_megas_restantes
    FROM lineas_paquetes
    WHERE linea_id = p_linea_id
      AND estado_paquete = 'Activo'
      AND paquete_id IN (1, 2, 4)
    ORDER BY fecha_activacion DESC
    LIMIT 1;

    IF FOUND AND paquete_megas_restantes >= p_megabytes_consumidos THEN
        UPDATE lineas_paquetes
        SET megas_restantes = megas_restantes - p_megabytes_consumidos
        WHERE linea_paquete_id = linea_paquete_id;

        INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida)
        VALUES (p_linea_id, NOW(), p_megabytes_consumidos, p_ip_destino, p_url);
    END IF;
END;
$$;



---Ejercicio 5----------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE comprar_paquete(
    p_linea_id INT,
    p_paquete_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    existe_paquete_activo BOOLEAN;
    paquete RECORD;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM lineas_paquetes
        WHERE linea_id = p_linea_id
          AND estado_paquete = 'Activo'
    ) INTO existe_paquete_activo;

    IF existe_paquete_activo THEN
        RAISE NOTICE 'Ya existe un paquete activo';
        RETURN;
    END IF;

    SELECT * INTO paquete FROM paquetes WHERE paquete_id = p_paquete_id;

    INSERT INTO lineas_paquetes (
        linea_id, paquete_id, fecha_activacion, fecha_expiracion,
        minutos_restantes, sms_restantes, megas_restantes, estado_paquete
    ) VALUES (
        p_linea_id,
        p_paquete_id,
        NOW(),
        NOW() + (paquete.vigencia_dias || ' dias')::interval,
        paquete.minutos_incluidos,
        paquete.sms_incluidos,
        paquete.megas_incluidos,
        'Activo'
    );
END;
$$;

SELECT * FROM lineas_paquetes WHERE linea_id=9 AND paquete_id=2;
call comprar_paquete(9,2);

----------------------------------------------------------------
 UPDATE lineas_paquetes
        SET megas_restantes = 0
        WHERE linea_paquete_id = linea_paquete_id;