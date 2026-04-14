-------------------------------
DO
$$
    DECLARE
        v_estudiantes_activos1 INT;
        v_estudiantes_id       INT     := 1;
        v_carrera_target       VARCHAR := 'SIS';
    BEGIN
        -----
        SELECT COUNT(*)
        INTO v_estudiantes_activos1
        FROM estudiante e
                 INNER JOIN carrera c ON e.id_carrera = c.id_carrera
        WHERE c.sigla = v_carrera_target;

        IF v_estudiantes_activos1 > 0 THEN
            RAISE NOTICE 'Hay % estudiantes activos en la carrera %.',
                v_estudiantes_activos1, v_carrera_target;

            RAISE INFO 'Hay % estudiantes activos en la carrera %.',
                v_estudiantes_activos1, v_carrera_target;
        ELSE
            RAISE WARNING 'No se encontraron estudiantes en la carrera %.',
                v_carrera_target;
        END IF;
-------
    END
$$ LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE INSCRIBI_MATERIA(IN P_NOMBRE_ESTUDIANTE VARCHAR, IN P_MATERIA VARCHAR,
                                             INOUT P_RESULT VARCHAR) AS
$$
DECLARE

    V_CLASE_ID      INT;
    V_ESTUDIANTE_ID INT := NULL;
BEGIN
    -----

    SELECT c.id_clase
    INTO V_CLASE_ID
    FROM clase c
             INNER JOIN materia m ON c.id_materia = m.id_materia
    WHERE sigla = P_MATERIA
    ORDER BY c.id_clase DESC
    LIMIT 1;

    IF V_CLASE_ID IS NULL THEN
        RAISE NOTICE 'No hay una clase disponible para la materia %.',
            P_MATERIA;
        RETURN;
    END IF;

    SELECT id_estudiante INTO V_ESTUDIANTE_ID FROM estudiante WHERE nombre_completo = P_NOMBRE_ESTUDIANTE;

    IF V_ESTUDIANTE_ID IS NULL THEN
        RAISE NOTICE 'No existe un estudiante con nombre %.',
            P_NOMBRE_ESTUDIANTE;
        RETURN;
    END IF;

    IF (SELECT EXISTS(SELECT 1
                      FROM inscripcion I
                      WHERE id_estudiante = V_ESTUDIANTE_ID
                        AND id_clase = V_CLASE_ID) = true) THEN
        RAISE NOTICE 'El estudiante ya está incrito en la materia %.',
            V_MATERIA;
        RETURN;
    END IF;


    INSERT INTO inscripcion (ID_ESTUDIANTE, ID_CLASE)
    VALUES (V_ESTUDIANTE_ID, V_CLASE_ID);

    P_RESULT := CONCAT('El estudiante INSTRITO CLASE %.  ESTUDIANTE %',
                       V_CLASE_ID, V_ESTUDIANTE_ID);
-------
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION F_PRECIO(P_PRODUCTO_ID INTEGER)
    RETURNS NUMERIC AS
$$
DECLARE
    V_PRECIO NUMERIC;
BEGIN
    SELECT price INTO V_PRECIO FROM product WHERE id = P_PRODUCTO_ID;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Producto con ID % no encontrado', P_PRODUCTO_ID;
    END IF;
    RETURN V_PRECIO;
END
$$ LANGUAGE plpgsql;


SELECT F_PRECIO(2);

DO
$$
    DECLARE
        V_RESULT VARCHAR;
    BEGIN
        call INSCRIBI_MATERIA('Ricardo Laredo', 'DADAS', V_RESULT);
        RAISE NOTICE 'Resultado %', V_RESULT;
    END
$$ LANGUAGE plpgsql;
