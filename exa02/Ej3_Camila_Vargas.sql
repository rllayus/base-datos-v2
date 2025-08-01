-- Camila Vargas

-- Escriba una vista que muestre
-- nombre cliente, numero telefono, fecha de la llamada, duracion, costo
-- Donde tipo_llamada sea igual a "Saliente"
-- Escribir indices si los necesitara

-- Select c.nombre, lt.numero_telefono telefono ,
--        hl.fecha_hora_inicio fecha, hl.duracion_segundos duracion,
--        hl.costo_llamada costo
--            from clientes c
--                   inner join public.lineas_telefonicas lt on c.cliente_id = lt.cliente_id
--                   inner join public.historial_llamadas hl on lt.linea_id = hl.linea_origen_id
-- where hl.tipo_llamada = 'Saliente';



CREATE INDEX idx_lineas_telefonicas_cliente_id ON lineas_telefonicas(cliente_id);

CREATE INDEX idx_historial_llamadas_linea_origen_id ON historial_llamadas(linea_origen_id);
CREATE INDEX idx_historial_llamadas_tipo_llamada ON historial_llamadas(tipo_llamada);

CREATE VIEW vista_llamadas_salientes AS
Select c.nombre, lt.numero_telefono telefono ,
       hl.fecha_hora_inicio fecha, hl.duracion_segundos duracion,
       hl.costo_llamada costo
from clientes c
         inner join public.lineas_telefonicas lt on c.cliente_id = lt.cliente_id
         inner join public.historial_llamadas hl on lt.linea_id = hl.linea_origen_id
where hl.tipo_llamada = 'Saliente';

SELECT * FROM vista_llamadas_salientes WHERE telefono= '70070007';

