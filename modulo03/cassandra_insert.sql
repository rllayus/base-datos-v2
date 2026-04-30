--- INSERCIÓN DE PLANES DE SERVICIO (5 registros) ---
INSERT INTO planes_servicio (id_plan, nombre_plan, limite_datos_gb, limite_minutos_voz, limite_sms, costo_mensual, descripcion, esta_activo)
VALUES (3a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d, 'Plan Basico', 5, 200, 500, 10.00, 'Datos y llamadas limitados', true);
INSERT INTO planes_servicio (id_plan, nombre_plan, limite_datos_gb, limite_minutos_voz, limite_sms, costo_mensual, descripcion, esta_activo)
VALUES (11223344-5566-7788-99aa-bbccddeeff00, 'Plan Estandar', 20, 1000, 2000, 25.00, 'Buen balance de datos y llamadas', true);
INSERT INTO planes_servicio (id_plan, nombre_plan, limite_datos_gb, limite_minutos_voz, limite_sms, costo_mensual, descripcion, esta_activo)
VALUES (abcdef01-2345-6789-abcd-ef0123456789, 'Plan Premium', 100, 5000, 10000, 50.00, 'Datos y llamadas ilimitados', true);
INSERT INTO planes_servicio (id_plan, nombre_plan, limite_datos_gb, limite_minutos_voz, limite_sms, costo_mensual, descripcion, esta_activo)
VALUES (0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5e, 'Plan Solo Datos', 50, 0, 0, 30.00, 'Para usuarios de datos intensivos', true);
INSERT INTO planes_servicio (id_plan, nombre_plan, limite_datos_gb, limite_minutos_voz, limite_sms, costo_mensual, descripcion, esta_activo)
VALUES (f1e2d3c4-b5a6-9d8c-7b6a-5f4e3d2c1b0a, 'Plan Economico', 2, 100, 200, 5.00, 'Plan de bajo costo', true);


INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000001, '59170001001', 'Juan', 'Perez', 'Av. Beni #123', 'Santa Cruz de la Sierra', 'Santa Cruz', '00000', 'juan.perez@example.com', '2024-01-15 10:30:00+0000', 3a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d, 'Plan Basico', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000002, '59171234567', 'Maria', 'Garcia', 'Calle La Paz #456', 'Cochabamba', 'Cochabamba', '00000', 'maria.garcia@example.com', '2024-02-20 14:00:00+0000', 11223344-5566-7788-99aa-bbccddeeff00, 'Plan Estandar', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000003, '59178901234', 'Carlos', 'Sanchez', 'Av. Arce #789', 'La Paz', 'La Paz', '00000', 'carlos.sanchez@example.com', '2024-03-01 09:15:00+0000', abcdef01-2345-6789-abcd-ef0123456789, 'Plan Premium', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000004, '59174445555', 'Ana', 'Lopez', 'Calle Sucre #10', 'Sucre', 'Chuquisaca', '00000', 'ana.lopez@example.com', '2024-04-05 11:00:00+0000', 0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5e, 'Plan Solo Datos', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000005, '59176667777', 'Pedro', 'Ramirez', 'Av. Pando #20', 'Santa Cruz de la Sierra', 'Santa Cruz', '00000', 'pedro.ramirez@example.com', '2024-05-10 16:00:00+0000', 3a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d, 'Plan Basico', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000006, '59178889999', 'Laura', 'Torres', 'Calle Junin #30', 'Tarija', 'Tarija', '00000', 'laura.torres@example.com', '2024-06-01 08:00:00+0000', 11223344-5566-7788-99aa-bbccddeeff00, 'Plan Estandar', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000007, '59171112222', 'Miguel', 'Vargas', 'Av. 6 de Agosto #40', 'Oruro', 'Oruro', '00000', 'miguel.vargas@example.com', '2024-06-10 12:00:00+0000', abcdef01-2345-6789-abcd-ef0123456789, 'Plan Premium', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000008, '59173334444', 'Sofia', 'Rojas', 'Calle Potosi #50', 'Potosi', 'Potosi', '00000', 'sofia.rojas@example.com', '2024-06-15 09:30:00+0000', 0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5e, 'Plan Solo Datos', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000009, '59175556666', 'Diego', 'Castro', 'Av. Busch #60', 'Santa Cruz de la Sierra', 'Santa Cruz', '00000', 'diego.castro@example.com', '2024-06-20 10:00:00+0000', f1e2d3c4-b5a6-9d8c-7b6a-5f4e3d2c1b0a, 'Plan Economico', true);
INSERT INTO abonados (id_abonado, numero_telefono, nombre, apellido, direccion, ciudad, departamento, codigo_postal, correo_electronico, fecha_registro, id_plan, nombre_plan, esta_activo)
VALUES (00000000-0000-0000-0000-000000000010, '59177778888', 'Valeria', 'Flores', 'Calle Bolivar #70', 'Sucre', 'Chuquisaca', '00000', 'valeria.flores@example.com', '2024-06-22 14:00:00+0000', 11223344-5566-7788-99aa-bbccddeeff00, 'Plan Estandar', true);


INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000001, uuid(), '2024-06-24 09:00:00+0000', '2024-06-24 09:05:00+0000', '59170001001', '59171112233', 300, 'saliente', 0.15);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000002, uuid(), '2024-06-24 10:15:00+0000', '2024-06-24 10:17:30+0000', '59179876543', '59171234567', 150, 'entrante', 0.00);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000003, uuid(), '2024-06-24 11:30:00+0000', '2024-06-24 11:35:00+0000', '59178901234', '59170000000', 300, 'saliente', 0.20);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000004, uuid(), '2024-06-24 12:45:00+0000', '2024-06-24 12:46:00+0000', '59174445555', '59171010101', 60, 'saliente', 0.05);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000005, uuid(), '2024-06-24 13:00:00+0000', '2024-06-24 13:08:00+0000', '59176667777', '59172223344', 480, 'saliente', 0.25);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000006, uuid(), '2024-06-24 14:00:00+0000', '2024-06-24 14:01:00+0000', '59175556666', '59178889999', 60, 'entrante', 0.00);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000007, uuid(), '2024-06-24 15:00:00+0000', '2024-06-24 15:10:00+0000', '59171112222', '59170001001', 600, 'saliente', 0.30);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000008, uuid(), '2024-06-24 16:00:00+0000', '2024-06-24 16:02:00+0000', '59173334444', '59179998888', 120, 'saliente', 0.10);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000009, uuid(), '2024-06-24 17:00:00+0000', '2024-06-24 17:03:00+0000', '59175556666', '59171234567', 180, 'saliente', 0.08);
INSERT INTO llamadas_voz (id_abonado, id_llamada, hora_inicio, hora_fin, numero_origen, numero_destino, duracion_segundos, tipo_llamada, costo)
VALUES (00000000-0000-0000-0000-000000000010, uuid(), '2024-06-24 18:00:00+0000', '2024-06-24 18:05:00+0000', '59177778888', '59170001001', 300, 'saliente', 0.18);


INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000001, uuid(), '2024-06-24 09:30:00+0000', 52428800, '192.168.1.1', '4G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000002, uuid(), '2024-06-24 10:45:00+0000', 104857600, '192.168.1.2', '5G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000003, uuid(), '2024-06-24 11:50:00+0000', 209715200, '192.168.1.3', '5G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000004, uuid(), '2024-06-24 12:55:00+0000', 26214400, '192.168.1.4', '4G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000005, uuid(), '2024-06-24 13:15:00+0000', 78643200, '192.168.1.5', '4G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000006, uuid(), '2024-06-24 14:05:00+0000', 157286400, '192.168.1.6', '5G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000007, uuid(), '2024-06-24 15:10:00+0000', 314572800, '192.168.1.7', '5G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000008, uuid(), '2024-06-24 16:05:00+0000', 41943040, '192.168.1.8', '4G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000009, uuid(), '2024-06-24 17:05:00+0000', 62914560, '192.168.1.9', '4G');
INSERT INTO uso_datos (id_abonado, id_uso, hora_uso, volumen_bytes, direccion_ip, tipo_red)
VALUES (00000000-0000-0000-0000-000000000010, uuid(), '2024-06-24 18:05:00+0000', 104857600, '192.168.1.10', '5G');


INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000001, uuid(), '2024-06-24 09:10:00+0000', '59170001001', '59171112233', 'SMS', 'enviado', 'Saludos!');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000002, uuid(), '2024-06-24 10:20:00+0000', '59179876543', '59171234567', 'SMS', 'recibido', 'Ok, nos vemos.');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000003, uuid(), '2024-06-24 11:40:00+0000', '59178901234', '59170000000', 'MMS', 'enviado', NULL);
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000004, uuid(), '2024-06-24 12:50:00+0000', '59174445555', '59171010101', 'SMS', 'enviado', 'Llego tarde.');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000005, uuid(), '2024-06-24 13:05:00+0000', '59172223344', '59176667777', 'SMS', 'recibido', 'Entendido.');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000006, uuid(), '2024-06-24 14:10:00+0000', '59178889999', '59175556666', 'SMS', 'enviado', 'Estoy en camino.');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000007, uuid(), '2024-06-24 15:15:00+0000', '59170001001', '59171112222', 'SMS', 'recibido', 'Gracias por la info.');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000008, uuid(), '2024-06-24 16:10:00+0000', '59173334444', '59179998888', 'SMS', 'enviado', 'Confirmado.');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000009, uuid(), '2024-06-24 17:10:00+0000', '59171234567', '59175556666', 'SMS', 'recibido', 'De acuerdo.');
INSERT INTO mensajes (id_abonado, id_mensaje, hora_mensaje, numero_origen, numero_destino, tipo_mensaje, direccion, texto_mensaje)
VALUES (00000000-0000-0000-0000-000000000010, uuid(), '2024-06-24 18:10:00+0000', '59177778888', '59170001001', 'SMS', 'enviado', 'Todo listo.');

--- INSERCIÓN DE FACTURAS (10 registros) ---
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000001, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 12.50, true, '2024-06-10 09:00:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000002, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 28.75, false, null);
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000003, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 55.00, true, '2024-06-05 10:00:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000004, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 32.00, true, '2024-06-12 11:00:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000005, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 15.00, true, '2024-06-08 14:00:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000006, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 27.00, true, '2024-06-15 16:00:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000007, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 58.00, true, '2024-06-03 09:30:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000008, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 33.50, true, '2024-06-07 10:00:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000009, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 7.00, true, '2024-06-11 11:30:00+0000');
INSERT INTO facturas (id_abonado, id_factura, fecha_emision, periodo_facturacion_inicio, periodo_facturacion_fin, monto_total, esta_pagada, fecha_pago)
VALUES (00000000-0000-0000-0000-000000000010, uuid(), '2024-06-01 00:00:00+0000', '2024-05-01 00:00:00+0000', '2024-05-31 23:59:59+0000', 30.00, true, '2024-06-14 15:00:00+0000');