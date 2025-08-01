--Pregunta 3
create index idx_c_id on lineas_telefonicas (cliente_id);
create index idx_h_llamadas on historial_llamadas (linea_origen_id);

create or replace view pregunta3 as
select c.nombre as cliente, lt.numero_telefono,
       h.fecha_hora_inicio as fecha_llamada, h.duracion_segundos as duracion,
       h.costo_llamada as costo from clientes c
        inner join lineas_telefonicas lt
        on c.cliente_id = lt.cliente_id
        inner join historial_llamadas h
         on h.linea_origen_id = lt.linea_id and tipo_llamada = 'Saliente'

order by c.nombre;

select * from pregunta3 WHERE numero_telefono = '70070007'  ;

--Pregunta 4
CREATE OR REPLACE PROCEDURE pregunta4(
    IN lt_numero varchar,
    --IN lt_numero numeric, El tipo de dato en la tabla es varchar
    IN h_mega_consumido integer,
    IN h_ip_destino numeric,
    IN h_url_destino varchar(200),
    INOUT result character varying
)
    LANGUAGE plpgsql
AS $$
DECLARE
    lt_linea_id integer;
    lp_mega_restantes numeric;
    lp_id integer;

    BEGIN
        SELECT linea_id INTO lt_linea_id
        FROM lineas_telefonicas
        WHERE numero_telefono = lt_numero
        limit 1;

        IF NOT FOUND THEN
            result := 'Error: Linea telefonica no existe';
            RETURN;
        END IF;

        SELECT lp.linea_paquete_id, lp.megas_restantes - h_mega_consumido
        INTO lp_id, lp_mega_restantes
        FROM lineas_paquetes lp
        WHERE lp.linea_id = lt_linea_id
          AND (paquete_id = 1 OR paquete_id = 2 OR paquete_id = 4)
        LIMIT 1;


        INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida) VALUES (
                     lt_linea_id,
                     now(),
                     h_mega_consumido,
                     h_ip_destino,
                     h_url_destino
                 );

        UPDATE lineas_paquetes
        SET megas_restantes = lp_mega_restantes
        WHERE linea_paquete_id = lp_id;

        result := 'Operación exitosa';

    END;
$$;



-----
DO $$
DECLARE
    -- Declara variables para los parámetros de entrada
    v_linea_param        varchar        := '70070007';
    v_megas_param        integer       := 1000;
    v_ip_destino_param   numeric   := 192;
    v_url_accedida_param VARCHAR(100)  := 'https://www.google.com';
    v_resultado_proc     VARCHAR;
BEGIN
    CALL pregunta4(
        lt_numero          => v_linea_param,
        h_mega_consumido => v_megas_param,
        h_ip_destino     => v_ip_destino_param,
        h_url_destino   => v_url_accedida_param,
        result           => v_resultado_proc  -- Aquí se asignará el valor de salida
    );
    RAISE NOTICE 'El resultado del procedimiento HISTORIAL_NAVEGACION es: %', v_resultado_proc;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ocurrió un error al llamar al procedimiento: %', SQLERRM;
END $$ LANGUAGE plpgsql;


select count(*) from historial_navegacion where linea_id = 9;
select * from lineas_telefonicas where numero_telefono='70070007';
SELECT * FROM lineas_paquetes WHERE linea_id=9 AND paquete_id IN (1,2, 4);


--Pregunta 5
select * from lineas_paquetes where linea_id = 1 order by paquete_id;
select paquete_id from paquetes group by paquete_id;

create or replace procedure pregunta5(
    in lt_telefono numeric,
    in p_nombre varchar(200)
)
    language plpgsql
as $$
declare
    lt_linea_id integer;
    lp_id integer;
    lp_estado varchar(200);
begin
    select linea_id into lt_linea_id
    from lineas_telefonicas
    where numero_telefono = lt_telefono;

    select paquete_id into lp_id
    from paquetes
    where nombre_paquete = p_nombre;

    select estado_paquete into lp_estado
    from lineas_paquetes
    where linea_id = lt_linea_id and paquete_id = lp_id
    limit 1;

    if lp_estado <> 'Activo' then
        insert into lineas_paquetes(
            linea_id, paquete_id, fecha_activacion, fecha_expiracion,
            minutos_restantes, sms_restantes, megas_restantes, estado_paquete)
        values (
                   lt_linea_id, lp_id, now(), now(),
                   0, 0, 0, 'Activo');
    end if;
end;
$$;

DO $$
DECLARE
    -- Declara variables para los parámetros de entrada
    v_linea_param       integer      := 9;
    v_paquete_id        integer      := 1;
    v_resultado_proc     VARCHAR;
BEGIN
    CALL pregunta5(
        p_linea   => v_linea_param,
        p_paquete => v_paquete_id,
        result    => v_resultado_proc  -- Aquí se asignará el valor de salida
    );
    RAISE NOTICE 'El resultado del procedimiento HISTORIAL_NAVEGACION es: %', v_resultado_proc;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ocurrió un error al llamar al procedimiento: %', SQLERRM;
END $$ LANGUAGE plpgsql;
