use [GD2015C1]

/*LOS CURSORES SE PUEDEN REEMPLAZAR POR TABLAS TEMPORALES PERO SI HAY
RECURSISVIDAD CONVIENE EL CURSOSR*/

/*1 Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.*/

create function fx_estado (@cod_prod char(8), @cod_depo char(2))
returns varchar(max) as
begin 
	declare @estado varchar(max)
	
	select @estado = case
	when isnull(s.stoc_stock_maximo,0) = 0 then 'SIN STOCK MAXIMO'
	when ISNULL(s.stoc_cantidad,0) < s.stoc_stock_maximo 	
	then CONCAT('OCUPACION DEL DEPOSITO ' , s.stoc_cantidad * 100/s.stoc_stock_maximo , '%')
	else 'DEPOSITO COMPLETO' end
	from STOCK s
	inner join DEPOSITO d on d.depo_codigo = s.stoc_deposito
	where @cod_depo = d.depo_codigo and 
	@cod_prod = s.stoc_producto

	return @estado

end	
--para probar
select s.*,dbo.fx_estado (stoc_producto,stoc_deposito) as porcentaje
from STOCK s
-------

Create function fx_eje1 (@prod_codigo CHAR(8),@deposito CHAR(2))
RETURNS VARCHAR(MAX) AS
BEGIN
		declare @retorno varchar(max)
		select @retorno = case
		when ISNULL(s.stoc_stock_maximo,0) = 0 THEN 'SIN STOCK MAXIMO'
		when ISNULL(s.stoc_cantidad,0) < s.stoc_stock_maximo
		THEN CONCAT ('OCUPACION DEL DEPOSITO ',
		ISNULL(s.stoc_cantidad,0)*100/s.stoc_stock_maximo,'%')
		else 'DEPOSITO COMPLETO' END
		from STOCK s 
		inner join DEPOSITO d on s.stoc_deposito = d.depo_codigo
		where s.stoc_producto = @prod_codigo and d.depo_codigo = @deposito
		return @retorno


END
------ok
CREATE FUNCTION fx_estado_deposito(@prod_codigo CHAR(8), @deposito CHAR(2))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @estado VARCHAR(MAX)
	SELECT @estado = CASE 
						WHEN s.stoc_cantidad < s.stoc_stock_maximo --esto se peude porque ambos son NO NULL si fuese alguno nulo el > da falso y estaria mal la consulta
						THEN CONCAT('OCUPACION DEL DEPOSITO',
						s.stoc_cantidad * 100 / s.stoc_stock_maximo, '%')
						ELSE 'DEPOSITO COMPLETO' END 
	FROM STOCK s
	INNER JOIN DEPOSITO d ON s.stoc_deposito = d.depo_codigo
	WHERE s.stoc_producto = @prod_codigo

END
GO
/*
1 Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.*/	--RESPUESTA DEFINITIVA por moscuzza
CREATE FUNCTION get_ocupacion_depositov2(@prod_codigo char(8), @depo_codigo char(2))
RETURNS VARCHAR(MAX) AS
BEGIN
    DECLARE @estado VARCHAR(MAX) = ''
    SELECT @estado = CASE
                     WHEN ISNULL(s.stoc_stock_maximo,0) = 0 THEN 'SIN STOCK MAXIMO'
					 WHEN ISNULL(s.stoc_cantidad,0) < s.stoc_stock_maximo 
							THEN CONCAT('OCUPACION DEL DEPOSITO ',
							ISNULL(s.stoc_cantidad,0) * 100 /
							s.stoc_stock_maximo,' %')
                         ELSE 'DEPOSITO COMPLETO' END
    FROM STOCK s
             INNER JOIN DEPOSITO d ON s.stoc_deposito = d.depo_codigo
    WHERE s.stoc_producto = @prod_codigo
      AND d.depo_codigo = @depo_codigo 
    RETURN @estado

END
--s.* todos los campos
select s.*, dbo.get_ocupacion_deposito(stoc_producto,stoc_deposito) as	porcentaje 
from stock s


/*
2 Realizar una función que dado un artículo y una fecha, 
retorne el stock que existía a esa fecha
*/
create function fx_ej2 (@prod_cod char(8) ,@fecha smalldatetime)
returns smalldatetime as
begin
	declare @retorno smalldatetime
	
	select @retorno = 1
	from STOCK s
	where s.stoc_producto = @prod_cod  

--	return @retorno 
end



Create function fx_eje2(@prod_cod  char(8), @fecha smalldatetime)
returns decimal(12,2) as
begin 
	declare @retorno decimal(12,2)
	select @retorno = s.stoc_cantidad
	from STOCK s
	inner join Producto p on s.stoc_producto = p.prod_codigo
	inner join Item_Factura i on p.prod_codigo = i.item_producto
	inner join Factura f on i.item_tipo = f.fact_tipo 
	and i.item_numero = f.fact_numero and i.item_sucursal = f.fact_sucursal
	where s.stoc_producto = @prod_cod and f.fact_fecha = @fecha
	return @retorno
end
--no verifacdo
/*
4. Cree el/los objetos de base de datos necesarios 
para actualizar la columna de empleado empl_comision 
con la sumatoria del total de lo vendido por ese 
empleado a lo largo del último año. Se deberá retornar
el código del vendedor que más vendió (en monto) 
a lo largo del último año.
*/--no verifacdo


create procedure sp_ejer4 (@MasVendido numeric(6,0) OUTPUT) as
BEGIN
	declare @vendedor numeric(6), @empl_comision decimal(12),


	DECLARE c_comision CURSOR FOR
	select empl_comision
	FROM Empleado


	OPEN c_comision
	FETCH NEXT FROM c_comision INTO empl_comision
	while(@@FETCH_STATUS = 0 )
	BEGIN

		FETCH NEXT FROM c_comisiom INTO empl_comision

	end
END
--///////////////
ALTER PROC Ejercicio4 (@EmplQueMasVendio numeric(6,0) OUTPUT)
AS
BEGIN
/*SET @EmplQueMasVendio = (SELECT TOP 1 empl_codigo
								FROM Empleado
								INNER JOIN Factura
								ON fact_vendedor = empl_codigo
								WHERE YEAR(fact_fecha) = (
								SELECT TOP 1 YEAR(fact_fecha)
								FROM Factura
								ORDER BY fact_fecha DESC
												)
								GROUP BY empl_codigo
								ORDER BY SUM(fact_total) DESC
										
										)*/

UPDATE Empleado Set empl_comision = 
				(SELECT SUM(F.fact_total)
				FROM Factura F
				WHERE YEAR(fact_fecha) = (
				SELECT TOP 1 YEAR(fact_fecha)
				FROM Factura
				ORDER BY fact_fecha DESC)
				AND F.fact_vendedor = empl_codigo)

set @EmplQueMasVendio = (SELECT TOP 1 empl_codigo
						   FROM Empleado
						   ORDER BY empl_comision DESC)
RETURN
END


--minuto 1hora de clase procedure
/*3 clase procedure 1:00:00
Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.
*/--retornar y modificar es un procedure //funciones no modificar 

--mio
create procedure eje3 (@empleados_sin_jefe int output) as
begin
	
	declare @gerente_general numeric(6)

	select @empleados_sin_jefe = count(*)
	from Empleado e 
	where e.empl_jefe is null

	if(@empleados_sin_jefe > 1)
	begin
	select top 1 @gerente_general = e.empl_codigo
	from Empleado e 
	where e.empl_jefe is null
	order by e.empl_salario desc, e.empl_ingreso

	update Empleado 
	set empl_jefe = @gerente_general
	where empl_jefe is null
	and empl_codigo != @gerente_general
	end

end

--ok
CREATE PROCEDURE pr_ejercicio_3	(@p_empleados_sin_jefe INT OUTPUT) AS 
BEGIN
	DECLARE @v_gerente_general NUMERIC(6)

	SELECT @p_empleados_sin_jefe = COUNT(*) 
	FROM empleado 
	WHERE empl_jefe IS NULL 

	IF(@p_empleados_sin_jefe > 1)
	BEGIN
		SELECT TOP 1 @v_gerente_general = empl_codigo 
		FROM empleado 
		WHERE empl_jefe IS NULL 
		ORDER BY empl_salario DESC, empl_ingreso

		UPDATE empleado 
		SET empl_jefe = @v_gerente_general 
		WHERE empl_jefe IS NULL 
		AND empl_codigo != @v_gerente_general 

	END
END
GO

/* 4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año. */
--ULTIMO ANIO 2012

--mio
create procedure ej4(@cod_vendedor numeric(6)) as
begin
	update Empleado 
	set empl_comision = isnull((select sum(f.fact_total)
						from Factura f
						where f.fact_vendedor = Empleado.empl_codigo
						and year(f.fact_fecha) = 2012
						),0)
			select * from Empleado			

	select top 1 @cod_vendedor = empl_codigo
	from Empleado
	order by empl_comision desc
		

end



--anio maximo qye hay en la base select max(year(f1.fact_fecha)) from factura f1
--select max(year(Factura.fact_fecha))
--ok
CREATE PROCEDURE pr_ejercicio_4	(@p_mejor_vendedor INT OUTPUT) AS 
BEGIN--en insert update delete no se pueden poner alias
	UPDATE Empleado
	SET empl_comision = ISNULL((SELECT SUM(fact_total) FROM Factura F 
					    WHERE year(F.fact_fecha) = 
						(SELECT MAX(YEAR(fact_fecha)) FROM factura)--maximo anio
					    AND fact_vendedor = Empleado.empl_codigo),0) 

	SELECT TOP 1 @p_mejor_vendedor = empl_codigo FROM Empleado ORDER BY empl_comision DESC

END
GO

/* 6
Realizar un procedimiento que si en alguna factura se facturaron componentes
que conforman un combo determinado (o sea que juntos componen otro
producto de mayor nivel), en cuyo caso deberá reemplazar las filas
correspondientes a dichos productos por una sola fila con el producto que
componen con la cantidad de dicho producto que corresponda
*/
--sesion15.#insert_item 
--sesion45.#insert_item 

create procedure eje6 as
begin 
	
	update Factura
	END
--ok
CREATE PROCEDURE pr_ejercicio6 AS 
BEGIN
	DECLARE @tipo char(1), @sucursal char(4), @numero CHAR(8), @producto CHAR(8)

	--esta en memoria el cursor
	DECLARE c_compuesto CURSOR FOR 
	SELECT c.comp_producto, i.item_tipo, i.item_sucursal, i.item_numero
	FROM Composicion c
	INNER JOIN Item_Factura i ON c.comp_componente = i.item_producto
	WHERE i.item_cantidad = c.comp_cantidad  
	GROUP BY c.comp_producto, i.item_tipo, i.item_sucursal, i.item_numero  
	HAVING COUNT(*) = (SELECT * --COUNT(*) 
						from Composicion c2 
						where c.comp_producto = c2.comp_producto)
  
	--estan en disco la tabla temporal
	CREATE TABLE #insert_item(
	tempo_tipo CHAR(1),
	tempo_sucursal CHAR(4),
	tempo_numero CHAR(8),
	tempo_compuesto CHAR(8)
	)
	CREATE TABLE #delete_item(
	tempo_tipo CHAR(1),
	tempo_sucursal CHAR(4),
	tempo_numero CHAR(8),
	tempo_componente CHAR(8)
	)
	
	OPEN c_compuesto
	FETCH NEXT FROM c_compuesto INTO @producto, @tipo, @sucursal, @numero
	WHILE (@@FETCH_STATUS = 0)
	BEGIN

	   INSERT INTO #insert_item VALUES (@tipo, @sucursal, @numero, @producto)
   	  
	   INSERT INTO #delete_item  
	   SELECT @tipo, @sucursal, @numero, comp_componente 
	   FROM composicion where comp_producto = @producto
	    
		FETCH NEXT FROM c_compuesto INTO @producto, @tipo, @sucursal, @numero
	END
	CLOSE c_compuesto
	DEALLOCATE c_compuesto

	BEGIN TRANSACTION

	insert item_factura
	SELECT tempo_tipo, tempo_sucursal, tempo_numero, tempo_compuesto,1,p.prod_precio 
	FROM #insert_item if2 INNER JOIN Producto p ON if2.tempo_compuesto = p.prod_codigo 

	delete item_factura where 
	item_tipo+item_sucursal+item_numero+item_producto IN (select 
	tempo_tipo+tempo_sucursal+tempo_numero+tempo_componente from #delete_item)

	COMMIT TRANSACTION
END

/*
9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.

Concepto 
Hay una tabla que es de productos donde esta todo el catalogo y una tabla 
donde esta el stock de ese producto en distintos depositos
ejem: un celular de una marca determinada que esta en 10 depositos 
Si hay stock en los depositos no tiene que permitir el borrado
Ahora si no tiene stock en ningun lado si tiene qu epermitirlo
Dejar que el delete fluya

paso por el codigo de barra 2 pilas 1 linterna 4 veces
y se tiene que restar el stock  de cada componente no de la composicion
El evento es UPDATE sobre el item de facturas, que es lo que habia antes que es lo que hay ahora,
si hubo una modificacion en las cantidades ,si la modificacion en cantidades
fue ascendente habian 2 ahora 5 yresta en en stock los componentes no el producto compuesto

Reglas : elegimos un deposito cualqueira y hacemos siempre la resta sobre ese deposito
Manejado con cursores  que me determine cuales son los componentes a restar y 
a partir de ahi hacer la modificacion,
aclaracion ADENTRO DE un TRIGGER PUEDO invocar un STORE PROCEDURE para poner toda la logica en el procedure
30 min*/
/*
9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.*/

/* adentro del trigger puedo invocar un procedure 
declaro un cursor con su logica poner el loop sobre el cursor
y adentro una linea que sea llamar al sp y toda la logica en el sp */
--mio 
create trigger ejer9
on item_factura
after update
as
begin

	declare @

end


/* 
updete item_factura set item_cantidad = item_cantidad +1
where item_producto ='falasds' and item_numero = 'asadjsaidja'

deleted tengo 4 ---> 5 en el inserted tengo 5
*/
CREATE TRIGGER ej9 
ON ITEM_FACTURA 
FOR UPDATE 
AS 
BEGIN
	DECLARE @COMPONENTE char(8),@CANTIDAD decimal(12,2)
	DECLARE cursorComponentes CURSOR FOR 
	SELECT c.comp_componente, (I.item_cantidad - d.item_cantidad)*c.comp_cantidad --ACA ES PARA VER CUNATO INVREMENTO
	FROM Composicion c
	INNER JOIN inserted I on c.comp_producto = i.item_producto 
	INNER JOIN deleted d on d.item_producto = i.item_producto AND d.item_tipo = i.item_tipo 
	AND d.item_sucursal = i.item_sucursal AND d.item_numero = i.item_numero 
	WHERE i.item_cantidad != d.item_cantidad --solo para los que cambiaron la cantiddad si modifico el precio no cambio nada 
--en el cursor joineo con composicion para asegurarme que sea un articulo compuesto
/*y tomo el inserted y deleted para chequear que no hay un camnio de cantidades */
	OPEN cursorComponentes
	FETCH NEXT FROM cursorComponentes 
	INTO @COMPONENTE,@CANTIDAD
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @CANTIDAD
		WHERE stoc_producto = @COMPONENTE AND STOC_DEPOSITO = (SELECT TOP 1 STOC_DEPOSITO FROM STOCK
									 WHERE STOC_PRODUCTO = @COMPONENTE ORDER BY STOC_CANTIDAD DESC)
		FETCH NEXT FROM cursorComponentes
		INTO @COMPONENTE,@CANTIDAD
	END
	CLOSE cursorComponentes
	DEALLOCATE cursorComponentes
END

/*
PARA PROBAR SI RESTA EL STOCK Y SI RESTA ESTA BIEN TODO
USE [GD2015C1]
GO

SELECT [comp_cantidad]
      ,[comp_producto]
      ,[comp_componente]
  FROM [dbo].[Composicion]

GO

-- factura A sucursal 0003 item_numero 00092524 00001707 

--00001707 tiene 1 unidad de 00001491  y 2 unidades del 00014003

SELECT * FROM Item_Factura WHERE item_producto in
(select comp_producto from Composicion)


select * from stock s 
where s.stoc_producto in ('00001491','00014003')
order by s.stoc_deposito, s.stoc_producto

deposito 00 tiene a los 2
deposito 00 tiene a los 2

update Item_Factura set item_cantidad = item_cantidad + 10
where item_tipo = 'A' and item_sucursal = '0003' and item_numero = '00092524'
and item_producto = '00001707'

--para ver los datos
select * from stock s 
where s.stoc_producto in ('00001491','00014003')
order by s.stoc_deposito, s.stoc_producto
*/

/*
10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.

Concepto 
Hay una tabla que es de productos donde esta todo el catalogo y una tabla 
donde esta el stock de ese producto en distintos depositos
ejem: un celular de una marca determinada que esta en 10 depositos 
Si hay stock en los depositos no tiene que permitir el borrado
Ahora si no tiene stock en ningun lado si tiene qu epermitirlo
Dejar que el delete fluya

En el modelo puede que el modelo de culular figure como registro en un deposito
pero con stock 0 o nulo y ante esto debemos hacer un 
borrado en casacada, se debe borrar el que dice
stock 0 para que permita despues hacer el delete
Entonces si el obejto es 1 solo o mas , sobre que tabla  y cuales serian los eventos

si hago un instead of 

Forma de Pensando : tenmos 1 tabla de Productos donde esta todo el catalogo
t una tabla que tenemos el stock de ese producto en distintos depositos
si hay stock en los depositos no debe permitir el borrado,
si hay algun stock si tiene que permitirlo dejear el delete

Puede que el modelo celular figure un registro en el deposito pero que tengo stock 0 o null
y deberia de hacer una opracion de borrrado en cascada 
borrar el stock 0 para que permita despues hacer el delete, con stock negativo los borra 

TABLA: PRODUCTO

EVENTO/S:  DELETE

MOMENTO: INSTEAD OF 

FUNCIONALIDAD:
CHEQUEO DE SI HAY REGISTROS CON STOCK > 0
       ROLLBACK Y RETURN //debe inpedir o mandar un mensaje

CHEQUEO DE SI HAY REGISTROS CON STOCK <= 0
       BORRARLOS

REPLICAR EL EVENTO DE DELETE.

Nose si la OPERACION arraco con ese delete o con otra cosa 
enotnces usa el instead o, porque puede venir en cascada con otra cosa 


10. Crear el/los objetos de base de datos que ante el
intento de borrar un artículo verifique que no exista 
stock y si es así lo borre en caso contrario que emita un
mensaje de error.
*/

create trigger tr_borrar_articulo
on Producto
instead of delete 
as 
begin 

	if exists (
	select 1 
	from deleted d
	inner join STOCK s on d.prod_codigo= s.stoc_producto
	where s.stoc_cantidad > 0 and
	exists(select 1 from Producto p1 where p1.prod_codigo = d.prod_codigo))


end





CREATE TRIGGER dbo.tr_articulo_safe_delete
ON Producto
INSTEAD OF DELETE
AS
BEGIN --si es sobre una tabla transaccional no se puede hacer un update en un registro
    IF EXISTS(SELECT 1 --Ahora HAGO el select sobre una tabla chica no sobre la base completa//antes DELETED p era PRODUCTO
              FROM DELETED p
				INNER JOIN STOCK s ON p.prod_codigo = s.stoc_producto
              WHERE s.stoc_producto > 0
                AND EXISTS(SELECT 1 FROM Producto D WHERE D.prod_codigo = p.prod_codigo))
        BEGIN
            ROLLBACK TRANSACTION
            RETURN
        END
--ES NECESARIO EL segundo if elemina los que tiene stock 0
    IF EXISTS(SELECT 1
              FROM Producto p
                       INNER JOIN STOCK s ON p.prod_codigo = s.stoc_producto
              WHERE s.stoc_producto <= 0
                AND EXISTS(SELECT 1 FROM DELETED D WHERE D.prod_codigo = p.prod_codigo))
        BEGIN
            DELETE
            FROM STOCK
            WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED)
            DELETE
            FROM Producto
            WHERE prod_codigo IN (SELECT prod_codigo FROM DELETED)
        END


--------
CREATE TRIGGER dbo.tr_articulo_safe_deletev1
    ON Producto
    INSTEAD OF DELETE
    AS
BEGIN
    IF EXISTS(SELECT 1
            FROM DELETED p
			INNER JOIN STOCK s ON p.prod_codigo = s.stoc_producto
			WHERE s.stoc_cantidad > 0
                AND EXISTS(SELECT 1 FROM Producto D WHERE D.prod_codigo = p.prod_codigo))--esta demas no va
        BEGIN
            ROLLBACK TRANSACTION
            RETURN
        END
--si no tuviera ninguno con stok 0
/*si hubiera registros con stock en 0 como va sin niguna condicion los
borra, si no hay ningun registro el delete da 0 filas y se sigue ejecutando 
en ningun momento hay errores la logica es la misma
Osea que no hace falta*/
            DELETE
            FROM STOCK
            WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED)
			
			DELETE
			FROM Producto
			WHERE prod_codigo IN (SELECT prod_codigo FROM DELETED)
END

--tambien se podria hacer con cursores y borrar de a uno
/*Pensado para el parcial
Se debe borrrar los de sotck y producto solo los que cumplan con las 
validadciones, */

--VERSION FINAL DE LA 2
CREATE TRIGGER dbo.tr_articulo_safe_delete_V2
ON Producto
INSTEAD OF DELETE
AS
BEGIn
		DELETE
		FROM STOCK
        WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED) AND ISNULL(stoc_cantidad,0) <= 0
--elimine los que se podian	
		DELETE
		FROM Producto
		WHERE prod_codigo IN (SELECT prod_codigo FROM DELETED)
		AND NOT EXISTS (SELECT 1 FROM stock s2 WHERE s2.stoc_producto = Producto.prod_codigo) 
--si quedo alguno quedo con una cantidad positiva y preguto si exite
END
GO

/*10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.*/
--el cursor es larga la sintaxis
--VERSION FINAL DE LA 1
CREATE TRIGGER dbo.tr_articulo_safe_delete_v1Final
    ON Producto
    INSTEAD OF DELETE
    AS
BEGIN
    IF EXISTS(SELECT 1
              FROM DELETED p
              INNER JOIN STOCK s ON p.prod_codigo = s.stoc_producto
              WHERE s.stoc_cantidad > 0)
        BEGIN
            ROLLBACK TRANSACTION
        RETURN
        END
            DELETE
            FROM STOCK
            WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED)
			
			DELETE
			FROM Producto
			WHERE prod_codigo IN (SELECT prod_codigo FROM DELETED)
END
--------mio pai
create trigger eje10 
on producto
instead of delete
as
begin

	if exists(
	select 1 from deleted d
	inner join STOCK s on d.prod_codigo = s.stoc_producto
	where s.stoc_cantidad > 0
	)
	rollback transaction
	return
	end
	
	delete 
	from STOCK
	where stoc_producto in (select prod_codigo from deleted)
	
	delete 
	from Producto
	where prod_codigo in (select prod_codigo from deleted)

end


/*eJERICICOS 11.
Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo.*/
/*
ESTE ES PARA HACER FUNCIONES CON CURSORES
fUNCIONES RECURSIVAS O CURSORES tomas un conj de fil y col y leerlo en loop
Ejercicio 2 tambien pide Cursores*/
--mio
create function fx_11(@p_cod_empl numeric(6))
returns int as
begin
	declare @cantidadEmpleados int = 0, @codigo_empl numeric(6)

	declare c_empleados cursor for
	select e.empl_codigo
	from Empleado e
	where e.empl_codigo > e.empl_jefe and
	@p_cod_empl = e.empl_jefe

	open c_empleados
	fetch next from c_empleados into @codigo_empl
	while(@@FETCH_STATUS = 0)
	begin
		set @cantidadEmpleados = @cantidadEmpleados + 1 + dbo.fx_11(@codigo_empl)
		fetch next from c_empleados into @codigo_empl
	end
	close c_empleados
	deallocate c_empleados
	return @cantidadEmpleados
end

--------------------
--ok
CREATE FUNCTION cantidad_empleados(@p_codigo_empleado NUMERIC(6))
    RETURNS INT AS
BEGIN
    DECLARE @c_empl_codigo NUMERIC(6),  @cantidad_empleados INT = 0
    DECLARE empleados CURSOR FOR
        SELECT e1.empl_codigo
        FROM Empleado e1
        WHERE e1.empl_jefe = @p_codigo_empleado
		AND e1.empl_codigo > e1.empl_jefe 
    
	OPEN empleados
    FETCH NEXT FROM empleados INTO @c_empl_codigo
    WHILE (@@FETCH_STATUS = 0)
        BEGIN
           SET @cantidad_empleados = @cantidad_empleados + 1 + dbo.cantidad_empleados(@c_empl_codigo)
    FETCH NEXT FROM empleados INTO @c_empl_codigo
        END
    CLOSE empleados
    DEALLOCATE empleados
    RETURN @cantidad_empleados
END



/*
CREATE FUNCTION cantidad_empleados(@param_codigo_empl NUMERIC (6))
RETURNS INT AS
BEGIN 
	DECLARE @c_empl_codigo NUMERIC(6),@cantidad_empleados INT = 0
	
	DECLARE c_empleados CURSOR FOR
		SELECT e1.empl_codigo
		FROM Empleado e1
		WHERE e1.empl_jefe = @param_codigo_empl
		AND e1.empl_codigo > e1.empl_jefe
		OPEN empleados
		FETCH NEXT FROM c_empleados INTO @c_empl_codigo
		WHILE (@@FETCH_STATUS = 0)
			BEGIN
				SET @cantidad_empleados = @cantidad_empleados +1 + 
				dbo.cantidad_empleados(@c_empl_codigo)
					
			FETCH NEXT FROM c_empleados INTO @c_empl_codigo
		CLOSE c_empleados
		DEALLOCATE c_empleados
		RETURN @cantidad_empleados
*/

			
--si el empleado es supervisor de 4 personas y 
--luego quiero poner obetener los 4 codigos y llamas 4 vesces
--a la function rcursiva

/*15. Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. No se
conocen los nivles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
select.
*/
--si dice pensado para trabajarlo, en un select el objeto tiene que ser una funcion

create function eje15(@prod char(8))
returns decimal (12,2) as
begin  
	declare @precio decimal (12,2) 
	
	select @precio =  
	from Producto p
	inner join Item_Factura i on p.prod_codigo = i.item_producto



	return @precio
end

CREATE FUNCTION EJer15(@PRODUCTO char(8))
RETURNS decimal (12,2)
AS 
BEGIN 
	DECLARE @precio decimal (12,2)
	IF (@PRODUCTO IN (SELECT comp_producto FROM Composicion))
		SET @precio = (
		SELECT SUM(dbo.ejer15(comp_componente)*comp_cantidad) 
		FROM Composicion 
		WHERE comp_producto = @PRODUCTO)
	ELSE
		SET @precio = (SELECT prod_precio FROM Producto WHERE @PRODUCTO = prod_codigo)
	RETURN @PRECIO
END

-----------------------------------
CREATE FUNCTION cantidad_empleados(@p_codigo_empleado NUMERIC(6))
    RETURNS INT AS
BEGIN
    DECLARE @c_empl_codigo NUMERIC(6),  @cantidad_empleados INT = 0
   
   DECLARE empleados CURSOR FOR
        SELECT e1.empl_codigo
        FROM Empleado e1
        WHERE e1.empl_jefe = @p_codigo_empleado
		AND e1.empl_codigo > e1.empl_jefe 
   
   OPEN empleados
    FETCH NEXT FROM empleados INTO @c_empl_codigo
    WHILE (@@FETCH_STATUS = 0)
        BEGIN
           SET @cantidad_empleados = @cantidad_empleados + 1 + dbo.cantidad_empleados(@c_empl_codigo)
        FETCH NEXT FROM empleados INTO @c_empl_codigo
        END
    CLOSE empleados
    DEALLOCATE empleados
    RETURN @cantidad_empleados
END

/*
17. Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock
*/
/*
STOCK

CANTIDAD MINIMA
hacer pedido del producto, haciendo en nuestro caso llevamos a la cantidad a la maxima
CANTIDAD

CANTIDAD MAXIMA
---------
TRIGGERS

STOCK

INSERT (CUMPIR LA REGLA)
UPDATE (MINIMA Y MAXIMA CUMPLIR LA REGLA)
UPDATE (CANTIDAD) ACTUALIZAR MAXIMA

INSTEAD OF / AFTER--puede ser cualqueira de los 2

insted of valido y si no cumple la regla realizo las operaciones, 
si no cumple regla saltar el error,
si cumple regla replicar operacion
--es mas corto el after
no hace falta usar cursosres pero se peude

17. Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock
*/

/*
Un update en un insert tiene que cumplir con la regla de negocio,
em el INSERT NO deberia ingresar directamente ese registro
y 
En el update, yo no puedo cambiar la cantidad minima
no deberia dejarlo
Si con la cantidad que tengo se deja 
de cumplir la regla Si tengo 50 la minima es 10 no
puedo pasar la minima a 60,

tembien deberia impedir modificar la cantidad maxima 
cuando deje de cumplir la regla
Si tengo 50 y la cant max es 200
La cantidad max no deberia pasar a valer 30

Si es un descuento de la cantidad, la cantidad 
avanzaria a la cant maxima 

RESOLVER CON TRIGGER PORQUE DICE AUTOMATICAMENTE

TABLAS STOCK

EVENTO insert update delete => este caso insert
insert debe cumplir la regla
update para minima y maxima cumplir la regla
y para cantidad una actualizacion

MOMENTO AFTER/INSTEAD OF
INSTEAD OF valido y si no cumple la regla 
realizar las operaciones, si no cumple error, 
si cumple replicar la operacion

Es mas CORTO el AFTER
2 TRIGGER DISTINTOS
Y EN EL UPADTE para saber cual se modifico
tendra que compararlo el del minimo con el maximo

Ej
if existe(un registro cambio minimo y el minimo por encima 
de la cantidad) => saltar error

ejercicio 17. Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock
*/

create trigger eje17
on stock
instead of insert,update
as
begin
	
	if exists(
	select 1 
	from 
	)
	update stock



end



CREATE TRIGGER tr_after_insert_ejercicio_17
    ON STOCK
    INSTEAD OF INSERT
    AS
BEGIN
    DECLARE @cant DECIMAL(12, 2),
        @min DECIMAL(12, 2),
        @max DECIMAL(12, 2),
        @prod CHAR(8),
        @depo CHAR(2),
        @detalle CHAR(100),
        @proxima_reposicion SMALLDATETIME
    DECLARE @to_insert DECIMAL(12, 2) = 0

    SELECT @cant = I.stoc_cantidad,
           @min = I.stoc_punto_reposicion,
           @max = I.stoc_stock_maximo,
           @detalle = I.stoc_detalle,
           @proxima_reposicion = I.stoc_proxima_reposicion,
           @prod = I.stoc_producto,
           @depo = I.stoc_deposito
    FROM INSERTED I

    IF (@cant <= @min)
        SET @to_insert = @max - @cant
    ELSE
        IF (@cant > @max) SET @to_insert = @cant - @max
INSERT INTO STOCK (stoc_cantidad, stoc_punto_reposicion, stoc_stock_maximo, stoc_detalle, stoc_proxima_reposicion,
                       stoc_producto, stoc_deposito)
    VALUES (@to_insert,
            @min,
            @max,
            @detalle,
            @proxima_reposicion,
            @prod,
            @depo)
END
GO

--POR MOSCU
CREATE TRIGGER tr_after_update_ejercicio_17 --update	
ON STOCK
AFTER UPDATE
AS
BEGIN
	    DECLARE @prod CHAR(8) 
		DECLARE @depo CHAR(2)
--en base a los if el select seria para llevarlo a un CURSOR	
		DECLARE c_stock CURSOR FOR 
		SELECT i.stoc_producto, i.stoc_deposito 
		FROM inserted i 
		inner join deleted d ON i.stoc_producto = d.stoc_producto 
		AND i.stoc_deposito = d.stoc_deposito 
	    WHERE i.stoc_cantidad < d.stoc_cantidad --se redujo el stock
		AND i.stoc_cantidad < i.stoc_punto_reposicion

--actaliza con el declare
		IF EXISTS (SELECT 1 FROM inserted i inner join deleted d ON i.stoc_producto = d.stoc_producto 
		AND i.stoc_deposito = d.stoc_deposito 
	    WHERE i.stoc_punto_reposicion > d.stoc_punto_reposicion AND i.stoc_punto_reposicion > i.stoc_cantidad)
		BEGIN
			ROLLBACK--si hace roolback es select del declare c_stock nunca se ejecuto
			RETURN
	    END
		--si se modifico la cantidad y es menor que el stock minimo lo mando a reponer al maximo de una
IF EXISTS (SELECT 1 FROM inserted i 
		inner join deleted d ON i.stoc_producto = d.stoc_producto 
		AND i.stoc_deposito = d.stoc_deposito 
	    WHERE i.stoc_cantidad < d.stoc_cantidad
		AND i.stoc_cantidad < i.stoc_punto_reposicion)
		BEGIN
			ROLLBACK
			RETURN
	    END
--El select del declare c_stock se ejecuta cuando llega si solo si al OPEN
--si tengo mas de un registro entonces tengo que usa un cursor
		OPEN c_stock
		FETCH NEXT FROM c_stock INTO @prod, @depo
		WHILE (@@FETCH_STATUS = 0)
		BEGIN

			UPDATE stock SET stoc_proxima_reposicion = GETDATE() --proxima reposicion la fecha de hoy 
			WHERE stoc_producto = @prod AND stoc_deposito = @depo

		FETCH NEXT FROM c_stock INTO @prod, @depo
		END
		CLOSE c_stock
		DEALLOCATE c_stock

END  
/*si lo que se odifico es la cantidad
y ademas la cantidad quedo por debajo 
del stock minimo la tengo que llevar
al stock maximo */	

/*Este trigger realiza dos verificaciones con 
condiciones de ROLLBACK:

Si se aumenta el punto de reposición pero 
el stock actual no es suficiente para satisfacerlo.

Si el stock se reduce por debajo del nivel 
mínimo sin acción de reposición.*/
------------------
IF EXISTS (SELECT 1 FROM inserted i 
		inner join deleted d ON i.stoc_producto = d.stoc_producto 
		AND i.stoc_deposito = d.stoc_deposito 
	    WHERE i.stoc_punto_reposicion > d.stoc_punto_reposicion 
		AND i.stoc_punto_reposicion > i.stoc_cantidad)
		BEGIN
			ROLLBACK
			RETURN
	    END

IF EXISTS (SELECT 1 FROM inserted i 
		inner join deleted d ON i.stoc_producto = d.stoc_producto 
		AND i.stoc_deposito = d.stoc_deposito 
	    WHERE i.stoc_stock_maximo < d.stoc_stock_maximo 
		AND i.stoc_stock_maximo < i.stoc_cantidad)
		BEGIN
			ROLLBACK
			RETURN
	    END

/*
--si se modifico la cantidad y ademas quedo 
--por debajo del stock minimo
--la tengo que llevar al stock maximo

como ocurre con muchos lo tengo que hacer con cursor o un 
update generico que tendria que coumpliser estas condiciones
*/
IF EXISTS (SELECT 1 FROM inserted i 
		inner join deleted d ON i.stoc_producto = d.stoc_producto 
		AND i.stoc_deposito = d.stoc_deposito 
	    WHERE i.stoc_stock_maximo < d.stoc_stock_maximo 
		AND i.stoc_stock_maximo < i.stoc_cantidad)
		BEGIN
			ROLLBACK
			RETURN
	    END
-------------------------------------
-------------------------
/*
8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por
cantidad de sus componentes, se aclara que un producto que compone a otro,
también puede estar compuesto por otros y así sucesivamente, la tabla se debe
crear y está formada por las siguientes columnas:

Código	Detalle			  Cantidad				Precio_generado		Precio_facturado

Código		Detalle		  Cantidad de			Precio que se		Precio del producto
del			del			  productos que			compone a través de
articulo	articulo	  conforman el combo	sus componentes


Crear la tabla y completar se peude hacer con ununico select
insert y un unico select

sp debe tener el create de la tabla mas su llenado
para quela tabla quede en la bd se ejecuta el sp
no va a tener parametrosA
*/
CREATE TABLE DIFERENCIAS
(
    codigo           CHAR(8) PRIMARY KEY,
    detalle          CHAR(100),
    cantidad         DECIMAL(12, 2),
    precio_generado  DECIMAL(12, 2),
    precio_facturado DECIMAL(12, 2)
)
GO

CREATE FUNCTION fx_calcular_precio_generado(@p_comp_producto_cod CHAR(8))
    RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @precio_generado DECIMAL(12, 2) = 0
    DECLARE @comp_codigo CHAR(8)
    DECLARE @comp_cantidad DECIMAL(12, 2)
    DECLARE componentes CURSOR FOR SELECT c.comp_componente, c.comp_cantidad
                                   FROM Composicion c
                                   WHERE c.comp_producto = @p_comp_producto_cod
    OPEN componentes
    FETCH NEXT FROM componentes INTO @comp_codigo, @comp_cantidad
    WHILE (@@FETCH_STATUS = 0)
        BEGIN
            SET @precio_generado += @comp_cantidad * dbo.fx_calcular_precio_generado(@comp_codigo)
            FETCH NEXT FROM componentes INTO @comp_codigo, @comp_cantidad
        END
CLOSE componentes
    DEALLOCATE componentes
    RETURN @precio_generado
END
GO

CREATE PROCEDURE sp_ej_08 AS
BEGIN
    INSERT INTO DIFERENCIAS (codigo, detalle, cantidad, precio_generado, precio_facturado)
    SELECT p.prod_codigo                              AS Código,
           p.prod_detalle                             AS Detalle,
           itf.item_cantidad                          AS Cantidad,
           dbo.fx_calcular_precio_generado(p.prod_codigo) AS Precio_generado,
           SUM(itf.item_precio)                       AS Precio_facturado
    FROM Producto p
             INNER JOIN Item_Factura itf ON p.prod_codigo = itf.item_producto
             INNER JOIN Composicion c ON p.prod_codigo = c.comp_producto
    WHERE itf.item_precio != dbo.fx_calcular_precio_generado(p.prod_codigo)
    GROUP BY p.prod_codigo, p.prod_detalle
END
GO

/*
22. Se requiere recategorizar los rubros de productos, de forma tal que nigun rubro
tenga más de 20 productos asignados, si un rubro tiene más de 20 productos
asignados se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada
--------------------------
procedure para modificar el caso de que no 
cumpla la nueva regla de negocio estan los distintos 
trigger para validar que la regla de nogocio que ya 
implementarion los procedure se sigan implementado

OBSERVACION

STORED PROCEDURE
RUBROS HASTA 20 PRODUCTOS INCLUVICO COMO MAXIMO
 RUBROS CON MAS DE 20 PRODUCTOS (WHILE)  RUBRO CON MAYOR CANTIDAD PRODUCTOS SIEMPRE QUE SEAN MAS DE 20
EN EL WHILE: TOMAR LOS QUE EXCEDEN DE 20:  REASIGNAR O CREAR NUEVO RUBRO Y REASIGNAR.  TODO LO HACE UN NUEVO SP.

Los datos del cursor se modifican entonces se hace con while
snapshot dual
ejecuto el cursor mientras proceso los datos del cursor se modificaron
No seria los mas apropiado
Con un while pongo la condicion tomo un rubro
lo trabaje y luego tomo otro, es el mismo concepto de bucle

CURSOR es apropiado cuando no hay modificaciones sobre los datos que leo(SOLO LECTURA)

TRIGGERS.
--------------
TRIGGER

TABLA/S:  PRODUCTO
 
EVENTOS:  INSERT UPDATE

MOMENTO AFTER

IF EXISTS (SELECT 1 FROM INSERTED .............)
BEGIN
     ROLLBACK
     RETURN
END
------------------
Cuando hay un UPDATE seri conveninente un AFTER para notener que hacer el 
UPDATE a mano porque seria mas largo
---------------

22
Se requiere recategorizar los rubros de productos, de forma 
tal que nigun rubro tenga más de 20 productos asignados,
si un rubro tiene más de 20 productos asignados 
se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro 
en la misma familia con la descirpción “RUBRO REASIGNADO”
, cree el/los objetos de base de datos necesarios 
para que dicha regla de negocio quede implementada
*/
create procedure 



CREATE PROCEDURE MueveProductoRubro(@RubroOrigen INT,@RubroDestino INT,@Restantes INT OUTPUT)
-- aca pongo cuantos faltaron reasignar y se lo devuelvo a la funcion que lo llamo
AS
BEGIN
-- veo cuanto espacio tengo disponible en el rubro destino
    DECLARE @EspacioRubro INT = 20 - (SELECT COUNT(*) 
									FROM Producto 
									WHERE prod_rubro = @RubroDestino);
-- si la cantidad a mover es menor a el espacio uso ese valor en caso 
--contrario muevo solo el espacio disponible
    DECLARE @CantidadMover INT = CASE 
								WHEN @EspacioRubro < @Restantes THEN @EspacioRubro 
								ELSE @Restantes END;

    -- Muevo la cantidad calculada en el paso anterior
    UPDATE TOP (@CantidadMover) Producto
    SET prod_rubro = @RubroDestino
    WHERE prod_rubro = @RubroOrigen;

    -- Actualizo la variable que usare como retorno, con cuantos productos quedaron por mover
    SET @Restantes = @Restantes - @CantidadMover;
END;
GO

CREATE PROCEDURE ReasignarProductos
AS
BEGIN
DECLARE @IdRubro INT;
DECLARE @NuevoRubro INT;
DECLARE @Cantidad INT;
DECLARE @Reasignar INT;

    -- Ejecuto el while mientras hayan rubros con mas de 20 productos
    WHILE EXISTS  (
        SELECT 1
        FROM Rubro AS r
        WHERE (SELECT COUNT(*) FROM Producto WHERE prod_rubro = r.rubr_id) > 20
    )
    BEGIN
   SELECT TOP 1
        @IdRubro = r.rubr_id,
        @Cantidad = (SELECT COUNT(*) FROM Producto WHERE prod_rubro = r.rubr_id)
        FROM Rubro AS r
        WHERE (SELECT COUNT(*) FROM Producto WHERE prod_rubro = r.rubr_id) > 20;

-- Aca calculo cuantos productos debo reasignar para dejar solo 20 en este rubro
SET @Reasignar = @Cantidad - 20;

-- Continuo mientras me queden productos a reasignar
        WHILE @Reasignar > 0
        BEGIN
            -- Busco un nuevo rubro con menos de 20 productos
            SET @NuevoRubro = (
                SELECT TOP 1 r.rubr_id
                FROM Rubro AS r
                WHERE r.rubr_id != @IdRubro
                AND (SELECT COUNT(*) FROM Producto WHERE prod_rubro = r.rubr_id) < 20
                ORDER BY NEWID()
            );

-- Si encuentro un rubro con espacio llamo al SP que mueve el producto
IF @NuevoRubro IS NOT NULL
BEGIN
-- llamo al SP que mueve los productos, pasandole rubro origen y destino,
-- y me quedo con la variable de retorno para seguir moviendo si no alcanzo el espacio
EXEC MueveProductoRubro @IdRubro, @NuevoRubro, @Reasignar OUTPUT;
END
            ELSE
BEGIN
-- si no hay espacio creo un nuevo rubro
INSERT INTO Rubro (rubr_id, rubr_detalle)
VALUES ((SELECT ISNULL(MAX(rubr_id), 0) + 1 FROM Rubro), 'RUBRO REASIGNADO');

SET @NuevoRubro = (SELECT MAX(rubr_id) FROM Rubro);

-- Reasignar productos al nuevo rubro creado
EXEC MueveProductoRubro @IdRubro, @NuevoRubro, @Reasignar OUTPUT;
END
GO
----------------------------------------------------------
CREATE TRIGGER chequearLimiteRubro
ON Producto
AFTER INSERT, UPDATE
AS --begin ni end podrian no ir porque el cuerpo ejecuta tiene solo una sola instruccion
    IF EXISTS (
        SELECT 1 FROM Producto 
		WHERE prod_rubro IN (SELECT DISTINCT prod_rubro FROM INSERTED)
        GROUP BY prod_rubro  
        HAVING COUNT(*) > 20
    )
        ROLLBACK TRANSACTION
		RETURN --como buena practica
GO
/*
Reubro electricidad
6 antes luego 8 que entraron 
Como ya se ejecuto entonces 6+8 = 14 > 20 falso y el select no devuleve nada
*/

----------mas simple del top 1
SELECT COUNT(*) - 20, prod_rubro 
FROM Producto
GROUP BY prod_rubro
Having COUNT(*) >20
--me deulve cuanto tengo que reasignar de cada rubro 
--porque a los 20 se reasigna
--------------------------------------------
/*
27. Se requiere reasignar los encargados de stock de los diferentes depósitos. Para
ello se solicita que realice el o los objetos de base de datos necesarios para
asignar a cada uno de los depósitos el encargado que le corresponda,
entendiendo que el encargado que le corresponde es cualquier empleado que no
es jefe y que no es vendedor, o sea, que no está asignado a ningun cliente, se
deberán ir asignando tratando de que un empleado solo tenga un deposito
asignado, en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado.
*/
--SIN EN UN PROCEDURE NO PONGO UN BEGIN O UN END Y FALLA VUELVE TODO PARA ATRAS

--trae el codigo de deposito mientras el encargao no este en la lista de
--los que no sean asignable,dETERMINA el proximo deposito a asignar
-- select para iterar mientras haya depositos a asignar, deberia estar en la condicion del while
select depo_codigo from deposito where depo_encargado not in (
SELECT e.empl_codigo 
FROM empleado e 
where not exists (select 1 from cliente c where e.empl_codigo = c.clie_vendedor) 
and not exists (SELECT 1 FROM empleado s where s.empl_jefe = e.empl_codigo)
)

--me indica el proximo empleado que voy a asignar
-- select para iterar mientras haya depositos a asignar
UPDATE deposito SET depo_encargado = (
SELECT TOP 1 e.empl_codigo 
FROM empleado e LEFT JOIN deposito d ON e.empl_codigo = d.depo_encargado 
where not exists (select 1 from cliente c where e.empl_codigo = c.clie_vendedor) 
and not exists (SELECT 1 FROM empleado s where s.empl_jefe = e.empl_codigo)
GROUP BY e.empl_codigo
ORDER BY COUNT(*))
WHERE depo_codigo = -- select depo_codigo variable tomada de arriba.

/*
itero el deposito disponibles y en otra funcion llamo a 
este que me va a devolver el proximo empleado asignable*/
-----------------------------------------------------------------------------
--empleado que no son ejefes y no pueden estar asignados como vendedores
select e.empl_codigo 
from Empleado e
where not exists
(select 1 from Cliente c 
where e.empl_codigo = c.clie_vendedor )
except
select s.empl_jefe from Empleado s
--son los empleados que pueden estar asignados a los depositos

select * from deposito where depo_encargado not in( 
select e.empl_codigo 
from Empleado e
where not exists 
(select 1 from Cliente c 
where e.empl_codigo = c.clie_vendedor )
except
select s.empl_jefe from Empleado s
) 
/*
--son los encargados del deposito que no estan entre los que se acepta 
--tengo que reasignarle el encargado

Me trae todos los depositos como acepta nulos no queiro voltaear todos
El que ya tenia un encargado si no tenia niguno lo dejo como esta, 
pero el encargado no es alguien que puede quedar asignado lo 
tengo que reasignar
*/
----------------------------------------------------

--me indica el proximo empleado que voy a asignar
-- select para iterar mientras haya depositos a asignar
select depo_codigo from deposito where depo_encargado not in (
SELECT e.empl_codigo 
FROM empleado e 
where not exists (select 1 from cliente c where e.empl_codigo = c.clie_vendedor) 
and not exists (SELECT 1 FROM empleado s where s.empl_jefe = e.empl_codigo)
)
--trae el codigo de deposito mientras el encargao no este en la lista de
--los que no sean asignable


/*
30 Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas

BOSERVAVION PARA RESOLVER
trigger

tabla/s item_factura

evento: insert

momento: after

if exists (select 1 ...)
begin 
rollback
raiseerror
end

month(getdate() year(getdate())=fechafact

Parcial pide
Armarse un pequenio dato de prueba apra el 2024
donde meto un item con 120 y esta
para ser una prueba minima tendria que ser una factura del 2024

armar o modificar un dato de prueba de los existentes
una factura del 2012 pasarla al 2024
y despues agregarle un item 
una para que de ok
y otro para dar el error

La idea es poder hacer un 
insert into item_factura sobre una factura que ya exista del 2024 
y poder probar

30.Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas
*/

-- agregar cursor ok 
CREATE TRIGGER t_compramaxima -- t-sql ej 30
ON dbo.Item_Factura
AFTER INSERT
AS
BEGIN
    DECLARE @ClienteCod CHAR(6)
    DECLARE @ProductoCod CHAR(8)
    DECLARE @Cantidad DECIMAL(12, 2)

    -- me traigo el cliente, producto y cantidad insertados
    SELECT
        @ClienteCod = f.fact_cliente,
        @ProductoCod = i.item_producto,
        @Cantidad = i.item_cantidad
	FROM inserted as i
	INNER JOIN Factura as f
	ON i.item_numero = f.fact_numero AND i.item_sucursal = f.fact_sucursal AND i.item_tipo = f.fact_tipo

    -- aca le sumo lo insertado a lo existente y veo si alguno sobrepasa las 100 unidades
    IF EXISTS (
        SELECT 1
        FROM dbo.Item_Factura as i
		INNER JOIN Factura as f
		ON i.item_numero = f.fact_numero AND i.item_sucursal = f.fact_sucursal 
		AND i.item_tipo = f.fact_tipo
        WHERE f.fact_cliente = @ClienteCod
        AND item_producto = @ProductoCod
        AND MONTH(f.fact_fecha) = MONTH(GETDATE()) AND YEAR(f.fact_fecha) = YEAR(GETDATE())
        GROUP BY f.fact_cliente, item_producto
        HAVING SUM(i.item_cantidad) + @Cantidad > 100
    )
    BEGIN
        -- si se sobrepaso el limite tiro el error
        ROLLBACK TRANSACTION
        RAISERROR('Limite de compra superado', 10, 1)
    END
END
--////////////////////////////
-- Resueldos git no checkeado


/*30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.*/

--mio
create trigger eje30
on
as
begin
	

end



--ok por git creo
CREATE TRIGGER dbo.Ejercicio30 
ON item_factura 
FOR INSERT
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)
	DECLARE @cantProducto decimal(12,2)
	DECLARE @itemsVendidosEnELMes int
	DECLARE @excedente int
	
	DECLARE cursor_ifact CURSOR FOR
	SELECT item_tipo,item_sucursal,item_numero,item_cantidad
	FROM inserted
	
	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@cantProducto
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @itemsVendidosEnELMes = (
								SELECT sum(item_cantidad)
								FROM Item_Factura
								INNER JOIN Factura
								ON fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
								WHERE item_producto = @producto
									AND fact_fecha = (SELECT MONTH(GETDATE()))
								)
		IF (@itemsVendidosEnELMes + @cantProducto) > 100
		BEGIN
			SET @excedente = (@itemsVendidosEnELMes + @cantProducto)-100
			DELETE FROM Item_Factura 
			WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
			DELETE FROM Factura 
			WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
			RAISERROR('No se puede comprar mas del producto %s, se superaron las unidades por %i',1,1,@producto,@excedente)
			ROLLBACK TRANSACTION
		END
		FETCH NEXT FROM cursor_ifact
		INTO @tipo,@sucursal,@numero,@cantProducto
	END
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
CLOSE

--Esta bien que borre la factura entera si un renglon no se puede ingresar?
---------------------------






--///////////////
/*
PARCIAL 

1. Sabiendo que un producto recurrente es aquel producto que al menos
se compró durante 6 meses en el último año.

Realizar una consulta SQL que muestre los clientes que tengan
productos recurrentes y de estos clientes mostrar:
i. El código de cliente.
ii. El nombre del producto más comprado del cliente.
iii. La cantidad comprada total del cliente en el último año.
Ordenar el resultado por el nombre del cliente alfabéticamente.


PUNTO 2 DEL MISMO EXAMEN

1. Implementar una restricción que no deje realizar operaciones masivas
sobre la tabla cliente. En caso de que esto se intente se deberá
registrar que operación se intentó realizar , en que fecha y hora y sobre
que datos se trató de realizar.



Masivo es una operación que afecta a mas de una fila

-------------

otro ej

Realizar una consulta SQL que muestre aquellos productos que tengan
entre 2 y 4 componentes distintos a nivel producto y cuyos
componentes no fueron todos vendidos (todos) en 2012 pero si en el
2011.
De estos productos mostrar:
i. El código de producto.
ii. El nombre del producto.
iii. El precio máximo al que se vendió en 2011 el producto.
El resultado deberá ser ordenado por cantidad de unidades vendidas
del producto en el 2011.



*/
/*
1. Sabiendo que un producto recurrente es aquel producto que al menos
se compró durante 6 meses en el último año.

Realizar una consulta SQL que muestre los clientes que tengan
productos recurrentes y de estos clientes mostrar:
i. El código de cliente.
ii. El nombre del producto más comprado del cliente.
iii. La cantidad comprada total del cliente en el último año.
Ordenar el resultado por el nombre del cliente alfabéticamente.


Nota: No se permiten select en el from, es decir, select … from (select …) as T,...
*/
SELECT
    c.clie_codigo AS codigo_del_cliente,
    c.clie_razon_social AS nombre,
    p.prod_detalle AS producto,
    SUM(ifact.item_cantidad) AS cantidad
FROM Factura f
JOIN cliente c ON f.fact_cliente = c.clie_codigo
JOIN item_factura ifact ON f.fact_tipo = ifact.item_tipo
    AND f.fact_sucursal = ifact.item_sucursal
    AND f.fact_numero = ifact.item_numero
JOIN producto p ON ifact.item_producto = p.prod_codigo
WHERE f.fact_fecha >= '2012-07-01 00:00:00'  
  AND f.fact_fecha < '2013-01-01 00:00:00'
  GROUP BY c.clie_codigo,c.clie_razon_social,p.prod_detalle
HAVING COUNT(DISTINCT MONTH(f.fact_fecha)) >= 6  
ORDER BY c.clie_razon_social ASC


---------------------
--ejercicioLaquiti
/* hacer un ejercicos q Cada vez que se inserte una
factura incorpore el fact_total en el campo empl_comision
*/
create trigger ejemEmpl
on Factura 
after insert
as
begin 
	
	declare @vend numeric(6,0)
	declare @total decimal(12,2)

	declare mi_cursor cursor for
	select fact_vendedor, fact_total
	select * 
	from inserted

	open mi_cursor
	fetch next from mi_cursor into @vend, @total
	while @@FETCH_STATUS = 0 
	begin
		print fact_vendedor
		update Empleado
		set empl_comision = empl_comision + @total
		where empl_codigo = @vend

	end
	close mi_cursor
	deallocate mi_cursor
end

/*
20. Crear el/los objeto/s necesarios para mantener 
actualizadas las comisiones del vendedor.
El cálculo de la comisión está dado por el 5% de 
la venta total efectuada por ese vendedor en ese mes,
más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.*/

select * from Empleado

create trigger tr_actuVendedor
on Factura
after update
as
begin

	declare @comision decimal(12,2)
	declare @fecha datetime
	declare @cod_vendedor numeric(6,0)
	
	declare c_facturas cursor for
	select fact_fecha, fact_cliente
	from inserted

	open c_facturas
	fetch next from c_facturas
	into @fecha, @cod_vendedor
	while(@@FETCH_STATUS = 0)
	begin 
		set @comision = 
		(select sum(f.fact_total) * (0.05 +
		case 
		when sum(distinct i.item_cantidad) > 50 then 0.03
		else 0 end)
		from Factura f
		inner join Item_Factura i
		on f.fact_tipo = i.item_tipo and f.fact_sucursal = i.item_sucursal
		and f.fact_numero = i.item_numero
		where f.fact_vendedor = @cod_vendedor and
		year(f.fact_fecha) = year(@fecha)
		and month(f.fact_fecha) = month(@fecha))

	update Empleado 
	set empl_comision = @comision
	where empl_codigo = @cod_vendedor
	fetch next from c_Facturas
	into @fecha, @cod_vendedor
	end

	close c_facturas
	deallocate c_facturas
end
---de git ok nose
SELECT * from Empleado

CREATE TRIGGER dbo.Ejercicio21 
ON Factura 
FOR INSERT
AS
BEGIN
	DECLARE @fecha smalldatetime, @vendedor numeric(6,0)
	DECLARE @comision decimal (12,2)
	
	DECLARE cursor_fact CURSOR FOR 
	SELECT fact_fecha,fact_vendedor
	FROM inserted
	
	OPEN cursor_fact
	FETCH NEXT FROM cursor_fact
	INTO @fecha,@vendedor
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @comision = 
			(SELECT SUM(item_precio*item_cantidad)*
			(0.05 + 
			CASE 
			WHEN COUNT(DISTINCT item_producto) > 50 THEN 0.03
			ELSE 0
			END
			)
			FROM Factura
			INNER JOIN Item_Factura
			ON item_tipo = fact_tipo AND item_sucursal 
			= fact_sucursal AND item_numero = fact_numero
			WHERE fact_vendedor = @vendedor
			AND YEAR(fact_fecha) = YEAR(@fecha)
			AND MONTH(fact_fecha) = MONTH(@fecha)
			)
		UPDATE Empleado SET empl_comision = @comision 
		WHERE empl_codigo = @vendedor
		FETCH NEXT FROM cursor_fact
		INTO @fecha,@vendedor
	END
	CLOSE cursor_fact
	DEALLOCATE cursor_fact
END
GO
------------
/*
21. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.
*/
CREATE TRIGGER ej21 
ON FACTURA 
FOR INSERT
AS
BEGIN
       IF exists(SELECT fact_numero+fact_sucursal+fact_tipo 
				FROM inserted 
				INNER JOIN Item_Factura
				ON item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo
				INNER JOIN Producto 
				ON prod_codigo = item_producto 
				JOIN Familia ON fami_id = prod_familia
                GROUP BY fact_numero+fact_sucursal+fact_tipo
                HAVING COUNT(distinct fami_id) <> 1 ) --si existen facturas con mas de una familia
		BEGIN
              DECLARE @NUMERO char(8),@SUCURSAL char(4),@TIPO char(1)
              
			  DECLARE cursorFacturas CURSOR FOR 
			  SELECT fact_numero,fact_sucursal,fact_tipo 
			  FROM inserted
              
			  OPEN cursorFacturas
              FETCH NEXT FROM cursorFacturas INTO @NUMERO,@SUCURSAL,@TIPO
              WHILE @@FETCH_STATUS = 0
              BEGIN
                     DELETE FROM Item_Factura 
					 WHERE item_numero+item_sucursal+item_tipo = @NUMERO+@SUCURSAL+@TIPO
                     
					 DELETE FROM Factura 
					 WHERE fact_numero+fact_sucursal+fact_tipo = @NUMERO+@SUCURSAL+@TIPO
                     
			  FETCH NEXT FROM cursorFacturas INTO @NUMERO,@SUCURSAL,@TIPO
              END
              CLOSE cursorFacturas
              DEALLOCATE cursorFacturas
              
			  RAISERROR ('no puede ingresar productos de mas de una familia en una misma factura.',1,1)
              ROLLBACK
       END
END

/*
23. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura.
*/

/*
26. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.*/

CREATE TRIGGER dbo.ejercicio26v2 
ON item_factura 
FOR Insert
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)

	DECLARE cursor_ifact CURSOR FOR SELECT item_tipo,item_sucursal,item_numero,item_producto
									FROM inserted

	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS(SELECT *
				  FROM Composicion
				  WHERE comp_componente = @producto)
		BEGIN
			DELETE FROM Factura WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
			DELETE FROM Item_Factura WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
			RAISERROR('EL producto a insertar es componente de otro producto, no se puede insertar en la factura',1,1)
			ROLLBACK TRANSACTION
		END
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	END
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
GO

---------
CREATE TRIGGER dbo.ejercicio26 ON item_factura INSTEAD OF Insert
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)
	DECLARE @cantidad decimal(12,2)
	DECLARE @precio decimal(12,2)

	DECLARE cursor_ifact CURSOR FOR SELECT *
									FROM inserted

	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS(SELECT *
				  FROM Composicion
				  WHERE comp_componente = @producto)
		BEGIN
			DELETE FROM Factura WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
			DELETE FROM Item_Factura WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
			RAISERROR('EL producto a insertar es componente de otro producto, no se puede insertar en la factura',1,1)
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			INSERT INTO Item_Factura
			VALUES (@tipo,@sucursal,@numero,@producto,@cantidad,@precio)
		END
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	END
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
GO
