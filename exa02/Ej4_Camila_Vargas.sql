-- Camila Vargas Flores

-- PROCEDIMIENTO ALMACENADO
-- INSERT HISTORIAL_NAVEGACION
-- PARAMETROS ID LINEA
-- IF LINEA TIENE PAQUETE 1,2,4 DESCONTAR SALDO PAQUETE (MEGAS RESTANTES)

-- PROBAR CON UN INSERT

-- INSERT INTO public.historial_navegacion (navegacion_id, linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida)
-- VALUES (DEFAULT, 16, '2025-06-11 09:38:47.000000', 100.00,
--         '172.217.10.14', 'tiktok.com');
--
-- SELECT lp.linea_paquete_id as id,lp.linea_id, lp.paquete_id, lp.megas_restantes
-- FROM lineas_paquetes lp where linea_id = 17 and paquete_id in(1,2,4);
--
--
-- UPDATE public.lineas_paquetes
-- SET megas_restantes = megas_restantes - 2.00
-- WHERE linea_id = 16 and paquete_id in(1,2,4);


-- TODO OBTENER CADA ID LINEA PAQUETE LIMIT 1, CON ESE ID ACTUALIZAR SUS MEGAS RESTANTES
CREATE OR REPLACE FUNCTION descontar_megas(linea integer,megas numeric(10, 2) )
    RETURNS void AS $$
DECLARE
    v_linea_id_1 integer;
    v_linea_id_2 integer;
    v_linea_id_4 integer;

BEGIN

    INSERT INTO public.historial_navegacion (navegacion_id, linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida)
    VALUES (DEFAULT, linea, '2025-06-11 09:38:47.000000', megas,
            '172.217.10.14', 'tiktok.com');

    SELECT lp.linea_paquete_id into v_linea_id_1 from lineas_paquetes lp where lp.paquete_id =1 limit 1;
    SELECT lp.linea_paquete_id into v_linea_id_2 from lineas_paquetes lp where lp.paquete_id =2 limit 1;
    SELECT lp.linea_paquete_id into v_linea_id_4 from lineas_paquetes lp where lp.paquete_id =4 limit 1;


    --     IF v_linea_id_1 IS NOT NULL THEN
--         UPDATE public.lineas_paquetes lp
--         SET megas_restantes = megas_restantes - megas
--         WHERE lp.linea_paquete_id = v_linea_id_1;
--
--
--     END IF;

    UPDATE public.lineas_paquetes
    SET megas_restantes = megas_restantes - megas
    WHERE linea_id = linea and paquete_id in(1,2,4);

END;
$$ LANGUAGE plpgsql;

select descontar_megas(9,2000);

select count(*) from historial_navegacion where linea_id = 9;
select * from lineas_telefonicas where numero_telefono='70070007';
SELECT * FROM lineas_paquetes WHERE linea_id=9 AND paquete_id IN (1,2, 4);
