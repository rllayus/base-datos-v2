
CREATE TABLE IF NOT EXISTS abonados (
    id_abonado UUID,            -- ID único del abonado (UUID para buena distribución de datos).
    numero_telefono TEXT,       -- Número de teléfono principal del abonado.
    nombre TEXT,
    apellido TEXT,
    direccion TEXT,
    ciudad TEXT,
    departamento TEXT,
    codigo_postal TEXT,
    correo_electronico TEXT,
    fecha_registro TIMESTAMP,
    id_plan UUID,               -- ID del plan de servicio actual del abonado.
    nombre_plan TEXT,           -- Nombre del plan (desnormalizado para consultas rápidas).
    esta_activo BOOLEAN,
    PRIMARY KEY (id_abonado)    -- La clave de partición es el ID del abonado.
);

CREATE INDEX IF NOT EXISTS ON abonados (numero_telefono);


CREATE TABLE IF NOT EXISTS llamadas_voz (
    id_abonado UUID,            -- ID del abonado relacionado con la llamada.
    id_llamada UUID,            -- ID único de la llamada.
    hora_inicio TIMESTAMP,      -- Hora de inicio de la llamada (parte de la clave de clúster para ordenar).
    hora_fin TIMESTAMP,
    numero_origen TEXT,         -- Número desde donde se originó la llamada.
    numero_destino TEXT,        -- Número al que se dirigió la llamada.
    duracion_segundos INT,      -- Duración de la llamada en segundos.
    tipo_llamada TEXT,          -- 'saliente', 'entrante', 'perdida'.
    costo DECIMAL,              -- Costo de la llamada.
    PRIMARY KEY ((id_abonado, hora_inicio), id_llamada) -- Particiona por abonado y luego por fecha/hora de inicio.
                                                        -- id_llamada como parte de la clave de clúster para unicidad y orden.
);


CREATE TABLE IF NOT EXISTS uso_datos (
    id_abonado UUID,            -- ID del abonado que usó los datos.
    id_uso UUID,                -- ID único del registro de uso de datos.
    hora_uso TIMESTAMP,         -- Marca de tiempo del registro de uso (parte de la clave de clúster).
    volumen_bytes BIGINT,       -- Volumen de datos usado en bytes.
    direccion_ip INET,          -- Dirección IP asignada durante el uso.
    tipo_red TEXT,              -- Por ejemplo: '4G', '5G', 'Wi-Fi'.
    PRIMARY KEY ((id_abonado, hora_uso), id_uso) -- Particiona por abonado y hora de uso.
) ;


CREATE TABLE IF NOT EXISTS mensajes (
    id_abonado UUID,            -- ID del abonado.
    id_mensaje UUID,            -- ID único del mensaje.
    hora_mensaje TIMESTAMP,     -- Hora del mensaje (parte de la clave de clúster).
    numero_origen TEXT,
    numero_destino TEXT,
    tipo_mensaje TEXT,          -- 'SMS', 'MMS'.
    direccion TEXT,             -- 'enviado', 'recibido'.
    texto_mensaje TEXT,         -- Contenido del mensaje (opcional, considera el tamaño si es muy grande).
    PRIMARY KEY ((id_abonado, hora_mensaje), id_mensaje) -- Particiona por abonado y hora del mensaje.
) ;


CREATE TABLE IF NOT EXISTS planes_servicio (
    id_plan UUID,               -- ID único del plan.
    nombre_plan TEXT,
    limite_datos_gb INT,        -- Límite de datos en Gigabytes.
    limite_minutos_voz INT,     -- Límite de minutos de voz.
    limite_sms INT,             -- Límite de SMS.
    costo_mensual DECIMAL,
    descripcion TEXT,
    esta_activo BOOLEAN,
    PRIMARY KEY (id_plan)       -- La clave de partición es el ID del plan.
);


CREATE TABLE IF NOT EXISTS facturas (
    id_abonado UUID,            -- ID del abonado.
    id_factura UUID,            -- ID único de la factura.
    fecha_emision TIMESTAMP,    -- Fecha de emisión de la factura (parte de la clave de clúster).
    periodo_facturacion_inicio TIMESTAMP,
    periodo_facturacion_fin TIMESTAMP,
    monto_total DECIMAL,
    esta_pagada BOOLEAN,
    fecha_pago TIMESTAMP,
    PRIMARY KEY ((id_abonado, fecha_emision), id_factura) -- Particiona por abonado y fecha de emisión.
) ;