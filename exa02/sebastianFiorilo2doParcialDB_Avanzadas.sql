--3 del examen

create or replace view clientes_tipollamada AS
select c.nombre as NOMBRE_CLIENTE,lt.numero_telefono as NUMERO_TELEFONO, hl.duracion_segundos as DURACION, hl.costo_llamada from clientes c
    inner join lineas_telefonicas lt on c.cliente_id = lt.cliente_id
    inner join historial_llamadas hl on lt.linea_id = hl.linea_origen_id
    WHERE hl.tipo_llamada = 'Saliente';

select * from clientes_tipollamada where NUMERO_TELEFONO =  '70070007';

--4 del examen

CREATE OR REPLACE PROCEDURE registrar_HN(
    p_linea_id               INTEGER,
    p_fecha_hora_inicio      TIMESTAMP,
    p_megabytes_consumidos   NUMERIC(10,2),
    p_ip_destino             VARCHAR,
    p_url_accedida           TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_paquete_id      INTEGER;
    v_megas_restantes NUMERIC(10,2);
    v_nuevo_saldo     NUMERIC(10,2);
BEGIN
    SELECT paquete_id,
           megas_restantes
      INTO v_paquete_id,
           v_megas_restantes
    FROM lineas_paquetes
    WHERE linea_id = p_linea_id
      AND paquete_id IN (1,2,4)
      AND estado_paquete = 'Activo'
      AND CURRENT_TIMESTAMP BETWEEN fecha_activacion AND fecha_expiracion
    LIMIT 1;

    IF v_paquete_id IS NOT NULL THEN
        v_nuevo_saldo := v_megas_restantes - p_megabytes_consumidos;
        IF v_nuevo_saldo < 0 THEN
            v_nuevo_saldo := 0;
        END IF;

        UPDATE lineas_paquetes
           SET megas_restantes = v_nuevo_saldo
         WHERE linea_id   = p_linea_id
           AND paquete_id = v_paquete_id;
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
$$;


-----
DO $$
DECLARE
    -- Declara variables para los parámetros de entrada
    v_linea_param        INTEGER        := 9;
     v_fecha_hora_inicio_params      TIMESTAMP:= current_timestamp;
    v_megas_param        NUMERIC(10,2)       := 1000;
    v_ip_destino_param   VARCHAR   := '1100.e234234';
    v_url_accedida_param TEXT  := 'https://www.google.com';
BEGIN
    CALL registrar_HN(
        p_linea_id          => v_linea_param,
        p_fecha_hora_inicio => v_fecha_hora_inicio_params,
        p_megabytes_consumidos     => v_megas_param,
        p_ip_destino   => v_ip_destino_param,
        p_url_accedida           => v_url_accedida_param
    );
    RAISE NOTICE 'El resultado del procedimiento HISTORIAL_NAVEGACION es: ';
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ocurrió un error al llamar al procedimiento: %', SQLERRM;
END $$ LANGUAGE plpgsql;


CALL registrar_HN(
  1,
  '2025-06-13 14:05:00',
  40.25,
  '192.168.0.10',
  'https://example.com/pagina.html'
);

select * from lineas_paquetes where linea_id = 9;

select * from lineas_telefonicas;


select count(*) from historial_navegacion where linea_id =9;

--5 del examen

CREATE OR REPLACE PROCEDURE compra_paquetes(
    p_linea_id    INTEGER,
    p_paquete_id  INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count_vigente    INTEGER;
    v_vigencia_dias    INTEGER;
    v_minutos_inc      INTEGER;
    v_sms_inc          INTEGER;
    v_megas_inc        NUMERIC(10,2);
    v_saldo            NUMERIC(10,2);
    v_precio            NUMERIC(10,2);
    v_fecha_inicio     TIMESTAMP;
    v_fecha_expiracion TIMESTAMP;
BEGIN
    SELECT COUNT(*)
      INTO v_count_vigente
    FROM lineas_paquetes
    WHERE linea_id       = p_linea_id
      AND paquete_id     = p_paquete_id
      AND estado_paquete = 'Activo'
      AND CURRENT_TIMESTAMP
          BETWEEN fecha_activacion AND fecha_expiracion;

    IF v_count_vigente > 0 THEN
        RAISE EXCEPTION 'La línea ya tiene activo el paquete ';
    END IF;

    SELECT saldo_actual
      INTO v_saldo
    FROM lineas_telefonicas
    WHERE linea_id = p_linea_id;

    SELECT precio,
           vigencia_dias,
           minutos_incluidos,
           sms_incluidos,
           megas_incluidos
    INTO   v_precio,
           v_vigencia_dias,
           v_minutos_inc,
           v_sms_inc,
           v_megas_inc
    FROM paquetes
    WHERE paquete_id = p_paquete_id
      AND activo = TRUE
    LIMIT 1;

    IF v_saldo < v_precio THEN
        RAISE EXCEPTION 'Saldo insuficiente';
    END IF;

    v_fecha_inicio     := CURRENT_TIMESTAMP;
    v_fecha_expiracion := v_fecha_inicio + (v_vigencia_dias || ' days')::INTERVAL;

    UPDATE lineas_telefonicas
       SET saldo_actual = v_saldo - v_precio
     WHERE linea_id = p_linea_id;

    INSERT INTO lineas_paquetes (
        linea_id,
        paquete_id,
        fecha_activacion,
        fecha_expiracion,
        minutos_restantes,
        sms_restantes,
        megas_restantes,
        estado_paquete
    ) VALUES (
        p_linea_id,
        p_paquete_id,
        v_fecha_inicio,
        v_fecha_expiracion,
        v_minutos_inc,
        v_sms_inc,
        v_megas_inc,
        'Activo'
    );

    RAISE NOTICE 'Paquete asignado a línea';
END;
$$;



CALL compra_paquetes(9, 2);

CALL compra_paquetes(1, 5);

select * from lineas_paquetes where linea_id = 9 AND paquete_id=2;

select * from lineas_telefonicas where linea_id =9;

select * from paquetes;