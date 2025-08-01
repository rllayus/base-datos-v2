-- 1. Crea la función que será ejecutada por el trigger

CREATE OR REPLACE FUNCTION FUN_DESCONTAR_STOCK()
    RETURNS TRIGGER AS $$
DECLARE
    V_CANTIDAD_PLATO INTEGER;
BEGIN
    SELECT cantidad_plato
    INTO V_CANTIDAD_PLATO
    FROM platos WHERE plato_id=NEW.plato_id;

    IF V_CANTIDAD_PLATO > NEW.cantidad THEN
        UPDATE platos
        SET cantidad_plato= cantidad_plato - NEW.cantidad
        WHERE plato_id=NEW.plato_id;
    END IF;

    RETURN NEW; -- Es importante retornar NEW en un trigger AFTER
END;
$$ LANGUAGE plpgsql;

---

-- 2. Crea el trigger que llama a la función
CREATE TRIGGER TGR_DESCONTAR_STOCK
    --BEFORE
    AFTER INSERT ON detalle_venta
    FOR EACH ROW
EXECUTE FUNCTION FUN_DESCONTAR_STOCK();



