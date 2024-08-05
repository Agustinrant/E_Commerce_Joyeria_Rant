
-- eliminé la columna de stock en la tabla producto
ALTER TABLE producto
DROP COLUMN Stock;


USE joyeríaecommerce;

-- hubo un error en la carga de algunos datos en la tabla de direccion (los primeros 3 codigos no aparecían)
select * from direccion;
SELECT * FROM direccion WHERE ID_Cliente IS NULL;
UPDATE direccion
SET ID_Cliente = 1
WHERE ID_Direccion = 1;

UPDATE direccion
SET ID_Cliente = 2
WHERE ID_Direccion = 2;

UPDATE direccion
SET ID_Cliente = 3
WHERE ID_Direccion = 3;

-- Seleccion de Tablas
select * from direccion;
select * from producto;
select * from almacen;
select * from categoria;
select * from ciudad;
select * from inventario;
select * from pedido;
select * from cliente;
select * from carrito;
select * from detalle_carrito;
select * from detalle_pedido;

-- vista detalle pedidos
CREATE VIEW vista_detalle_pedidos AS
SELECT
    p.ID_Pedido,
    c.ID_Cliente,
    c.Nombre AS Nombre_Cliente,
    c.Apellido AS Apellido_Cliente,
    prod.ID_Producto,
    prod.Nombre AS Nombre_Producto,
    dp.Cantidad,
    c.ID_Direccion
FROM
    pedido p
JOIN
    cliente c ON p.ID_Cliente = c.ID_Cliente
JOIN
    detalle_pedido dp ON p.ID_Pedido = dp.ID_Pedido
JOIN
    carrito ca ON dp.ID_Carrito = ca.ID_Carrito
JOIN
    detalle_carrito dc ON ca.ID_Carrito = dc.ID_Carrito
JOIN
    producto prod ON dc.ID_Producto = prod.ID_Producto;
   -- seleccionar vista 
    SELECT * FROM vista_detalle_pedidos;
    
    
-- vista clientes que compraron más de 4 productos
CREATE VIEW clientes_mas_de_4_productos AS
SELECT
    c.ID_Cliente,
    c.Nombre,
    c.Apellido,
    c.Email,
    c.DNI,
    c.Telefono,
    c.Fecha_Registro,
    SUM(dp.Cantidad) AS Total_Productos_Comprados
FROM
    cliente c
JOIN
    pedido p ON c.ID_Cliente = p.ID_Cliente
JOIN
    detalle_pedido dp ON p.ID_Pedido = dp.ID_Pedido
GROUP BY
    c.ID_Cliente,
    c.Nombre,
    c.Apellido,
    c.Email,
    c.DNI,
    c.Telefono,
    c.Fecha_Registro
HAVING
    SUM(dp.Cantidad) > 4;
-- seleccionar vista
SELECT * FROM clientes_mas_de_4_productos;

-- vista clientes por ciudad
CREATE VIEW clientes_por_ciudad AS
SELECT
    ci.ID_Ciudad,
    ci.País,
    ci.Provincia,
    ci.Codigo_Postal,
    COUNT(c.ID_Cliente) AS Total_Clientes
FROM
    cliente c
JOIN
    direccion d ON c.ID_Direccion = d.ID_Direccion
JOIN
    ciudad ci ON d.ID_Ciudad = ci.ID_Ciudad
GROUP BY
    ci.ID_Ciudad,
    ci.País,
    ci.Provincia,
    ci.Codigo_Postal;
    -- seleccionar vista
    SELECT * FROM clientes_por_ciudad;

-- vista ingresos por ciudad
CREATE VIEW ingresos_por_ciudad AS
SELECT
    ci.ID_Ciudad,
    ci.País,
    ci.Provincia,
    ci.Codigo_Postal,
    SUM(p.Total) AS Total_Ingresos
FROM
    ciudad ci
JOIN
    direccion d ON ci.ID_Ciudad = d.ID_Ciudad
JOIN
    cliente c ON d.ID_Direccion = c.ID_Direccion
JOIN
    pedido p ON c.ID_Cliente = p.ID_Cliente
GROUP BY
    ci.ID_Ciudad, ci.País, ci.Provincia, ci.Codigo_Postal;
    -- seleccionar vista
    SELECT * FROM ingresos_por_ciudad;
    
    
    -- vista clientes que ingresaron cada año
CREATE VIEW clientes_por_año AS
SELECT
    YEAR(c.Fecha_Registro) AS Año_Registro,
    COUNT(c.ID_Cliente) AS Total_Clientes
FROM
    cliente c
GROUP BY
    YEAR(c.Fecha_Registro);
    -- seleccionar vista
 
    
    
    
    -- funcion total con impuestos
    
DELIMITER $$

CREATE FUNCTION CalcularTotalConImpuestos(precioUnitario DECIMAL(10,2), cantidad INT, tasaImpuesto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE totalConImpuestos DECIMAL(10,2);
    SET totalConImpuestos = ((precioUnitario + tasaImpuesto) * cantidad);
    RETURN totalConImpuestos;
END $$

DELIMITER ;
-- seleccionar funcion
SELECT ID_Detalle_Pedido, Precio_Unitario, Cantidad, Impuestos,
       CalcularTotalConImpuestos(Precio_Unitario, Cantidad, Impuestos) AS TotalConImpuestos
FROM detalle_pedido;


-- funcion antiguedad clientes
DELIMITER //

CREATE FUNCTION AntiguedadCliente(fechaRegistro DATE)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE antiguedad INT;
    SET antiguedad = YEAR(CURDATE()) - YEAR(fechaRegistro);
    IF MONTH(fechaRegistro) > MONTH(CURDATE()) OR (MONTH(fechaRegistro) = MONTH(CURDATE()) AND DAY(fechaRegistro) > DAY(CURDATE())) THEN
        SET antiguedad = antiguedad - 1;
    END IF;
    RETURN antiguedad;
END //

DELIMITER ;
-- select funcion (todos los clientes)
SELECT ID_Cliente, Nombre, Apellido, AntiguedadCliente(Fecha_Registro) AS Antiguedad
FROM cliente;


-- stored procedure agregar cliente nuevo
DELIMITER $$

CREATE PROCEDURE AddCliente(
    IN pNombre VARCHAR(255),
    IN pApellido VARCHAR(255),
    IN pEmail VARCHAR(255),
    IN pDNI VARCHAR(255),
    IN pTelefono VARCHAR(255),
    IN pFechaRegistro DATE
)
BEGIN
    INSERT INTO cliente (Nombre, Apellido, Email, DNI, Telefono, Fecha_Registro)
    VALUES (pNombre, pApellido, pEmail, pDNI, pTelefono, pFechaRegistro);
END $$

DELIMITER ;
-- usar el procedimiento
CALL AddCliente('Juanito', 'Montana', 'juanitomontana@gmail.com', '12345678', '555-1234', '2021-06-01');


-- stored procedure cambiar stock
DELIMITER $$

CREATE PROCEDURE UpdateStock(
    IN pProductoID INT,
    IN pCantidadCambiada INT
)
BEGIN
    UPDATE producto
    SET Stock = Stock + pCantidadCambiada
    WHERE ID_Producto = pProductoID;
END $$

DELIMITER ;
-- usar procedimiento
CALL UpdateStock(1, -2); -- Resta 2 del stock del producto con ID 1

-- trigger registrar datos cambiados
DELIMITER $$

CREATE TRIGGER BeforeClienteUpdate
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    IF OLD.Email <> NEW.Email OR OLD.Telefono <> NEW.Telefono THEN
        INSERT INTO cliente_cambios (ID_Cliente, Email_Antiguo, Email_Nuevo, Telefono_Antiguo, Telefono_Nuevo, Fecha_Cambio)
        VALUES (OLD.ID_Cliente, OLD.Email, NEW.Email, OLD.Telefono, NEW.Telefono, NOW());
    END IF;
END $$

DELIMITER ;
-- creacion de tabla clientes_cambios -- donde se guarda la info vieja
CREATE TABLE cliente_cambios (
    ID_Cambio INT AUTO_INCREMENT PRIMARY KEY,
    ID_Cliente INT,
    Email_Antiguo VARCHAR(255),
    Email_Nuevo VARCHAR(255),
    Telefono_Antiguo VARCHAR(255),
    Telefono_Nuevo VARCHAR(255),
    Fecha_Cambio DATETIME
);
-- revisar la tabla
SELECT * FROM cliente_cambios;

-- prueba creacion y cambio cliente
INSERT INTO cliente (Nombre, Apellido, Email, DNI, Telefono, Fecha_Registro)
VALUES ('Test', 'User', 'testuser@example.com', '123456789', '123-456-7890', CURDATE());
UPDATE cliente
SET Email = 'newemail@example.com', Telefono = '987-654-3210'
WHERE ID_Cliente = 1;


-- trigger para actualizar el inventario al llenar el carrito
DELIMITER $$

CREATE TRIGGER UpdateInventoryAfterSale
AFTER INSERT ON detalle_carrito
FOR EACH ROW
BEGIN
    -- Reducir el inventario del producto vendido
    UPDATE inventario
    SET Cantidad = Cantidad - NEW.Cantidad
    WHERE ID_Producto = NEW.ID_Producto;
END $$

DELIMITER ;