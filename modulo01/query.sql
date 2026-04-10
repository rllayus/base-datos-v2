SELECT a.id as producto_Id, a.nombre_servicio as Producto
FROM articulo a LEFT JOIN detalle_almacen da
ON(a.id=da.articulo_id)
WHERE da.articulo_id IS NULL;

--
SELECT count(*) from articulo
WHERE nombre_servicio= 'Zapato';



SELECT count(*) from detalle_almacen WHERE articulo_id=1;

SELECT EXISTS(SELECT 1 from detalle_almacen WHERE articulo_id=1);

SELECT * FROM articulo a
WHERE  (SELECT count(*) from detalle_almacen WHERE articulo_id=a.id)=0;


SELECT * FROM(

SELECT a.nombre_servicio as producto, sum(dv.cantidad) as cantidad FROM detalle_venta dv INNER JOIN articulo a
ON (dv.articulo_id=a.id)
GROUP BY a.nombre_servicio
--ORDER BY cantidad DESC

)WHERE cantidad > 1967 order by cantidad desc ;

---
SELECT a.nombre_servicio as producto, sum(dv.cantidad) as cantidad FROM detalle_venta dv INNER JOIN articulo a
ON (dv.articulo_id=a.id)
GROUP BY a.nombre_servicio
--ORDER BY cantidad DESC
HAVING sum(dv.cantidad) >1967;



SELECT *
FROM articulo a
WHERE NOT EXISTS (
    SELECT 1
    FROM detalle_almacen ad
    WHERE ad.articulo_id = a.id
);
----

SELECT * FROM articulo