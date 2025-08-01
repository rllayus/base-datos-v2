CREATE OR REPLACE VIEW vista_ejercicio3 AS
SELECT c.nombre, lt.numero_telefono as telefono_cliente, hl.fecha_hora_inicio, hl.duracion_segundos, hl.costo_llamada
FROM clientes c
         INNER JOIN public.lineas_telefonicas lt on c.cliente_id = lt.cliente_id
         INNER JOIN public.historial_llamadas hl on lt.linea_id = hl.linea_origen_id
WHERE hl.tipo_llamada = 'Saliente'
  AND lt.numero_telefono = '70140014';

select count(*) from vista_ejercicio3;

CREATE INDEX linea_telefonica_cliente ON lineas_telefonicas (cliente_id);
create index historial_llamadas_origen on historial_llamadas (linea_origen_id);
create index historial_llamadas_tipo on historial_llamadas (tipo_llamada);


CREATE OR REPLACE PROCEDURE registrar_historial_navegacion(
    IN p_linea_id INT,
    IN p_megabytes_consumidos DECIMAL(10,2),
    IN p_ip_destino VARCHAR(45),
    IN p_url_accedida TEXT,
    INOUT result character varying
)
    LANGUAGE plpgsql
AS $$
DECLARE
v_paquete_activo RECORD;
    v_saldo_actual DECIMAL(10,2);
    v_tipo_contrato VARCHAR(10);
BEGIN
SELECT tipo_contrato, saldo_actual
INTO v_tipo_contrato, v_saldo_actual
FROM lineas_telefonicas
WHERE linea_id = p_linea_id;

IF NOT FOUND THEN
        result := 'La línea telefónica no existe';
        RETURN;
END IF;

SELECT lp.linea_paquete_id,
       lp.megas_restantes,
       lp.paquete_id
INTO v_paquete_activo
FROM lineas_paquetes lp
WHERE lp.linea_id = p_linea_id
  AND lp.megas_restantes > 0
  AND paquete_id IN (1,2,4)
ORDER BY lp.paquete_id DESC
    LIMIT 1;

INSERT INTO historial_navegacion (
    linea_id,
    fecha_hora_inicio,
    megabytes_consumidos,
    ip_destino,
    url_accedida
) VALUES (
             p_linea_id,
             now(),
             p_megabytes_consumidos,
             p_ip_destino,
             p_url_accedida
         );

IF v_paquete_activo IS NOT NULL THEN
        IF v_paquete_activo.megas_restantes < p_megabytes_consumidos THEN
            result := 'Megas insuficientes en el paquete';
            RETURN;
END IF;

UPDATE lineas_paquetes
SET megas_restantes = megas_restantes - p_megabytes_consumidos,
    estado_paquete = CASE
                         WHEN (megas_restantes - p_megabytes_consumidos) <= 0 THEN 'Consumido'
                         ELSE estado_paquete
        END
WHERE linea_paquete_id = v_paquete_activo.linea_paquete_id;
ELSE
        result := 'No tiene paquete con megas;';
        RETURN;
END IF;
END;
$$;



CREATE OR REPLACE PROCEDURE comprar_paquete_datos(
    IN p_linea_id INT,
    IN p_paquete_id INT,
    INOUT result character varying
)
    LANGUAGE plpgsql
AS $$
DECLARE
v_linea RECORD;
    v_paquete RECORD;
    v_paquete_activo RECORD;
BEGIN
SELECT tipo_contrato, saldo_actual, estado_linea
INTO v_linea
FROM lineas_telefonicas
WHERE linea_id = p_linea_id;

IF NOT FOUND THEN
        result := 'La línea telefónica no existe';
END IF;

    IF v_linea.estado_linea != 'Activa' THEN
        result := 'La línea no está activa';
END IF;

SELECT *
INTO v_paquete
FROM paquetes
WHERE paquete_id = p_paquete_id;

IF NOT FOUND THEN
        result := 'El paquete no existe';
END IF;

    IF NOT v_paquete.activo THEN
        result := 'El paquete no está disponible para la venta';
END IF;

SELECT lp.linea_paquete_id, lp.fecha_expiracion, p.nombre_paquete
INTO v_paquete_activo
FROM lineas_paquetes lp
         JOIN paquetes p ON p.paquete_id = lp.paquete_id
WHERE lp.linea_id = p_linea_id
  AND lp.paquete_id = p_paquete_id
  AND lp.estado_paquete = 'Activo'
  AND lp.megas_restantes > 0;

IF FOUND THEN
        result := 'Ya tiene un paquete de datos vigente';
END IF;

    IF v_linea.tipo_contrato = 'Prepago' AND v_linea.saldo_actual < v_paquete.precio THEN
        result := 'Saldo insuficiente.';
END IF;

BEGIN
        IF v_linea.tipo_contrato = 'Prepago' THEN
UPDATE lineas_telefonicas
SET saldo_actual = saldo_actual - v_paquete.precio
WHERE linea_id = p_linea_id;
END IF;

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
             CURRENT_TIMESTAMP,
             CURRENT_TIMESTAMP + (v_paquete.vigencia_dias || ' days')::interval,
             v_paquete.minutos_incluidos,
             v_paquete.sms_incluidos,
             v_paquete.megas_incluidos,
             'Activo'
         );

EXCEPTION
        WHEN OTHERS THEN
            result := 'NOk';
            RETURN ;
END;
END;
$$;



SELECT *
FROM paquetes
WHERE paquete_id = 4;

CALL comprar_paquete_datos(9, 2, null);
SELECT * from lineas_paquetes where linea_id=9 and paquete_id=2;