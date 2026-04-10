------------------------
DO $$
DECLARE
    v_estudiantes_activos INT;
    v_carrera_target VARCHAR := 'SIS';
BEGIN

    SELECT COUNT(*) INTO v_estudiantes_activos
    FROM estudiante e
    INNER JOIN carrera c ON e.id_carrera = c.id_carrera
    WHERE c.sigla = v_carrera_target;

    IF v_estudiantes_activos > 0 THEN
        RAISE NOTICE 'Hay % estudiantes activos en la carrera %.', v_estudiantes_activos, v_carrera_target;
    ELSE
        RAISE WARNING 'No se encontraron estudiantes en la carrera %.', v_carrera_target;
    END IF;

END
$$ LANGUAGE plpgsql;