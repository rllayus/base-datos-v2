SELECT
    datname,
    usename,
    client_addr,
    backend_start
FROM
    pg_stat_activity
WHERE
    datid = (SELECT oid FROM pg_database WHERE datname = current_database())
    AND usename <> 'postgres' -- Opcional: Excluir al usuario postgres si no te interesa
ORDER BY
    backend_start;

SELECT *
FROM
    pg_stat_activity
WHERE
    datid = (SELECT oid FROM pg_database WHERE datname = current_database())
    AND usename <> 'postgres' -- Opcional: Excluir al usuario postgres si no te interesa
ORDER BY
    backend_start;