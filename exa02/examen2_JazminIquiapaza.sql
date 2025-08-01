CREATE OR REPLACE VIEW vista_historial_llamadas AS
SELECT
    c.nombre AS cliente,
    lt.numero_telefono,
    hl.fecha_hora_inicio AS fecha_llamada,
    hl.duracion_segundos,
    hl.costo_llamada,
    hl.tipo_llamada
FROM clientes c
         INNER JOIN public.lineas_telefonicas lt on c.cliente_id = lt.cliente_id
         INNER JOIN public.historial_llamadas hl on lt.linea_id = hl.linea_origen_id
WHERE hl.tipo_llamada = 'Saliente';

CREATE INDEX idx_linea_cliente ON lineas_telefonicas (cliente_id);
CREATE INDEX idx_historial_cliente ON historial_llamadas(linea_origen_id);

CREATE INDEX idx_tipo_llamada ON historial_llamadas (tipo_llamada);

------ indice para poder filtrar por numero en la vista
CREATE INDEX idx_numero_telefono ON lineas_telefonicas (numero_telefono);

SELECT * FROM vista_historial_llamadas where numero_telefono = '70070007'; ----- 517 ms

CREATE OR REPLACE PROCEDURE HISTORIAL_NAVEGACION(
    IN p_linea bigint,
    IN p_megas_consumidos numeric,
    IN p_ip_destino varchar(45),
    IN p_url_accedida varchar(100),

    INOUT result character varying
)
    language plpgsql
as
$$
DECLARE
    v_megas_restantes numeric;
    v_paquete_id integer;
    v_linea_paquete integer;
BEGIN

    SELECT linea_paquete_id as v_linea_paquete, megas_restantes AS v_megas_restantes, paquete_id AS v_paquete_id
    INTO v_linea_paquete, v_megas_restantes, v_paquete_id
    FROM lineas_paquetes WHERE linea_id = p_linea  IN ( 1, 2, 4)LIMIT  1 FOR UPDATE;
    --FROM lineas_paquetes WHERE linea_id = p_linea AND  paquete_id IN ( 1, 2, 4)LIMIT  1 FOR UPDATE;


    IF v_megas_restantes <> 0 AND v_megas_restantes > p_megas_consumidos  THEN
        --IF p_linea <> 0  THEN
          --  result := 'ERROR - NUMERO INVALIDO';
        --ELSE

            INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, ip_destino, url_accedida)
            values (p_linea, now(), p_ip_destino, p_url_accedida);

            UPDATE lineas_paquetes lp SET megas_restantes = (v_megas_restantes - p_megas_consumidos)
            WHERE linea_paquete_id = v_linea_paquete;
            result:= v_linea_paquete;
        --END IF;
    ELSE
        result := 'NO HAY MEGAS';
    END IF;

END;
$$;

SELECT linea_paquete_id as v_linea_paquete, megas_restantes AS v_megas_restantes, paquete_id AS v_paquete_id
    FROM lineas_paquetes WHERE linea_id = 9 AND  paquete_id IN ( 1, 2, 4);

DO $$
DECLARE
    -- Declara variables para los parámetros de entrada
    v_linea_param        BIGINT        := 9;
        v_megas_param        NUMERIC       := 1000;
    v_ip_destino_param   VARCHAR(45)   := '192.168.1.100';
    v_url_accedida_param VARCHAR(100)  := 'https://www.google.com';
    v_resultado_proc     VARCHAR;
BEGIN
    CALL HISTORIAL_NAVEGACION(
        p_linea          => v_linea_param,
        p_megas_consumidos => v_megas_param,
        p_ip_destino     => v_ip_destino_param,
        p_url_accedida   => v_url_accedida_param,
        result           => v_resultado_proc  -- Aquí se asignará el valor de salida
    );
    RAISE NOTICE 'El resultado del procedimiento HISTORIAL_NAVEGACION es: %', v_resultado_proc;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ocurrió un error al llamar al procedimiento: %', SQLERRM;
END $$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE COMPRAR_PAQUETE(
    IN p_linea bigint,
    IN p_paquete bigint,

    INOUT result character varying
)
    language plpgsql
as
$$
DECLARE
    v_sms integer;
    v_megas integer;
    v_existe integer;
BEGIN

    SELECT linea_paquete_id
    INTO v_existe
    FROM lineas_paquetes WHERE linea_id = p_linea AND paquete_id = paquete_id;
    --FROM lineas_paquetes WHERE linea_id = p_linea AND paquete_id = p_paquete AND megas_restantes > 0 AND estado_paquete='Activo';


    --IF v_existe != 0 THEN
    IF v_existe <> 0 THEN
        result := 'YA TIENE EL PAQUETE';
    ELSE
        SELECT sms_incluidos as v_sms , megas_incluidos as v_megas  INTO v_sms, v_megas FROM paquetes WHERE  paquete_id = p_paquete;

        INSERT INTO lineas_paquetes (linea_id, paquete_id, fecha_activacion, fecha_expiracion, minutos_restantes, sms_restantes, megas_restantes)
        VALUES (p_linea, p_paquete, now(), now(), 0, v_sms, v_megas) ;
    END IF;
END;
$$;


DO $$
DECLARE
    -- Declara variables para los parámetros de entrada
    v_linea_param       integer      := 9;
    v_paquete_id        integer      := 1;
    v_resultado_proc     VARCHAR;
BEGIN
    CALL COMPRAR_PAQUETE(
        p_linea   => v_linea_param,
        p_paquete => v_paquete_id,
        result    => v_resultado_proc  -- Aquí se asignará el valor de salida
    );
    RAISE NOTICE 'El resultado del procedimiento HISTORIAL_NAVEGACION es: %', v_resultado_proc;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ocurrió un error al llamar al procedimiento: %', SQLERRM;
END $$ LANGUAGE plpgsql;


    SELECT *
    --FROM lineas_paquetes WHERE linea_id = p_linea AND paquete_id = paquete_id;
    FROM lineas_paquetes WHERE linea_id = 9 AND paquete_id = 1;

SELECT linea_paquete_id
    FROM lineas_paquetes WHERE  paquete_id = paquete_id;