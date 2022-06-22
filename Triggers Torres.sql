DROP DATABASE IF EXISTS proyecto_alpha;
CREATE DATABASE proyecto_alpha;

USE proyecto_alpha; /* Selecciona el scheme creado. */

CREATE TABLE if NOT EXISTS farmacia(

id_farmacia int primary key,
stock_farmaco varchar(50) NOT NULL,
nombre_farmaco varchar(100) NOT NULL,
precio_farmaco float NOT NULL,
descripcion_farmaco varchar(50) NOT NULL

);


CREATE TABLE if NOT EXISTS receta(

id_receta int primary key,
dosis float NOT NULL,
farmaco_recetado varchar(100) NOT NULL,
validez_receta date NOT NULL,
frecuencia_uso time NOT NULL

);

CREATE TABLE if NOT EXISTS historialClinico(

id_historialClinico int primary key,
nombre_medico varchar(50) NOT NULL,
numero_medico varchar(80) NOT NULL,
observacion varchar(150) NULL,
especialidad varchar(50) NOT NULL,
fecha_citada date NOT NULL

);

CREATE TABLE if NOT EXISTS obraSocial(

id_obraSocial int primary key,
telefono_cliente varchar(100) NULL,
nombre_cliente varchar(50) NOT NULL,
apellido_cliente varchar(50) NOT NULL,
nombre_obraSocial varchar(50) NOT NULL,
email varchar(50) NULL,
numero_socio int NOT NULL

);

CREATE TABLE if NOT EXISTS cliente(

/* Creacion de Foreign keys*/
id_obra_social int NOT NULL,
idreceta int NOT NULL,
id_histclinico int NOT NULL,
id_farm int NOT NULL,

/* Resto de los datos */

id_cliente int primary key,
nombre_cliente varchar(50) NOT NULL,
apellido_cliente varchar(50) NOT NULL,
dni_cliente int NOT NULL,
telefono_cliente varchar(100) NULL,
email varchar(50) NULL,

/* Referencias a las Foreign keys */
FOREIGN KEY (id_obra_social) REFERENCES obraSocial(id_obraSocial),
FOREIGN KEY (idreceta) REFERENCES receta(id_receta),
FOREIGN KEY (id_histclinico) REFERENCES historialClinico(id_historialClinico),
FOREIGN KEY (id_farm) REFERENCES farmacia(id_farmacia)

);

show tables;

create VIEW v_cliente as SELECT nombre_cliente, apellido_cliente, dni_cliente, telefono_cliente, email from cliente;

SELECT * FROM v_cliente;

create VIEW v_farmaco as SELECT nombre_farmaco, precio_farmaco, descripcion_farmaco from farmacia;

SELECT * FROM v_farmaco;

create VIEW v_obra_cliente as SELECT cliente.id_cliente, cliente.nombre_cliente, cliente.apellido_cliente, obraSocial.id_obrasocial, obraSocial.nombre_obrasocial, obraSocial.numero_socio from cliente, obraSocial WHERE cliente.id_obra_social = obraSocial.id_obraSocial;

SELECT * FROM v_obra_cliente;

create VIEW v_historial_cliente as SELECT cliente.id_cliente, cliente.nombre_cliente, cliente.apellido_cliente, historialClinico.id_historialClinico,  historialClinico.nombre_medico, historialClinico.numero_medico, historialClinico.observacion from cliente, historialClinico WHERE cliente.id_histclinico = historialClinico.id_historialClinico;

SELECT * FROM v_historial_cliente;

create VIEW v_receta_cliente as SELECT cliente.id_cliente, cliente.nombre_cliente, cliente.apellido_cliente, receta.id_receta,  receta.farmaco_recetado,  receta.dosis from cliente, receta WHERE cliente.idreceta = receta.id_receta;

SELECT * FROM v_receta_cliente;


DELIMITER //

create function farmaco_en_stock(nombre_farmaco varchar(100), stock_farmaco int) 
returns varchar(50)
deterministic
begin
declare mensaje varchar(50);
if stock_farmaco = '0' then
set mensaje = 'No hay';
else
set mensaje = 'Si hay';
end if;

return mensaje;

end//

delimiter ;


SELECT * FROM farmacia;
SELECT nombre_farmaco, farmaco_en_stock(nombre_farmaco, stock_farmaco) from farmacia;



DELIMITER //

create function dato_cliente_general(dni_cliente int) 
returns varchar(50)
deterministic
begin
declare mensaje varchar(50);


if dni_cliente < 15000000 then
set mensaje = 'Es mayor de 60';
else
set mensaje = 'Cliente regular';
end if;

return mensaje;

end//

delimiter ;




SELECT * FROM obrasocial;
SELECT * FROM cliente;

SELECT cliente.dni_cliente, obraSocial.numero_socio,  
obraSocial.nombre_obraSocial, dato_cliente_general(cliente.dni_cliente) 

from cliente, obraSocial WHERE cliente.id_obra_social = obraSocial.id_obraSocial;


/* FUNCIONES DE STORED PROCEDURE */
/*DROP procedure orden_farmaco;*/


DELIMITER //

create procedure orden_farmaco(in campo_farmaco varchar(50), OUT descendente INT) 
begin

SET descendente = (SELECT MIN(precio_farmaco) 

FROM farmacia WHERE farmacia.nombre_farmaco = campo_farmaco

);

end//

delimiter ;

SELECT * FROM farmacia;

CALL orden_farmaco('nombre_farmaco', @descendente);
SELECT * FROM farmacia;

/*DROP procedure ingreso_farmaco;*/


DELIMITER //

create procedure ingreso_farmaco(nuevo_farmaco varchar(50), precio_nuevo float, descripcion_nuevo varchar(100)) 
begin

INSERT INTO farmacia(id_farmacia) VALUES ('1');

INSERT INTO farmacia(nombre_farmaco) VALUES (nuevo_farmaco);
INSERT INTO farmacia(stock_farmaco) VALUES (0);
INSERT INTO farmacia(precio_farmaco) VALUES (precio_nuevo);
INSERT INTO farmacia(descripcion_farmaco) VALUES (descripcion_nuevo);

end//

delimiter ;

SELECT * FROM farmacia;

CALL ingreso_farmaco('nuevo_farmaco', 2.50, 'Test');
SELECT * FROM farmacia;

/* Por falta de tiempo el ultimo no lo logre hacer funcionarpuesto que me dice que stock_farmaco no tiene un valor por deafault*/

DELIMITER //

CREATE TRIGGER agregar_farmaco AFTER INSERT ON farmacia
	FOR EACH ROW
   
    
	BEGIN
	  INSERT INTO farmacia_log (action, hora, fecha, user, stock_farmaco, nombre_Farmaco, precio_Farmaco, descripcion_farmaco)
      
	  VALUES('insert',CURRENT_TIME(), CURRENT_DATE(), USER(), NEW.stock_farmaco, NEW.nombre_Farmaco, NEW.precio_Farmaco, NEW.descripcion_farmaco);
      
	END;
    
    
	CREATE TRIGGER update_farmaco AFTER INSERT ON data
    
     BEGIN
	  INSERT INTO farmacia_log_before (action, hora, fecha, user,stock_farmaco, nombre_Farmaco, precio_Farmaco, descripcion_farmaco)
      
	  VALUES('pre-update',CURRENT_TIME(), CURRENT_DATE(), USER(), OLD.stock_farmaco, OLD.nombre_Farmaco, OLD.precio_Farmaco, OLD.descripcion_farmaco);
      
	END;
    
	FOR EACH ROW
	BEGIN
	INSERT INTO farmacia_log_after (action, hora, fecha, user, stock_farmaco, nombre_Farmaco, precio_Farmaco, descripcion_farmaco)
      
	  VALUES('update',CURRENT_TIME(), CURRENT_DATE(), USER(), NEW.stock_farmaco, NEW.nombre_Farmaco, NEW.precio_Farmaco, NEW.descripcion_farmaco);
	END;
    
    
	CREATE TRIGGER delete_farmaco AFTER INSERT ON data
	FOR EACH ROW
	BEGIN
	  INSERT INTO farmacia_log (action, hora, fecha, user, stock_farmaco, nombre_Farmaco, precio_Farmaco, descripcion_farmaco)
      
	  VALUES('borrar',CURRENT_TIME(), CURRENT_DATE(), USER(), OLD.stock_farmaco, OLD.nombre_Farmaco, OLD.precio_Farmaco, OLD.descripcion_farmaco);
	END;
    
    delimiter ;
    
    DELIMITER //


	BEGIN
	  INSERT INTO receta_log (action, hora, fecha, user, id, dosis, farmaco_recetado, validez_receta, frecuencia_uso)
      
	  VALUES('insert',CURRENT_TIME(), CURRENT_DATE(), USER(), NEW.id, NEW.dosis, NEW.farmaco_recetado, NEW.validez_receta, NEW.frecuencia_uso);
      
	END;
    
    
	CREATE TRIGGER update_receta AFTER INSERT ON receta
    
     BEGIN
	  INSERT INTO receta_log_before (action, hora, fecha, user, id, dosis, farmaco_recetado, validez_receta, frecuencia_uso)
      
	  VALUES('pre-update',CURRENT_TIME(), CURRENT_DATE(), USER(), OLD.id, OLD.dosis, OLD.farmaco_recetado, OLD.validez_receta, OLD.frecuencia_uso);
      
	END;
    
	FOR EACH ROW
	BEGIN
	INSERT INTO receta_log_after (action, hora, fecha, user, id, dosis, farmaco_recetado, validez_receta, frecuencia_uso)
      
	  VALUES('update',CURRENT_TIME(), CURRENT_DATE(), USER(), NEW.stock_farmaco, NEW.nombre_Farmaco, NEW.precio_Farmaco, NEW.descripcion_farmaco);
	END;
    
    
	CREATE TRIGGER delete_receta AFTER INSERT ON receta
	FOR EACH ROW
	BEGIN
	  INSERT INTO receta_log (action, hora, fecha, user, id, dosis, farmaco_recetado, validez_receta, frecuencia_uso)
      
	  VALUES('borrar',CURRENT_TIME(), CURRENT_DATE(), USER(), OLD.id, OLD.dosis, OLD.farmaco_recetado, OLD.validez_receta, OLD.frecuencia_uso);
	END;
    
    delimiter ;