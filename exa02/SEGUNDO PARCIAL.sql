CREATE OR REPLACE VIEW V_DATOS_CLIENTE AS
SELECT c.nombre, lt.numero_telefono, hl.fecha_hora_inicio, hl.duracion_segundos, hl.costo_llamada
        FROM clientes c
    JOIN public.lineas_telefonicas lt ON c.cliente_id = lt.cliente_id
    JOIN public.historial_llamadas hl on lt.linea_id = hl.linea_origen_id
WHERE hl.tipo_llamada='Saliente';


SELECT COUNT(*) FROM V_DATOS_CLIENTE WHERE numero_telefono='70130013';

DROP INDEX idx_lt;
DROP INDEX idx_hl;
DROP INDEX idx_hl_tipo;

CREATE INDEX idx_lt ON lineas_telefonicas (cliente_id);

CREATE INDEX idx_hl ON historial_llamadas (linea_origen_id);

CREATE INDEX idx_hl_tipo ON historial_llamadas (tipo_llamada);



CREATE OR REPLACE PROCEDURE P_REG_HISTORIAL(
    IN hn_linea_id INTEGER,
    IN hn_megabytes_consumindo NUMERIC(10,2),
    IN hn_ip_destino VARCHAR(200),
    IN hn_url_accedida TEXT,
    INOUT result VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE

BEGIN


    INSERT INTO historial_navegacion(linea_id, fecha_hora_inicio, ip_destino, url_accedida, megabytes_consumidos)
    VALUES (hn_linea_id, now(), hn_ip_destino, hn_url_accedida, hn_megabytes_consumindo);

    UPDATE lineas_paquetes SET megas_restantes = megas_restantes-hn_megabytes_consumindo WHERE linea_id=hn_linea_id;

    result:='ejecutado correctamente';

END;
$$;


CALL p_reg_historial(9, 20, '10.10.10.10', null, '');

SELECT count(*) FROM historial_navegacion WHERE linea_id=9;


CREATE OR REPLACE PROCEDURE P_COMPRAR_DATOS(
    IN c_cliente_id INTEGER,
    IN l_linea_id INTEGER,
    IN p_paquete_id INTEGER,
    INOUT result VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE

    v_tiempo_paquete            integer;
    v_minutos_paquete            integer;
    v_sms_paquete            integer;
    v_megas_paquete            numeric(10,2);

BEGIN

    select p.vigencia_dias, p.minutos_incluidos, p.sms_incluidos, p.megas_incluidos into v_tiempo_paquete, v_minutos_paquete, v_sms_paquete, v_megas_paquete
                                                FROM paquetes p WHERE p.paquete_id=p_paquete_id LIMIT 1;

   IF NOT EXISTS (SELECT 1 FROM lineas_paquetes lp
       JOIN lineas_telefonicas lt on lp.linea_id = lt.linea_id
        JOIN clientes c on c.cliente_id = lt.cliente_id
            JOIN paquetes p on p.paquete_id = lp.paquete_id
                WHERE c.cliente_id=c_cliente_id AND p.paquete_id=p_paquete_id AND lp.estado_paquete='Activo') THEN

       INSERT INTO lineas_paquetes (linea_id, paquete_id, fecha_activacion, fecha_expiracion, minutos_restantes, sms_restantes, megas_restantes)
       VALUES (l_linea_id, p_paquete_id, now(), now()+v_tiempo_paquete, v_minutos_paquete, v_sms_paquete, v_megas_paquete);

       result:='realizado correctamente';
       return;
   end if;

    result:='Ya tiene paquetes';


END;
$$;

CALL P_COMPRAR_DATOS(1, 2, 3, '');

SELECT * FROM lineas_paquetes WHERE linea_id=1 AND paquete_id=3;

SELECT c.cliente_id, lp.linea_id FROM lineas_paquetes lp
       JOIN lineas_telefonicas lt on lp.linea_id = lt.linea_id
        JOIN clientes c on c.cliente_id = lt.cliente_id
            JOIN paquetes p on p.paquete_id = lp.paquete_id
                WHERE c.cliente_id=1 AND p.paquete_id=3 AND lp.estado_paquete='Activo'
