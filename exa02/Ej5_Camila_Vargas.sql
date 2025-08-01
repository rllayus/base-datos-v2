-- Camila Vargas Flores



-- PROCEDMIENTO ALMACENADO
-- INSERTAR LINEA PAQUETES
-- PARAMETROS CLIENTE ID, PAQUETE_ID

-- TRIGGER CADA VEZ QUE SE HACE UNA INSERCION A LINEA PAQUETE VERIFICAR SI YA EXISTE
-- SELECT FROM LINEA PAQEUTE WHERE ID_PAQUETE =  AND NUMERO TELEFONO =

-- SELECT lp.linea_paquete_id as id, lt.numero_telefono as telefono, lp.paquete_id, p.activo
-- FROM lineas_telefonicas lt
--     inner join public.lineas_paquetes lp on lt.linea_id = lp.linea_id
--     inner join public.paquetes p on p.paquete_id = lp.paquete_id
-- WHERE lp.paquete_id = 1 AND lt.numero_telefono ='70130013'
-- AND p.activo =true;
--
-- INSERT INTO public.lineas_paquetes (linea_paquete_id, linea_id, paquete_id, fecha_activacion, fecha_expiracion, minutos_restantes, sms_restantes, megas_restantes, estado_paquete)
-- VALUES (DEFAULT, 16, 1, '2025-06-12 09:29:27.000000', '2025-06-12 09:29:32.000000', 50, 20, 2044.00, 'Activo');

CREATE OR REPLACE FUNCTION insertar_linea_paquete(telefono varchar, paquete integer)
    RETURNS VOID AS $$
DECLARE
    v_linea_id integer;
BEGIN

    SELECT  lt.linea_id
    INTO v_linea_id
    FROM lineas_telefonicas lt WHERE numero_telefono = telefono LIMIT 1;


    IF v_linea_id IS NULL THEN
        RAISE EXCEPTION 'No existe este telefono % ', telefono;
    ELSE
        INSERT INTO public.lineas_paquetes (linea_paquete_id, linea_id, paquete_id, fecha_activacion, fecha_expiracion, minutos_restantes, sms_restantes, megas_restantes, estado_paquete)
        VALUES (DEFAULT, v_linea_id, paquete, '2025-06-12 09:29:27.000000', '2025-06-12 09:29:32.000000', 50, 20, 2044.00, 'Activo');

    END IF;
END;
$$ LANGUAGE plpgsql;

select insertar_linea_paquete('70130013',6);






CREATE OR REPLACE FUNCTION verificar_paquete()
    RETURNS TRIGGER AS $$
DECLARE
    v_linea_paquete text;
BEGIN

    SELECT  linea_paquete_id
    INTO v_linea_paquete
    FROM lineas_paquetes lp
             inner join public.paquetes p on p.paquete_id = lp.paquete_id
    WHERE lp.paquete_id = NEW.paquete_id AND lp.linea_id =NEW.linea_id
      AND p.activo =true;

    IF v_linea_paquete IS NOT NULL THEN
        RAISE EXCEPTION 'Ya existe este paquete en linea paquete %', v_linea_paquete;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE  TRIGGER trg_verificar_paquete_existente
    BEFORE INSERT  ON lineas_paquetes
    FOR EACH ROW
EXECUTE PROCEDURE verificar_paquete();

