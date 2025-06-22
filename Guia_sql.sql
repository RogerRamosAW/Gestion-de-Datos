O--27/8
--EJECICIOS

--Ejercicios practica SQL
/*
1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
igual a $ 1000 ordenado por código de cliente.
*/

SELECT clie_codigo,clie_razon_social
FROM Cliente 
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo

--otra opcion
SELECT c.clie_codigo, c.clie_razon_social
FROM Cliente c
WHERE c.clie_limite_credito >= 1000
ORDER BY 1--COLUMNA 1 --orede ascendente 

/*
2 Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
cantidad vendida.*/

SELECT prod_codigo,prod_detalle
FROM Producto p
INNER JOIN	Item_Factura i ON p.prod_codigo =i.item_producto 
INNER JOIN	factura f ON f.fact_tipo = i.item_tipo 
AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
AND YEAR(fact_fecha) = 2012
GROUP BY p.prod_codigo,p.prod_detalle
ORDER BY SUM(i.item_cantidad) DESC
--porque el sum????

/*
3. Realizar una consulta que muestre código de producto, nombre de producto y el stock
total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
nombre del artículo de menor a mayor.*/

SELECT p.prod_codigo , p.prod_detalle, SUM(ISNULL(s.stoc_cantidad,0)) AS [stock total]
FROM Producto p LEFT OUTER JOIN STOCK s ON p.prod_codigo = s.stoc_producto
GROUP BY p.prod_codigo , p.prod_detalle
ORDER BY 2 --ORDEN POR LA COLUMAN SEUNDA




/*
4 Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.*/

--version ok
SELECT p.prod_codigo, p.prod_detalle,
SUM(ISNULL(c.comp_cantidad,0)) AS [cantidad de articulos componen] 
FROM producto p 
LEFT OUTER JOIN composicion c ON p.prod_codigo = c.comp_producto 
WHERE (SELECT AVG(s.stoc_cantidad) 
FROM stock s 
WHERE p.prod_codigo = s.stoc_producto) > 100
GROUP BY p.prod_codigo, p.prod_detalle

--version porque usaria iner?
Select p.prod_codigo, p.prod_detalle, 
SUM(ISNULL(c.comp_cantidad,0)) AS [cantidad de articulos componen] 
from Producto p 
INNER JOIN Composicion c ON p.prod_codigo = c.comp_producto
Where (select AVG(s.stoc_cantidad) from STOCK s where p.prod_codigo = s.stoc_producto) > 100
GROUP BY p.prod_codigo,p.prod_detalle



/*
5 Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.
.*/

--mio
select P.prod_codigo,p.prod_detalle,
SUM(i.item_cantidad) AS egresos2012 
from Producto P
INNER JOIN Item_Factura i on p.prod_codigo = i.item_producto
inner join Factura f on i.item_numero = f.fact_numero
and i.item_tipo = f.fact_tipo and i.item_sucursal = f.fact_sucursal
where year(f.fact_fecha) = 2012
GROUP BY p.prod_codigo, p.prod_detalle
Having SUM(i.item_cantidad) > 
(SELECT SUM(i2.item_cantidad)
from Item_Factura i2 
inner join Factura f2 on i2.item_numero = f2.fact_numero
and i2.item_tipo = f2.fact_tipo and i2.item_sucursal = f2.fact_sucursal
where year(f2.fact_fecha) = 2011 AND i2.item_producto = p.prod_codigo)

--va el inner join porque si tiene o egresos en 2012 tambien tengo que saberlo 
--la item_cantidad es lo que egreso
/*SELECT p.prod_codigo,p.prod_detalle, SUM(i.item_cantidad) as egresos2012 
FROM Producto p 
INNER JOIN Item_Factura i ON p.prod_codigo =i.item_producto
INNER JOIN Factura f ON f.fact_tipo = i.item_tipo 
AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY p.prod_codigo,p.prod_detalle
*/
/*5 Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.
.*/
SELECT p.prod_codigo, p.prod_detalle, SUM(i.item_cantidad) AS egresos2012 
FROM producto p
INNER JOIN Item_Fatura i ON p.prod_codigo = i.item_producto 
INNER JOIN factura f 
ON f.fact_tipo = i.item_tipo 
AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY p.prod_codigo, p.prod_detalle
HAVING SUM(i.item_cantidad) > (SELECT SUM(i2.item_cantidad) 
FROM Item_Factura i2  
INNER JOIN factura f2 
ON f2.fact_tipo = i2.item_tipo 
AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = i2.item_numero
WHERE YEAR(f2.fact_fecha) = 2011
AND i2.item_producto = p.prod_codigo)


/*
Ejercicio 6
Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.*/

SELECT r.rubr_id, r.rubr_detalle, count(*) as cantidad,
(SELECT SUM(ISNULL(s2.stoc_cantidad,0))
FROM STOCK s2
inner join Producto p2 on s2.stoc_producto = p2.prod_codigo 
where p2.prod_rubro = r.rubr_id  and 
						s2.stoc_cantidad > ( SELECT s3.stoc_cantidad
						FROM STOCK s3 
						where s3.stoc_producto = '00000000'
						and s3.stoc_deposito = '00')) AS StockMayor
select count(r.rubr_id)
FROM Rubro r
left join Producto p on r.rubr_id = p.prod_rubro
GROUP BY r.rubr_id, r.rubr_detalle

--EL STOCK PARA EL RUBRO
SELECT SUM(ISNULL(s2.stoc_cantidad,0))
FROM STOCK s2
inner join Producto p2 on s2.stoc_producto = p2.prod_codigo 
where p2.prod_rubro = '0001'
and s2.stoc_cantidad > ( SELECT s3.stoc_cantidad
FROM STOCK s3 
where s3.stoc_producto = '00000000' and s3.stoc_deposito = '00')

--el stock particular
SELECT s3.stoc_cantidad
FROM STOCK s3 
where s3.stoc_producto = '00000000' and s3.stoc_deposito = '00'
-------------
SELECT r.rubr_id, r.rubr_detalle, COUNT(*) as Cantidad,
(SELECT SUM(ISNULL(s2.stoc_cantidad,0)) 
FROM stock s2
INNER JOIN producto p2 ON s2.stoc_producto = p2.prod_codigo 
WHERE p2.prod_rubro = r.rubr_id
AND s2.stoc_cantidad > (SELECT s3.stoc_cantidad 
FROM stock s3 
WHERE s3.stoc_producto = '00000000' AND s3.stoc_deposito = '00') 
) AS stock
FROM rubro r
LEFT OUTER JOIN producto p ON r.rubr_id = p.prod_rubro 
GROUP BY r.rubr_id, r.rubr_detalle
--
(SELECT SUM(ISNULL(s2.stoc_cantidad,0)) 
FROM stock s2
INNER JOIN producto p2 ON s2.stoc_producto = p2.prod_codigo 
WHERE p2.prod_rubro = r.rubr_id
AND s2.stoc_cantidad > 
(SELECT s3.stoc_cantidad 
FROM stock s3 
WHERE s3.stoc_producto = '00000000' AND s3.stoc_deposito = '00') 
)

/*
7 Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock.*/

--SELECT 1 FROM Producto p 
--INNER JOIN STOCK s ON p.prod_codigo = s.stoc_producto --el orden del join es indistinto
--LEFT OUTER JOIN Item_Factura i ON p.prod_precio =

SELECT p.prod_codigo, p.prod_detalle, 
MIN(i.item_precio) AS precioMinimo, MAX(i.item_precio) AS precioMaximo,
CONVERT(DECIMAL(6,2),ROUND((MAX(i.item_precio) - MIN(i.item_precio)) * 100 / MIN(i.item_precio),2)) porcentaje
FROM producto p 
INNER JOIN stock s ON p.prod_codigo = s.stoc_producto 
LEFT OUTER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
WHERE s.stoc_cantidad > 0
GROUP BY p.prod_codigo, p.prod_detalle


/*
Ejercicio 8
Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.
.*/
SELECT COUNT(*) from deposito

select p.prod_codigo ,p.prod_detalle, MAX(s.stoc_cantidad) AS mayorStock
from Producto p --un producto en muchos depositos
inner join STOCK s on p.prod_codigo = s.stoc_producto
where s.stoc_cantidad >0
group by p.prod_codigo, p.prod_detalle
having count(*) = (SELECT COUNT(*) from deposito)

--por moscu
SELECT p.prod_codigo, p.prod_detalle, MAX(s.stoc_cantidad) AS mayorStock
FROM producto p INNER JOIN stock s ON p.prod_codigo = s.stoc_producto 
GROUP BY p.prod_codigo, p.prod_detalle 
HAVING count(*) = (SELECT COUNT(*) from deposito)

--8.1
SELECT p.prod_codigo, p.prod_detalle, MAX(s.stoc_cantidad) AS mayorStock
FROM producto p INNER JOIN stock s ON p.prod_codigo = s.stoc_producto
WHERE s.stoc_cantidad > 0
GROUP BY p.prod_codigo, p.prod_detalle 
HAVING count(*) = (SELECT COUNT(*) from deposito)

/*
Ejercicio 9
Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.
.*/

select j.empl_codigo AS codigoJefe, e.empl_codigo as codigoEmpleado,
CONCAT(RTRIM(e.empl_apellido) ,' ,',RTRIM(e.empl_nombre)) as empleadoNombre,
(select count(*) from DEPOSITO d2 
where d2.depo_encargado = j.empl_codigo or d2.depo_encargado = e.empl_codigo) as CantDepositos
from Empleado e	 
inner join Empleado j ON e.empl_jefe = j.empl_codigo


select count(*) from DEPOSITO d2 
where d2.depo_encargado = 1 or d2.depo_encargado = 2 --encargaos 1 y 2 del depo

-----------------------------------
select count(*) from DEPOSITO d where d.depo_encargado in (1,2) --encargaos 1 y 2 del depo

select * from DEPOSITO --busca la cant de depo asignados a jefe 1 y empl 2 ejemplos 
---------------------------------------
--por moscu
SELECT j.empl_codigo AS codigoJefe, e.empl_codigo AS codigoEmpleado, 
concat(rtrim(e.empl_apellido), ' ,', rtrim(e.empl_nombre)) AS nombreEmpleado,
(SELECT count(*) 
FROM DEPOSITO d2 
where d2.depo_encargado = e.empl_codigo 
OR d2.depo_encargado = j.empl_codigo) AS depositos
FROM Empleado e 
INNER JOIN 
Empleado j ON e.empl_jefe = j.empl_codigo

/*
10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo.
*/

select *
from Producto p 
where p.prod_codigo in (
select top 10 i.item_producto from Item_Factura i
group by i.item_producto
ORDER BY sum(i.item_cantidad) desc
)
union
select p.prod_codigo
from Producto p 
where p.prod_codigo in (
select top 10 COUNT(*) 
from Producto p 
inner join Item_Factura i on p.prod_codigo = i.item_producto
ORDER BY i.item_cantidad
)


/*
Ejercicio 11
Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012.
.*/

--el monto de dichas ventas sin impuestos
SELECT SUM(f2.fact_total_impuestos)  --factura en el from no provoca modificaciones
FROM factura f2  --no provoca multipliacion, para esa factura en el 2012 esxitan registros
WHERE EXISTS (SELECT 1 FROM Item_Factura i2 
INNER JOIN producto	p2 ON i2.item_producto = p2.prod_codigo 
WHERE f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
AND f2.fact_numero = i2.item_numero
AND YEAR(f2.fact_fecha) = 2012 
AND p2.prod_familia = '997')
--me devuelve lo que se vendio en el 2012 para esa familia 
--
select sum(fa.fact_total_impuestos)
from Factura fa
while EXISTS
(select 1 
from  Item_Factura i  
inner join Producto p on i.item_producto = p.prod_codigo 
where fa.fact_tipo = i.item_tipo AND fa.fact_sucursal = i.item_sucursal 
AND fa.fact_numero = i.item_numero 
and p.prod_familia = '90')
---sas
SELECT SUM(f2.fact_total_impuestos)  
FROM factura f2 
WHERE EXISTS 
(SELECT 1 FROM Item_Factura i2 
INNER JOIN producto p2 ON i2.item_producto = p2.prod_codigo 
WHERE f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
AND f2.fact_numero = i2.item_numero
AND p2.prod_familia = fam.fami_id)
/*
En otras palabras, está comprobando si la factura contiene al menos un producto de la familia fam.fami_id.*/

--resuelto
SELECT fam.fami_id, fam.fami_detalle, COUNT(DISTINCT i.item_producto) as ProductosDistintos,
(SELECT SUM(f2.fact_total_impuestos)  
FROM factura f2 
WHERE EXISTS (SELECT 1 FROM Item_Factura i2 
INNER JOIN producto p2 ON i2.item_producto = p2.prod_codigo 
WHERE f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
AND f2.fact_numero = i2.item_numero
AND p2.prod_familia = fam.fami_id)) as montoSinImpuestos
FROM Familia fam
INNER JOIN producto p ON fam.fami_id = p.prod_familia 
INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto 
GROUP BY fam.fami_id, fam.fami_detalle
HAVING (SELECT SUM(f2.fact_total_impuestos)  
FROM factura f2 
WHERE EXISTS (SELECT 1 FROM Item_Factura i2 
INNER JOIN producto p2 ON i2.item_producto = p2.prod_codigo 
WHERE f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
AND f2.fact_numero = i2.item_numero
AND YEAR(f2.fact_fecha) = 2012 
AND p2.prod_familia = fam.fami_id)) > 20000
ORDER BY 3 DESC



SELECT f.fami_id,f.fami_detalle, COUNT(DISTINCT i.item_producto) as ProductosDistintos
FROM Familia f
INNER JOIN Producto p ON f.fami_id = p.prod_familia
INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
ORDER BY  f.fami_id,f.fami_detalle
--FAMILIA, PRODUCTO, ITEM FACTURA, FACTURA


SELECT SUM(f2.fact_total_impuestos)  
FROM factura f2 
WHERE EXISTS (SELECT 1 FROM Item_Factura i2 
INNER JOIN producto p2 ON i2.item_producto = p2.prod_codigo 
WHERE f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
AND f2.fact_numero = i2.item_numero
AND p2.prod_familia = '997') 
--FAMILIA, PRODUCTO, ITEM FACTURA, FACTURA
--CANTIDAD diferentes de productos vendidos
--monto de dichas ventas sin impuestos



/*
12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/


--mio
select p.prod_detalle 'Nombre Producto',
count(distinct f.fact_cliente) 'Compradores',
(sum(i.item_cantidad * i.item_precio)/sum(i.item_cantidad)) as 'importe promedio x Producto',
(select count (*)
	from Stock s
	inner join Deposito d on s.stoc_deposito = d.depo_codigo--es igual en where y en on 
	where s.stoc_producto = p.prod_codigo and s.stoc_cantidad > 0) as 'Cantidad depositos',
(select sum(isnull(s.stoc_cantidad,0)) 
	  from Stock s
	  inner join Deposito d on s.stoc_deposito = d.depo_codigo and 
	  s.stoc_producto = p.prod_codigo
	  ) as 'Stock Actual del producto'
from Producto p 
	inner join Item_Factura i on P.prod_codigo = i.item_producto
	inner join Factura f on i.item_tipo = f.fact_tipo and
	i.item_sucursal = f.fact_sucursal and i.item_numero = f.fact_numero
where exists(select 1 
	from Item_Factura i1
	inner join Factura f1 on i1.item_tipo = f1.fact_tipo and
	i1.item_sucursal = f1.fact_sucursal and i1.item_numero = f1.fact_numero
	where year(f1.fact_fecha) = 2012 and i1.item_producto = p.prod_codigo)
group by p.prod_codigo,p.prod_detalle
Order by sum(i.item_precio * i.item_cantidad) desc

/*
OBSERVACION ES MEJOR DEJAR LAS FACTURAS ITEM Y PRODUCTO QUE tienen muchos
registros en el from principal y hacer subselect de tablas que no van 
a tener muchos registros como deposito, 
*/
select p.prod_detalle,
(select 1)
from Producto p
inner join Item_Factura i on p.prod_codigo = i.item_producto
inner join  Factura f on f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal 
AND f.fact_numero = i.item_numero 
ORDER BY p.prod_codigo desc

--cantidad de clientes distintos que lo compraron, 
(select COUNT(DISTINCT (c2.clie_codigo) 
from Cliente c2 
where f.fact_cliente  = c2.clie_codigo)

--importe promedio pagado por el producto
select AVG(p3.prod_precio) 
from Producto p3
inner join Item_Factura i3 on p3.prod_codigo = i3.item_producto
where p3.prod_codigo = '00010470'

-- cantidad de depósitos en los cuales hay stock del producto
select count(*)
from DEPOSITO d 
where exists(
select 1 from Producto p4
inner join STOCK s on p4.prod_codigo = s.stoc_producto
where d.depo_codigo = s.stoc_deposito and
p4.prod_codigo = '00010470' )

select p.prod_codigo, avg(p.prod_precio) 
from Producto p
GROUP BY p.prod_codigo

--------------------------------------------
--Resolucion moscuza ej 12
SELECT p.prod_detalle,
COUNT(DISTINCT f.fact_cliente),
SUM(item.item_precio * item.item_cantidad) / SUM(item.item_cantidad),
(select count(*) 
	from STOCK s 
	INNER join DEPOSITO d on s.stoc_deposito = d.depo_codigo 
	and s.stoc_producto = p.prod_codigo
	AND s.stoc_cantidad > 0),
(select SUM(ISNULL(s.stoc_cantidad,0)) 
	from STOCK s 
	INNER join DEPOSITO d on s.stoc_deposito = d.depo_codigo 
	and s.stoc_producto = p.prod_codigo)
FROM Producto p
	JOIN Item_Factura item on p.prod_codigo = item.item_producto
	JOIN Factura F ON f.fact_tipo = item.item_tipo 
	AND f.fact_sucursal = item.item_sucursal AND f.fact_numero = item.item_numero
where EXISTS (SELECT 1 
	FROM factura f2 
	INNER JOIN Item_Factura i2  
	ON f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
	AND f2.fact_numero = i2.item_numero
	WHERE YEAR(f2.fact_fecha) = 2012 AND i2.item_producto = p.prod_codigo)
GROUP by p.prod_codigo, p.prod_detalle
ORDER BY SUM(item.item_precio * item.item_cantidad) desc

--Factura Total ejemplo son la venta de los 10 productos en una factura

/*
13. Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.*/

--mio esta okokokooo
select p.prod_detalle as 'Nombre Producto', p.prod_precio as 'precio Producto'
,sum(componente.prod_precio * c.comp_cantidad) as 'Precio del Componente Total'
from Producto p 
inner join Composicion c on p.prod_codigo = c.comp_producto
inner join Producto componente on c.comp_componente = componente.prod_codigo
Group by p.prod_codigo,p.prod_detalle, p.prod_precio
having sum(c.comp_cantidad) > 2
Order by SUM(c.comp_cantidad) desc 

select *
from Producto p 
inner join Composicion c on p.prod_codigo = c.comp_producto

--ok moscu
SELECT p.prod_codigo, p.prod_detalle, p.prod_precio,
SUM(c.comp_cantidad * componente.prod_precio) as precioComponente 
FROM Producto p
INNER JOIN Composicion c ON p.prod_codigo = c.comp_producto
INNER JOIN Producto Componente ON c.comp_componente = Componente.prod_codigo 
GROUP BY p.prod_codigo, p.prod_detalle, p.prod_precio 
HAVING SUM(c.comp_cantidad) > 2 
ORDER BY SUM(c.comp_cantidad) 
--Entendido

/*
14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:
Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna
*/
--El ultimo anio 2012 simplificando
--mio okok
	select c.clie_codigo 'Codigo Cliente',
	count(*) as 'Compras Ultimo Anio',
	avg(f.fact_total) as 'Promedio Compra',
	(select count(distinct i2.item_producto)
		FROM Factura f2 
		INNER JOIN item_factura i2 ON f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
		AND f2.fact_numero = i2.item_numero 
		where YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = c.clie_codigo) as 'Productos Distintos',
		Max(f.fact_total) as 'Importe Maximo'
	from Cliente c
	inner join Factura f on c.clie_codigo = f.fact_cliente
	where year(f.fact_fecha) = 2012 
	Group by c.clie_codigo
union all --
select c.clie_codigo 'Codigo Cliente', 0 as 'Compras Ultimo Anio',
0 as 'Promedio Compra', 0 as 'Productos Distintos', 0 as 'Importe Maximo'
from Cliente c
where not exists(select 1 
				from Factura f
				where year(f.fact_fecha) = 2012 and f.fact_cliente = c.clie_codigo)
Order by 4 desc

--ok moscu	
SELECT c.clie_codigo, 
COUNT(*) AS Facturas, 
AVG(f.fact_total) AS promedio,
(SELECT COUNT(DISTINCT i2.item_producto) 
	FROM Factura f2 
	INNER JOIN item_factura i2 ON f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal 
	AND f2.fact_numero = i2.item_numero 
	WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = c.clie_codigo) AS productos,
	MAX(f.fact_total) AS importeMaximo
FROM Cliente c 
INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente 
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY c.clie_codigo 
UNION ALL -- si no compro es 0
SELECT c.clie_codigo, 0 AS Facturas, 0 AS promedio, 0 AS productos, 0 AS importeMaximo
FROM Cliente c 
WHERE NOT EXISTS (SELECT 1 
					FROM Factura f2 
					WHERE f2.fact_cliente = c.clie_codigo AND YEAR(f2.fact_fecha) = 2012)
ORDER BY 4 DESC
--------------------
--Cantidad de productos diferentes que compro en el último año
SELECT COUNT(DISTINCT i2.item_producto) FROM Factura f2 
INNER JOIN item_factura i2 ON f2.fact_tipo = i2.item_tipo 
AND f2.fact_sucursal = i2.item_sucursal 
AND f2.fact_numero = i2.item_numero 
WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = c.clie_codigo


-- Ejercicio 15
/*Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
(en la misma factura) más de 500 veces. El resultado debe mostrar el código y
descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
juntos dichos productos. Los distintos pares no deben retornarse más de una vez.*/

SELECT it1.item_producto, it2.item_producto, pr.prod_detalle, pr2.prod_detalle, COUNT(*) AS cantidad 
FROM item_factura it1
INNER JOIN item_factura it2 ON it1.item_numero = it2.item_numero AND it1.item_sucursal = it2.item_sucursal AND it1.item_tipo = it2.item_tipo
INNER JOIN producto pr ON pr.prod_codigo = it1.item_producto
INNER JOIN producto pr2 ON pr2.prod_codigo = it2.item_producto
WHERE it1.item_producto < it2.item_producto
GROUP BY it1.item_producto, it2.item_producto, pr.prod_detalle, pr2.prod_detalle
HAVING COUNT(*) > 500

--factura 92444 con productos 1415, 1420 y 7140 
--factura 92444 con productos 1415, 1420 y 7800 

--Terminado por mozcuzza
-- Ejercicio 15
SELECT it1.item_producto, it2.item_producto, pr.prod_detalle, pr2.prod_detalle, COUNT(*) AS cantidad 
FROM item_factura it1
INNER JOIN item_factura it2 ON it1.item_numero = it2.item_numero AND it1.item_sucursal = it2.item_sucursal AND it1.item_tipo = it2.item_tipo
INNER JOIN producto pr ON pr.prod_codigo = it1.item_producto
INNER JOIN producto pr2 ON pr2.prod_codigo = it2.item_producto
WHERE it1.item_producto < it2.item_producto
GROUP BY it1.item_producto, it2.item_producto, pr.prod_detalle, pr2.prod_detalle
HAVING COUNT(*) > 500

--EJercicio
/*
31. Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.
*/

--ok moscuzza
SELECT YEAR(f.fact_fecha) AS Año, v.empl_codigo as Codigo,
CONCAT(RTRIM(v.empl_apellido),', ',RTRIM(v.empl_nombre)) AS detalleVendedor,
COUNT(*) AS cantidadFacturas, 
COUNT(DISTINCT f.fact_cliente) AS cantidadClientes,
(SELECT COUNT(*) 
	FROM factura f2 
	INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
	AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = i2.item_numero 
	INNER JOIN Composicion c2 ON i2.item_producto = c2.comp_producto 
	WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha) 
	AND f2.fact_vendedor = v.empl_codigo) AS productosConComposicion,
(SELECT COUNT(*) 
	FROM factura f2 
	INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
	AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = i2.item_numero 
	WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)  AND f2.fact_vendedor = v.empl_codigo
	AND NOT EXISTS (SELECT 1 FROM Composicion c3 WHERE c3.comp_producto = i2.item_producto)
	) AS productosSinComposicion,
	SUM(f.fact_total) AS montoTotal
FROM Empleado v 
INNER JOIN Factura f ON v.empl_codigo = f.fact_vendedor 
GROUP BY YEAR(f.fact_fecha), v.empl_codigo, v.empl_apellido, v.empl_nombre  
ORDER BY YEAR(f.fact_fecha),
							(SELECT COUNT(*) 
							FROM factura f2 
							INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
							AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = i2.item_numero 
							WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha) AND f2.fact_vendedor = v.empl_codigo) DESC


/*
--ejercicio 27
Escriba una consulta sql que retorne una estadística basada en la facturacion por año y
envase devolviendo las siguientes columnas:
 Año
 Codigo de envase
 Detalle del envase
 Cantidad de productos que tienen ese envase
 Cantidad de productos facturados de ese envase
 Producto mas vendido de ese envase
 Monto total de venta de ese envase en ese año
 Porcentaje de la venta de ese envase respecto al total vendido de ese año
Los datos deberan ser ordenados por año y dentro del año por el envase con más
facturación de mayor a menor */

--ok moscuzza
SELECT YEAR(f.fact_fecha)                                             AS [Año],
	e.enva_codigo                                                     AS [CodEnv],
	e.enva_detalle                                                    as [DetEnv],
	(SELECT COUNT(*) FROM Producto WHERE prod_envase = e.enva_codigo) AS [#ProdConEnv],
       COUNT(DISTINCT p.prod_codigo)                                  AS [#ProdFactConEnv],
	(SELECT TOP 1 prod_detalle
        FROM Producto
        WHERE prod_envase = e.enva_codigo
        GROUP BY prod_codigo, prod_detalle
        ORDER BY COUNT(*) DESC)                                          AS [ProdMasVendidoEnv],
       SUM(item_cantidad * item_precio)                                  AS [MontoTotVentaEnvAño],
       SUM(item_cantidad * item_precio) * 100 /
       (SELECT SUM(fact_total)
        FROM Factura
	WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha))                     AS [%VentaEnvRespectoTotVendidoAño]
	FROM Producto p
		INNER JOIN Item_Factura ON p.prod_codigo = item_producto
        INNER JOIN Envases e ON p.prod_envase = e.enva_codigo
        INNER JOIN Factura f
                    ON item_tipo = f.fact_tipo AND item_sucursal = f.fact_sucursal AND item_numero = f.fact_numero
	GROUP BY YEAR(f.fact_fecha), e.enva_codigo, e.enva_detalle
	ORDER BY 1, 7 DESC




/*
-- EJ 22
Escriba una consulta sql que retorne una estadistica de venta para todos los rubros por
trimestre contabilizando todos los años. Se mostraran como maximo 4 filas por rubro (1
por cada trimestre).
Se deben mostrar 4 columnas:
 Detalle del rubro
 Numero de trimestre del año (1 a 4)
 Cantidad de facturas emitidas en el trimestre en las que se haya vendido al
menos un producto del rubro
 Cantidad de productos diferentes del rubro vendidos en el trimestre
El resultado debe ser ordenado alfabeticamente por el detalle del rubro y dentro de cada
rubro primero el trimestre en el que mas facturas se emitieron.
No se deberan mostrar aquellos rubros y trimestres para los cuales las facturas emitiadas
no superen las 100.
En ningun momento se tendran en cuenta los productos compuestos para esta
estadistica.
*/
--DATEPART(QUARTER, fecha) //funcion para calcualr el trimetre devuelve un valor del 1 al 4

--ok moscuzza
SELECT r.rubr_detalle as DetalleRubro,
DATEPART(QUARTER, f.fact_fecha
) as Trimestre,
--Cantidad de facturas emitidas en el trimestre en las que se haya vendido al menos un producto del rubro
COUNT(DISTINCT f.fact_tipo + f.fact_sucursal + f.fact_numero ) as CantidadFacturas,
COUNT (DISTINCT p.prod_codigo) as CantidadProductos
FROM Rubro r
INNER JOIN Producto p ON r.rubr_id = p.prod_rubro 
INNER JOIN Item_Factura i ON item_producto = p.prod_codigo
INNER JOIN Factura f ON f.fact_tipo = i.item_tipo 
			and f.fact_sucursal = i.item_sucursal and f.fact_numero = i.item_numero
	WHERE NOT EXISTS(SELECT 1 FROM Composicion c2 
	WHERE  c2.comp_producto = p.prod_codigo OR c2.comp_componente = p.prod_codigo)
--como el where se ejecuta antes se puede hacer el select de componente = producto_CODIGO
GROUP BY r.rubr_id,r.rubr_detalle, DATEPART(QUARTER, f.fact_fecha)
HAVING COUNT(DISTINCT f.fact_tipo + f.fact_sucursal + f.fact_numero) > 100
ORDER BY 1, 3 DESC 

/*la clave es ser preciso para que no se haga denso poner muchos select y tener mania*/

/*
Al lado del count tiene que ir siempre un campo, 
el Count y el nombre del campo me indica de filas o el contador de los que no sean nulos 
COUNT(DISTINC ...) me indica de filas de los que no
sean nulos y le agrega de un campo la eliminacion de los duplicados

OBSERVACION como no tengo un solo campo, lo tengo en 3 los concateno y los trato como un solo valor
y de esa forma lo puedo tratar como un COUNT(DISTICT..)  como es funcion le pongo un alias

COUNT(DISTINCT f.fact_tipo + f.fact_sucursal + f.fact_numero )  --concateno la clave primaria

SELECT r.rubr_detalle 
FROM Rubro r 
GROUP BY r.rubr_detalle 
ORDER BY r.rubr_detalle asc

WHERE es Restriccion a la tabla
HAVING  es restrinccion a la funcion sumarizada

*/
--HECHO POR MOZCU
SELECT r.rubr_detalle, DATEPART(QUARTER, f.fact_fecha) AS Trimestre,
COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) AS cantidadFacturas,
COUNT(DISTINCT p.prod_codigo) AS cantidadProductos
FROM rubro r 
INNER JOIN producto p ON r.rubr_id = p.prod_rubro 
INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
INNER JOIN factura f ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
WHERE NOT EXISTS (SELECT 1 FROM composicion c2 WHERE c2.comp_producto = p.prod_codigo OR c2.comp_componente = p.prod_codigo)
GROUP BY r.rubr_id, r.rubr_detalle, DATEPART(QUARTER, f.fact_fecha) 
HAVING COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) > 100
ORDER BY 1, 3 DESC

---------------------------------------
/*ejercicio 18
Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:
DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30
días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por cantidad de productos diferentes vendidos del rubro.
*/
select r.rubr_detalle, Sum(i.item_cantidad * i.item_precio)
from Rubro r
inner join Producto p on r.rubr_id = p.prod_rubro
inner join Item_Factura i on p.prod_codigo = i.item_producto
GROUP by r.rubr_id,r.rubr_detalle





SELECT r.rubr_detalle, SUM(i.item_precio * i.item_cantidad) AS Ventas, 
(SELECT TOP 1 p2.prod_codigo-- p2.prod_detalle, SUM(i2.item_cantidad) AS Sumatoria
FROM producto p2 
INNER JOIN rubro r2 ON p2.prod_rubro = r2.rubr_id 
INNER JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo 
WHERE r2.rubr_id = r.rubr_id
GROUP BY p2.prod_codigo, p2.prod_detalle
ORDER BY SUM(i2.item_c	antidad) Desc)
FROM Rubro r
INNER JOIN Producto p ON r.rubr_id = p.prod_rubro
INNER JOIN Item_Factura i ON i.item_producto = p.prod_codigo
GROUP BY r.rubr_id,r.rubr_detalle
UNION --los que no tuvieron ventas 
SELECT r.rubr_detalle, 0 AS Ventas, '00000000'  AS productoMasVendido, '00000000' AS SegundoVendido, '000000' AS Cliente
FROM rubro r 
WHERE NOT EXISTS (SELECT 1 FROM producto p2 INNER JOIN rubro r2 ON p2.prod_rubro = r2.rubr_id 
                  INNER JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo 
				  WHERE r2.rubr_id = r.rubr_id ) --sublect correlacionado de no existencia osea los que no estan en este select

--AL estar el precio en item no es necesario la factura
--INNER JOIN Factura f ON f.fact_sucursal = i.item_sucursal and f.fact_tipo = i.item_tipo and f.fact_numero = i.item_numer

/*OBSERVACIONES 
si un rubro no tuviera ventas entonces ESTO no joinea y no muestra el rubro, 
y deberia de mostrar el rubro con la cantidad en 0
SELECT r.rubr_detalle, SUM(i.item_precio * i.item_cantidad) AS Ventas
FROM Rubro r
INNER JOIN Producto p ON r.rubr_id = p.prod_rubro
INNER JOIN Item_Factura i ON i.item_producto = p.prod_codigo

ENTONCES SE PUEDE USAR 2 ESTRATEGIAS para unir a los que vendieron y los q no

1OPCION ES 

SELECT r.rubr_detalle, SUM(i.item_precio * i.item_cantidad) AS Ventas
FROM Rubro r
lEFT OUTER JOIN Producto p ON r.rubr_id = p.prod_rubro --quede rubro tabla dominante
lEFT OUTER  JOIN Item_Factura i ON i.item_producto = p.prod_codigo --igual para al quedar null tambien hay que considerar los de ventas 0
GROUP BY p.prod_codigo
UNION	
2da opcion
Mostrar los rubro mientra no exita un registro de ventas 
SELECT r.rubr_detalle, 0 AS Ventas, 
FROM rubro r 
WHERE NOT EXISTS (SELECT 1 FROM producto p2 INNER JOIN rubro r2 ON p2.prod_rubro = r2.rubr_id 
                  INNER JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo 
				  WHERE r2.rubr_id = r.rubr_id )
***********
PARA VER EL PRODUCTO MENOS Y MAS VENDIDO 
pruebo con PASTILLA con rubro_id=0013
mas vendido prod_codigo 00000102 halls 00001303 metitas

0007 Caramelos
*/

SELECT TOP 1 p2.prod_codigo-- p2.prod_detalle, SUM(i2.item_cantidad) AS Sumatoria
FROM producto p2 
INNER JOIN rubro r2 ON p2.prod_rubro = r2.rubr_id 
INNER JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo 
WHERE r2.rubr_id = '0013'
GROUP BY p2.prod_codigo, p2.prod_detalle
ORDER BY SUM(i2.item_cantidad) Desc
--DEVUELVE EL CODIGO DEL PRODUCTO MAS VENDIDO DEL RUBRO PASTILLAS

/*PARA LOS ULTIMOS 30 DIAS
tomamos la fecha del sistema getday()*/

/*ejercicio 18
Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:
DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30
días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por cantidad de productos diferentes vendidos del rubro.
*/
--HECHO POR MOZCU
SELECT r.rubr_detalle, SUM(i.item_precio * i.item_cantidad) AS Ventas,
(SELECT TOP 1 p2.prod_codigo 
FROM producto p2 INNER JOIN rubro r2 ON p2.prod_rubro = r2.rubr_id 
INNER JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo 
WHERE r2.rubr_id = r.rubr_id
GROUP BY p2.prod_codigo, p2.prod_detalle
ORDER BY SUM(i2.item_cantidad) DESC) AS productoMasVendido,
ISNULL((SELECT VW.prod_codigo FROM 
(SELECT ROW_NUMBER() OVER (ORDER BY SUM(i2.item_cantidad) DESC) AS orden, p2.prod_codigo
FROM producto p2 INNER JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo
WHERE p2.prod_rubro = r.rubr_id
GROUP BY p2.prod_codigo) VW
WHERE orden = 2),'00000000') AS SegundoVendido,
ISNULL((SELECT TOP 1 F.fact_cliente FROM Factura F 
INNER JOIN Item_Factura I ON F.fact_numero = I.item_numero AND F.fact_sucursal = I.item_sucursal AND F.fact_tipo = I.item_tipo 
INNER JOIN Producto P ON i.item_producto = p.prod_codigo 
WHERE DATEDIFF(DAY,F.fact_fecha,getdate()) < 31 AND 
P.prod_rubro = R.rubr_id
GROUP BY F.fact_cliente 
ORDER BY SUM(I.item_cantidad) DESC
),'000000') AS Cliente
FROM rubro r 
INNER JOIN producto p ON r.rubr_id = p.prod_rubro 
INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
GROUP BY r.rubr_id, r.rubr_detalle
UNION
SELECT r.rubr_detalle, 0 AS Ventas, '00000000'  AS productoMasVendido, '00000000' AS SegundoVendido, '000000' AS Cliente
FROM rubro r 
WHERE NOT EXISTS (SELECT 1 FROM producto p2 INNER JOIN rubro r2 ON p2.prod_rubro = r2.rubr_id 
                  INNER JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo 
				  WHERE r2.rubr_id = r.rubr_id )
--esta ok todo
select f.fact_fecha
,DATEDIFF(DAY,F.fact_fecha,getdate())
,DATEDIFF(MONTH,F.fact_fecha,getdate())
,DATEDIFF(YEAR,F.fact_fecha,getdate())
from Factura f


/*
23. Realizar una consulta SQL que para cada año muestre :
 Año
 El producto con composición más vendido para ese año.
 Cantidad de productos que componen directamente al producto más vendido
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año en forma descendente.
*/




--resuelto por moszu
SELECT YEAR(f.fact_fecha), P.prod_detalle,
(SELECT SUM(c2.comp_cantidad)  FROM Composicion c2 WHERE c2.comp_producto = p.prod_codigo) as componentes,
COUNT(*) as facturas,
(SELECT TOP 1 f2.fact_cliente
        FROM factura f2
                 INNER JOIN Item_Factura i2
                            ON f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal AND
                               f2.fact_numero = i2.item_numero
        WHERE i2.item_producto = p.prod_codigo
        GROUP BY f2.fact_cliente
        ORDER BY COUNT(DISTINCT f2.fact_tipo+f2.fact_sucursal+f2.fact_numero) DESC) as cliente,
       SUM(i.item_cantidad * i.item_precio) * 100 /
(SELECT SUM(i2.item_cantidad * i2.item_precio)
        FROM factura f2
                 INNER JOIN Item_Factura i2
                            ON f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal AND
                               f2.fact_numero = i2.item_numero
        WHERE YEAR(f.fact_fecha) = YEAR(f2.fact_fecha))as porcentaje
FROM factura f 
INNER JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
INNER JOIN producto p ON i.item_producto = p.prod_codigo 
INNER JOIN Composicion c ON p.prod_codigo = c.comp_producto 
GROUP BY YEAR(f.fact_fecha), p.prod_codigo, P.prod_detalle 
HAVING p.prod_codigo IN (
SELECT TOP 1 i2.item_producto
FROM factura f2 
INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = i2.item_numero
INNER JOIN Composicion c2 ON i2.item_producto = c2.comp_producto 
WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
GROUP BY i2.item_producto 
ORDER BY SUM(i2.item_cantidad) DESC)



--1opcion tarda mucho
select YEAR(f.fact_fecha),p.prod_codigo,p.prod_detalle
from Factura f
INNER JOIN Item_Factura i on f.fact_tipo = i.item_tipo
and f.fact_numero = i.item_numero and f.fact_sucursal = i.item_sucursal
INNER JOIN Producto p on i.item_producto = p.prod_codigo --como me pide la cantidad de productos pongo Producto pero sino podria saltar y no ponerlo y solo poner la composicion
INNER JOIN Composicion c on p.prod_codigo = c.comp_producto
WHERE p.prod_codigo IN (select TOP 1 i2.item_producto --in porque la tabla puede devolver nada y no es ni null ni 0
from Factura f2
INNER JOIN Item_Factura i2 on f2.fact_tipo = i2.item_tipo
and f2.fact_numero = i2.item_numero and f2.fact_sucursal = i2.item_sucursal
INNER JOIN Composicion c2 on i2.item_producto= c2.comp_producto
WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
GROUP BY i2.item_producto
ORDER BY SUM(i2.item_cantidad) DESC)
GROUP BY YEAR(f.fact_fecha),p.prod_codigo,p.prod_detalle

--2da opcion con HAVING

select YEAR(f.fact_fecha) AS Anio,p.prod_codigo,p.prod_detalle,
(select SUM(c2.comp_cantidad) from Composicion c2
where c2.comp_producto = p.prod_codigo) as cantProdComponentes
from Factura f
INNER JOIN Item_Factura i on f.fact_tipo = i.item_tipo
and f.fact_numero = i.item_numero and f.fact_sucursal = i.item_sucursal
INNER JOIN Producto p on i.item_producto = p.prod_codigo --como me pide la cantidad de productos pongo Producto pero sino podria saltar y no ponerlo y solo poner la composicion
INNER JOIN Composicion c on p.prod_codigo = c.comp_producto
GROUP BY YEAR(f.fact_fecha),p.prod_codigo,p.prod_detalle
HAVING p.prod_codigo IN (select TOP 1 i2.item_producto --in porque la tabla puede devolver nada y no es ni null ni 0
from Factura f2
INNER JOIN Item_Factura i2 on f2.fact_tipo = i2.item_tipo
and f2.fact_numero = i2.item_numero and f2.fact_sucursal = i2.item_sucursal
INNER JOIN Composicion c2 on i2.item_producto= c2.comp_producto
WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
GROUP BY i2.item_producto
ORDER BY SUM(i2.item_cantidad) DESC)
/*
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.

select COUNT(DISTINCT i3.item_cantidad)
from Item_Factura i3
WHERE i3.item_producto = '00001718'
GROUP BY i3.item_cantidad

select f4.fact_cliente
from Factura f4
INNER JOIN Item_Factura i4 on f4.fact_tipo = i4.item_tipo
and f4.fact_numero = i4.item_numero and f4.fact_sucursal = i4.item_sucursal
GROUP BY f4.fact_cliente

select TOP 1 i2.item_producto
from Factura f2
INNER JOIN Item_Factura i2 on f2.fact_tipo = i2.item_tipo
and f2.fact_numero = i2.item_numero and f2.fact_sucursal = i2.item_sucursal
INNER JOIN Composicion c2 on i2.item_producto= c2.comp_producto
WHERE YEAR(f2.fact_fecha) = 2012
GROUP BY i2.item_producto
ORDER BY SUM(i2.item_cantidad) DESC
--mas vendio en 2012 item_prod 00001718


select SUM(c2.comp_cantidad) from Composicion c2
where c2.comp_producto = '00001718'



*/

/*ejercicio 34
Escriba una consulta sql que retorne para todos los rubros la cantidad de facturas mal
facturadas por cada mes del año 2011 Se considera que una factura es incorrecta cuando
en la misma factura se factutan productos de dos rubros diferentes. Si no hay facturas
mal hechas se debe retornar 0. Las columnas que se deben mostrar son:
1- Codigo de Rubro
2- Mes
3- Cantidad de facturas mal realizadas.  */
SELECT r.rubr_id, COUNT(*) as 'Cantidad de facturas mal realizadas'
FROM Rubro r
INNER JOIN Producto p ON r.rubr_id = p.prod_rubro
INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
INNER JOIN Factura f ON i.item_sucursal = f.fact_sucursal and 
				i.item_cantidad = f.fact_numero and i.item_tipo = f.fact_tipo
WHERE YEAR(f.fact_fecha = '2011') AND MONTH(f.fact_fecha)  = 1 
GROUP BY r.rubr_id 

SELECT 
FROM Rubro r
INNER JOIN Producto p ON r.rubr_id = p.prod_rubro
INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
INNER JOIN Factura f ON i.item_sucursal = f.fact_sucursal and 
				i.item_cantidad = f.fact_numero and i.item_tipo = f.fact_tipo
WHERE r.rubr_detalle  



--para poner los 12 meses del anio

SELECT * 
FROM(SELECT 1 as Mes 
UNION SELECT 2 AS Mes
UNION SELECT 3 AS Mes
UNION SELECT 4 AS Mes
UNION SELECT 5 AS Mes
UNION SELECT 6 AS Mes
UNION SELECT 7 AS Mes
UNION SELECT 8 AS Mes
UNION SELECT 9 AS Mes
UNION SELECT 10 AS Mes
UNION SELECT 11 AS Mes
UNION SELECT 12 AS Mes) AS Meses, Rubro R
--ESTO es un producto cartesiano
--el producto se puede hacer porque el rubro teine 31 registros ,sino es imposible
--si no lo desarrollado totalmente ni performante
--los uninon son 12 variables
select * from Rubro

SELECT COUNT(DISTINCT f2.fact_tipo+f2.fact_sucursal+f2.fact_numero) FROM 
factura f2 INNER JOIN Item_Factura i2 ON 
f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = f2.fact_numero
INNER JOIN producto p2 ON i2.item_producto = p2.prod_codigo 
WHERE YEAR(f2.fact_fecha) = 2011 AND MONTH(f2.fact_fecha) = 1
AND p2.prod_rubro = '0007'--r.rubr_id 
AND EXISTS (SELECT 1 FROM producto p3 WHERE p3.prod_rubro != p2.prod_rubro)

--EL COUNT NUNCA DEVULVE NULO , 0 EN EL PEOR DE LOS CASOS entonces no
--es necesario poner ninguna funcionalidad para si es nulo

--**********Hecho por moscuza ok
SELECT r.rubr_id, Meses.Mes,
(SELECT COUNT(DISTINCT f2.fact_tipo+f2.fact_sucursal+f2.fact_numero) FROM 
factura f2 INNER JOIN Item_Factura i2 ON 
f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = f2.fact_numero
INNER JOIN producto p2 ON i2.item_producto = p2.prod_codigo 
WHERE YEAR(f2.fact_fecha) = 2011 AND MONTH(f2.fact_fecha) = Meses.Mes 
AND p2.prod_rubro = r.rubr_id 
AND EXISTS (SELECT 1 FROM producto p3 WHERE p3.prod_rubro != p2.prod_rubro)
) facturasErroneas 
FROM
(SELECT 1 as Mes 
UNION SELECT 2 AS Mes
UNION SELECT 3 AS Mes
UNION SELECT 4 AS Mes
UNION SELECT 5 AS Mes
UNION SELECT 6 AS Mes
UNION SELECT 7 AS Mes
UNION SELECT 8 AS Mes
UNION SELECT 9 AS Mes
UNION SELECT 10 AS Mes
UNION SELECT 11 AS Mes
UNION SELECT 12 AS Mes) AS Meses, rubro r



-------------------------------------------------------------------------------------------------------
/*
Cita:
1. Se pide realizar una consulta sql que retorne por cada año, el cliente que mas compro (fact_total),
la canitdad de articulos distintos comprados, la cantidad de rubros distintos comprados.
Solamente se deberan mostras aquellos clientes que posean al menos 10 facturas o mas por año.
El resultado debe ser ordenado por año.
Nota: no se permite el uso de sub-selects en el FROM ni funciones definidas por el usuario para este punto.
*/


/*
2. Implementar el/los objetos necesarios para la siguiente restriccion:
"Toda composicion (ej. COMBO 1) debe estar compuesta solamente por productos simples (EJ: COMBO4 compuesto por: 4 Hamburguesas, 2 gaseosas y 2 papas). No se permitirá que un combo este compuesto por nigun otro combo."
Se sabe que en la actualidad dicha regla se cumple y que la base de datos es accedido por n aplicaciones de diferentes tipos y tecnologías.
*/

/*
PARCIAL LUIS
realizar una consulta sql que retorne para el ultimo anio, los 5 vendedores 
con menos clientes asignados que mas vendieron en pesos,(si hay varios con menos
clientes asignados debe traer el que mas vendio)
1) apellido y nombre del vendedor
2)total de unidades de producro vendidas
3)monto promedio de venta por factura
4) monto total de ventas
el resultado debera mostrar ordenado la cantidad de ventas descente en caso de 
igualdad de cantidades ordenar por codigo de vendedor
NOTA: no se permite el uso de sub-select en el from ni funciones definidas por el usuario para este punto 
*/
select f.fact_vendedor
from Factura f
inner join Item_Factura i on f.fact_tipo =i.item_tipo
and f.fact_sucursal =i.item_sucursal and f.fact_numero = i.item_numero
where YEAR(f.fact_fecha) = '2011'--Datediff(year,f.fact_fecha,getdate()) < 1
--
select 
	fact_vendedor as vendedor,
	count(distinct f.fact_cliente) as clientesAsignados, 
	count( isnull(i.item_cantidad,0)) as TotalUnidadesVendidas,
	sum(f.fact_total)/count(distinct f.fact_tipo+f.fact_sucursal+f.fact_numero) as MontoPromedioXFactura,
	sum(f.fact_total) as MontoTotalVentas
from Factura f
	inner join Item_Factura i on i.item_tipo = f.fact_tipo and i.item_sucursal = f.fact_sucursal and i.item_numero = f.fact_numero 
where 
	year(f.fact_fecha)=2011--DATEDIFF(YEAR,f.fact_fecha,GETDATE()) < 1
	and f.fact_vendedor in (select top 5 f1.fact_vendedor 
							from Factura f1	
							where year(f1.fact_fecha)=2011 
							group by f1.fact_vendedor 
							order by count(distinct f1.fact_cliente), sum(f1.fact_total) desc)
group by fact_vendedor
order by TotalUnidadesVendidas desc,vendedor

/*28. Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.
*/

select 
	year(f.fact_fecha) as Año,
	f.fact_vendedor as Vendedor,
	count (distinct f.fact_tipo+f.fact_sucursal+f.fact_numero) as CantFacturas,
	count (distinct isnull(f.fact_cliente,'-')) as CantCliFacturados,
	ISNULL(
	(select 
		sum(isnull(i1.item_cantidad,0))
	from Factura f1 
		inner join Item_Factura i1 on i1.item_tipo = f1.fact_tipo and i1.item_sucursal = f1.fact_sucursal and i1.item_numero = f1.fact_numero 
		inner join Composicion c1 on c1.comp_producto = i1.item_producto
	where year(f1.fact_fecha)= year(f.fact_fecha) and f1.fact_vendedor = f.fact_vendedor
	),0) as ProductosFactComp,
	isnull((
	select 
		sum(isnull(i1.item_cantidad,0))
	from Factura f1 
		inner join Item_Factura i1 on i1.item_tipo = f1.fact_tipo and i1.item_sucursal = f1.fact_sucursal and i1.item_numero = f1.fact_numero 
		left join Composicion c1 on c1.comp_producto = i1.item_producto
	where year(f1.fact_fecha)= year(f.fact_fecha) and f1.fact_vendedor = f.fact_vendedor and c1.comp_producto is null
	),0) as ProductosFactSinComp,
	sum(f.fact_total) as MontoFacturado
from Factura f 
	inner join Item_Factura i on i.item_tipo = f.fact_tipo and i.item_sucursal = f.fact_sucursal and i.item_numero = f.fact_numero 
group by 
	year(f.fact_fecha),
	f.fact_vendedor
order by 1, count(distinct i.item_producto) desc








