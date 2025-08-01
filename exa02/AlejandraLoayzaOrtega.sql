CREATE INDEX idx_linea_ClienteFk ON lineas_telefonicas (cliente_id);
CREATE INDEX idx_historial_lineaFk ON historial_llamadas (linea_origen_id);
CREATE INDEX idx_historial_tipo_llamada ON historial_llamadas (tipo_llamada);

CREATE VIEW V_LLAMADAS_REALIZADAS AS
SELECT c.nombre as nombre_cliente, lt.numero_telefono, hl.fecha_hora_inicio, hl.duracion_segundos, hl.costo_llamada
    from historial_llamadas hl
    INNER JOIN lineas_telefonicas lt ON hl.linea_origen_id = lt.linea_id
    INNER JOIN clientes c ON lt.cliente_id = c.cliente_id
         WHERE hl.tipo_llamada = 'Saliente';

SELECT * FROM V_LLAMADAS_REALIZADAS WHERE numero_telefono = '70164108';


CREATE OR REPLACE PROCEDURE DESCONTAR_PAQUETE(
    --Todos los parametros de entrada
    IN p_megas_consumidos numeric,
    IN p_numero_telefono varchar(15),
    IN p_ip_destino varchar(15),
    IN p_url_accedida text
)
    language plpgsql
as
$$
DECLARE
    --variables
    v_id_paquete      integer;
    v_id_linea      BIGINT;
    v_id_lineaPaquete      BIGINT;
    v_megas_restantes      numeric;
BEGIN
    --Get id del numero
    SELECT lt.linea_id from lineas_telefonicas lt WHERE lt.numero_telefono = p_numero_telefono INTO v_id_linea;
    --get id paquete
    SELECT lp.paquete_id, lp.linea_paquete_id from lineas_paquetes lp
                         WHERE linea_id = v_id_linea AND paquete_id IN (1,2,4)
                         ORDER BY lp.linea_paquete_id LIMIT 1
        INTO v_id_paquete, v_id_lineaPaquete;

    IF v_id_paquete IS NOT NULL THEN
        INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, megabytes_consumidos,ip_destino, url_accedida) VALUES
            (v_id_linea,now(),p_megas_consumidos,p_ip_destino, p_url_accedida);

        Select lp.megas_restantes from lineas_paquetes lp WHERE lp.linea_paquete_id = v_id_lineaPaquete INTO v_megas_restantes;
        UPDATE lineas_paquetes SET megas_restantes = (v_megas_restantes-p_megas_consumidos) WHERE linea_paquete_id = v_id_lineaPaquete;


    end if;

EXCEPTION
    WHEN others THEN
    --Matar
END;
$$;


CREATE OR REPLACE PROCEDURE COMPRAR_PAQUETE(
    --Todos los parametros de entrada
    IN p_numero_telefono varchar(15),
    IN p_id_paquete integer
)
    language plpgsql
as
$$
DECLARE
    --variables
    v_id_linea      BIGINT;
    v_id_lineaPaquete      BIGINT;
    v_megas     numeric;
    v_minutos     integer;
    v_sms     integer;
BEGIN
    --Get id del numero
    SELECT lt.linea_id from lineas_telefonicas lt WHERE lt.numero_telefono = p_numero_telefono INTO v_id_linea;

    SELECT lp.linea_paquete_id from lineas_paquetes lp
             WHERE lp.paquete_id = p_id_paquete AND lp.linea_id = v_id_linea AND lp.fecha_expiracion > now() LIMIT 1
    INTO v_id_lineaPaquete;

    IF v_id_lineaPaquete IS NULL THEN
        SELECT p.minutos_incluidos, p.sms_incluidos, p.megas_incluidos from paquetes p WHERE p.paquete_id = p_id_paquete
        INTO v_minutos, v_sms, v_megas;

        INSERT INTO lineas_paquetes (linea_id, paquete_id, fecha_activacion, fecha_expiracion, minutos_restantes, sms_restantes, megas_restantes, estado_paquete) VALUES
            (v_id_linea,p_id_paquete,now(),now(), v_minutos,v_sms, v_megas, 'Activo');

    end if;

EXCEPTION
    WHEN others THEN
    --Matar
END;
$$;


