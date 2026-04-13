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



DO
$$
    DECLARE
        V_ESTUDIANTE_NOMBRE VARCHAR := 'ESTUDIANTE FANTASMA UNO';
        V_MATERIA           VARCHAR := 'PRG-100';

        V_CLASE_ID          INT;
        V_ESTUDIANTE_ID     INT     := NULL;
    BEGIN
        -----

        SELECT c.id_clase
        INTO V_CLASE_ID
        FROM clase c
                 INNER JOIN materia m ON c.id_materia = m.id_materia
        WHERE sigla = V_MATERIA
        ORDER BY c.id_clase DESC
        LIMIT 1;

        IF V_CLASE_ID IS NULL THEN
            RAISE NOTICE 'No hay una clase disponible para la materia %.',
                V_MATERIA;
            RETURN;
        END IF;

        SELECT id_estudiante INTO V_ESTUDIANTE_ID FROM estudiante WHERE nombre_completo = V_ESTUDIANTE_NOMBRE;

        IF V_ESTUDIANTE_ID IS NULL THEN
            RAISE NOTICE 'No existe un estudiante con nombre %.',
                V_ESTUDIANTE_NOMBRE;
            RETURN;
        END IF;

        IF (SELECT EXISTS(SELECT 1
                              FROM inscripcion I
                              WHERE id_estudiante = V_ESTUDIANTE_ID AND id_clase = V_CLASE_ID) = true)  THEN
            RAISE NOTICE 'El estudiante ya está incrito en la materia %.',
                V_MATERIA;
            RETURN;
        END IF;


        INSERT INTO inscripcion (ID_ESTUDIANTE, ID_CLASE)
        VALUES (V_ESTUDIANTE_ID, V_CLASE_ID);

        RAISE NOTICE 'El estudiante INSTRITO CLASE %.  ESTUDIANTE %',
                V_CLASE_ID, V_ESTUDIANTE_ID;
-------
    END
$$ LANGUAGE plpgsql;

-----------------------
