--ISABELA ORTIZ
-- index por número de teléfono
CREATE INDEX idx_lineas_numero_telefono ON lineas_telefonicas(numero_telefono);

-- index filtrar por tipo de llamada
CREATE INDEX idx_historial_tipo_llamada ON historial_llamadas(tipo_llamada);

CREATE OR REPLACE VIEW vista_llamadas_salientes AS
SELECT
    c.nombre AS nombre_cliente,
    c.apellido AS apellido_cliente,
    l.numero_telefono,
    h.fecha_hora_inicio AS fecha_llamada,
    h.duracion_segundos AS duracion,
    h.costo_llamada
FROM historial_llamadas h
         JOIN lineas_telefonicas l ON h.linea_origen_id = l.linea_id
         JOIN clientes c ON l.cliente_id = c.cliente_id
WHERE h.tipo_llamada = 'Saliente' AND l.numero_telefono = '70150015';

SELECT * FROM vista_llamadas_salientes;
-- SIN INDICE 371 ms
-- CON INDICE 292 ms

-- DROP INDEX idx_historial_tipo_llamada;
-- DROP INDEX idx_lineas_numero_telefono;

select count(*) from vista_llamadas_salientes;

DROP PROCEDURE registrar_y_descontar;


-- PROCEDIMIENTO ALMACENADO
-- REGISTRAR HISTORIAL DE NAVEGACION DE UNA LINEA Y SI TIENE PAQUETE 1,2,4 HACER UN DESCUENTO DEL SALDO DEL PAQUETE
CREATE OR REPLACE PROCEDURE registrar_y_descontar(
    p_linea_id INT,
    p_megas_consumidos DECIMAL,
    p_ip_destino VARCHAR,
    p_url_accedida TEXT
--     p_fecha_hora timestamp default now()
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_linea_paquete_id BIGINT;
    v_megas_restantes DECIMAL;
BEGIN
    -- insertar el registro d
    INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida)
    VALUES (p_linea_id, now(), p_megas_consumidos, p_ip_destino, p_url_accedida);

    -- buscar paquete 1, 2 o 4
    SELECT linea_paquete_id, megas_restantes
    INTO v_linea_paquete_id, v_megas_restantes
    FROM lineas_paquetes
    WHERE linea_id = p_linea_id
      AND paquete_id IN (1,2,4)
      AND estado_paquete = 'Activo'
      AND fecha_activacion <= now()
      AND fecha_expiracion >= now()
    ORDER BY fecha_activacion DESC
    LIMIT 1;

    IF FOUND THEN
        IF v_megas_restantes > p_megas_consumidos THEN
            RAISE NOTICE 'entra al if';
            UPDATE lineas_paquetes
            SET megas_restantes = megas_restantes - p_megas_consumidos
            WHERE linea_paquete_id = v_linea_paquete_id;
        ELSE
            UPDATE lineas_paquetes
            SET megas_restantes = 0,
                estado_paquete = 'Consumido'
            WHERE linea_paquete_id = v_linea_paquete_id;
        END IF;
    END IF;
END;
$$;

call registrar_y_descontar(9, 100, '192.179','stereum2.tech');
--0.00
--2020.00
---996.00
--0.00
--5120.00
--5120.00

SELECT * FROM historial_navegacion where linea_id=9 order by navegacion_id desc ;
SELECT * from lineas_paquetes where linea_id=9 AND paquete_id IN (1,2,4);

---2020.00
-996.00
5020.00
