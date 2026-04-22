-- 1. Crea la función que será ejecutada por el trigger

CREATE OR REPLACE FUNCTION FUN_DESCONTAR_SALDO()
    RETURNS TRIGGER AS
$$
DECLARE

BEGIN
    IF (new.duracion_segundos IS NOT NULL) THEN
        UPDATE bolsas_saldo
        SET saldo_minutos_voz = saldo_minutos_voz - NEW.DURACION_SEGUNDOS
        WHERE id_abonado = NEW.ID_ABONADO;
    END IF;

    RETURN NEW; -- Es importante retornar NEW en un trigger AFTER
END;
$$ LANGUAGE plpgsql;
---

-- 2. Crea el trigger que llama a la función
CREATE OR REPLACE TRIGGER TGR_SALDO_VOS
    BEFORE INSERT
    ON llamadas_voz
    --AFTER INSERT ON llamadas_voz
    FOR EACH ROW
EXECUTE FUNCTION FUN_DESCONTAR_SALDO();


INSERT INTO llamadas_voz(ID_ABONADO, NUMERO_DESTINO, HORA_INICIO, TIPO_LLAMADA)
VALUES ('04501a16-1ad9-4f9a-ab13-be647d528c4d', '76341505', now(), 'DASDSA');


SELECT *
FROM bolsas_saldo
WHERE id_abonado = '04501a16-1ad9-4f9a-ab13-be647d528c4d';

