SELECT count(*) FROM clientes;
SELECT count(*) FROM historial_llamadas;
SELECT count(*) FROM historial_navegacion;
SELECT count(*) FROM lineas_paquetes;
SELECT count(*) FROM lineas_telefonicas;
SELECT count(*) FROM paquetes;


/*
 Pregunta 3: Escriba una vista que muestre nombre del cliente, numero de telefono, fecha de la llamada, duración y costos
 de las llamadas cuyo tipo_llamada sea igual a Saliente.
 Debe asegurarse de escribir de igual manera sus indices si es que los necesitara.
 */
-- Vista
CREATE OR REPLACE VIEW llamadas_salientes AS
SELECT cl.nombre nombre_cliente, lt.numero_telefono as numero_telefono,
       hl.fecha_hora_inicio as fecha_llamada, hl.duracion_segundos as duracion, hl.costo_llamada as costo
FROM clientes cl
         INNER JOIN lineas_telefonicas lt
                    ON cl.cliente_id= lt.cliente_id
         INNER JOIN historial_llamadas hl
                    ON lt.linea_id = hl.linea_origen_id
WHERE hl.tipo_llamada = 'Saliente' AND lt.numero_telefono= '70090009'; --Numero de Saul Matny

SELECT * FROM llamadas_salientes;

CREATE INDEX IF NOT EXISTS idx_lineas_cliente
    ON lineas_telefonicas(cliente_id);

CREATE INDEX IF NOT EXISTS idx_hist_llam_linea_origen
    ON historial_llamadas(linea_origen_id);

CREATE INDEX IF NOT EXISTS idx_hist_llam_tipo
    ON historial_llamadas(tipo_llamada);

SELECT count(*) from llamadas_salientes;



/* 4. Escriba un procedimiento almacenado para registrar el historial de navegaci[on de una línea,
 tomando en cuenta si la línea tiene comprado un paquete con ID 1, 2 o 4 se debe hacer un descuento del saldo de paquete

 */

DROP PROCEDURE reg_hist_nav;

CREATE OR REPLACE PROCEDURE reg_hist_nav(
    IN p_linea_id integer,
    IN p_fecha_hora_inicio timestamp,
    IN p_megabytes_consumidos numeric(10,2),
    IN p_ip_destino VARCHAR,
    IN p_url_accedida TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_paquete_id INTEGER;
    v_megas_restantes NUMERIC(10,2);
BEGIN

    INSERT INTO historial_navegacion (linea_id, fecha_hora_inicio, megabytes_consumidos, ip_destino, url_accedida)
    VALUES (
               p_linea_id, p_fecha_hora_inicio, p_megabytes_consumidos,
               p_ip_destino, p_url_accedida
           );

    SELECT paquete_id, megas_restantes
    INTO v_paquete_id, v_megas_restantes
    FROM lineas_paquetes
    WHERE linea_id = p_linea_id
      AND (paquete_id = 1 OR paquete_id = 2 OR paquete_id = 4)
    ORDER BY linea_paquete_id
    LIMIT 1;

    IF FOUND THEN
        IF v_megas_restantes >= p_megabytes_consumidos THEN
            UPDATE lineas_paquetes
            SET megas_restantes = megas_restantes - p_megabytes_consumidos
            WHERE linea_id = p_linea_id
              AND paquete_id = v_paquete_id;
        ELSE
            RAISE NOTICE 'faltan megas restantes para consumir la cnatidad que quiere';
        END IF;
    ELSE
        RAISE NOTICE 'No se encontro';
    END IF;

END;
$$;


CALL reg_hist_nav(
  9,
  '2025-06-13 14:05:00',
  5000,
  '192.168.0.10',
  'https://example.comjjj/pagina.html'
);


SELECT lp.paquete_id, lp.megas_restantes
FROM lineas_paquetes lp
WHERE linea_id = 9
  AND (paquete_id = 1 OR paquete_id = 2 OR paquete_id = 4)
ORDER BY linea_paquete_id;

/*
2,5120.00
2,5120.00
4,2048.00
1,1024.00
4,2048.00
2,5120.00
2,5120.00
4,2048.00
*/

SELECT * FROM historial_navegacion hn
WHERE hn.linea_id = 9
ORDER BY hn.navegacion_id DESC
LIMIT 10;



/* 5. Escribir un procedimiento almacenado para que un cliente pueda comprar un paquete de datos, considerar que si
 ya tiene el paquete adquirido y esta vigente no debe poder adquirir otro.
 */

 CALL comprar_paquete(
  9,
     2,
  '2025-06-13 14:05:00',
      '2025-06-13 14:05:00',
  100,
  100,
  1000
);

drop procedure comprar_paquete;

CREATE OR REPLACE PROCEDURE comprar_paquete(
    IN p_linea_id          INTEGER,
    IN p_paquete_id        INTEGER,
    IN p_fecha_activacion  TIMESTAMP,
    IN p_fecha_expiracion  TIMESTAMP,
    IN p_minutos_restates INTEGER,
    IN p_sms_restantes INTEGER,
    IN p_megas_totales     NUMERIC(10,2)
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_existe INTEGER;
BEGIN

    SELECT COUNT(*)
    INTO v_existe
    FROM lineas_paquetes
    WHERE linea_id      = p_linea_id
      AND paquete_id    = p_paquete_id
      AND estado_paquete = 'Activo'
      AND CURRENT_TIMESTAMP BETWEEN fecha_activacion AND fecha_expiracion;

    IF v_existe > 0 THEN
        RAISE EXCEPTION 'Ya existe un paquete % vigente para la línea %', p_paquete_id, p_linea_id;
    END IF;

    INSERT INTO lineas_paquetes (linea_id, paquete_id, fecha_activacion, fecha_expiracion,minutos_restantes, sms_restantes, megas_restantes,estado_paquete)
    VALUES (
               p_linea_id,
               p_paquete_id,
               p_fecha_activacion,
               p_fecha_expiracion,
            p_minutos_restates,
            p_sms_restantes,
               p_megas_totales,
               --'activo'
               'Activo'
           );

    RAISE NOTICE 'Paquete comprado con éxito para la línea';
END;
$$;

