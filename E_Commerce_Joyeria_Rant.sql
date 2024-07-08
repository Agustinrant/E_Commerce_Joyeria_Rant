-- Eliminar la base de datos existente si existe
DROP DATABASE IF EXISTS JoyeríaECommerce;

-- Crear la base de datos
CREATE DATABASE JoyeríaECommerce;
USE JoyeríaECommerce;

-- Creación de la tabla Ciudad
CREATE TABLE Ciudad (
    ID_Ciudad INT PRIMARY KEY AUTO_INCREMENT,
    País VARCHAR(50),
    Provincia VARCHAR(50),
    Codigo_Postal INT
);

-- Creación de la tabla Dirección
CREATE TABLE Direccion (
    ID_Direccion INT PRIMARY KEY AUTO_INCREMENT,
    ID_Cliente INT,
    ID_Ciudad INT,
    Calle VARCHAR(100),
    Altura VARCHAR(10),
    Piso VARCHAR(20),
    FOREIGN KEY (ID_Ciudad) REFERENCES Ciudad(ID_Ciudad)
);

-- Creación de la tabla Cliente
CREATE TABLE Cliente (
    ID_Cliente INT PRIMARY KEY AUTO_INCREMENT,
    ID_Direccion INT,
    Nombre VARCHAR(20),
    Apellido VARCHAR(20),
    Email VARCHAR(50),
    DNI VARCHAR(10),
    Telefono VARCHAR(20),
    Fecha_Registro DATETIME,
    FOREIGN KEY (ID_Direccion) REFERENCES Direccion(ID_Direccion)
);

-- Creación de la tabla Categoría
CREATE TABLE Categoría (
    ID_Categoria INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(50),
    Descripcion TEXT
);

-- Creación de la tabla Producto
CREATE TABLE Producto (
    ID_Producto INT PRIMARY KEY AUTO_INCREMENT,
    ID_Categoria INT,
    Nombre VARCHAR(50),
    Descripcion TEXT,
    Precio DECIMAL(10,2),
    Material VARCHAR(20),
    Talle INT,
    Stock INT,
    FOREIGN KEY (ID_Categoria) REFERENCES Categoría(ID_Categoria)
);

-- Creación de la tabla Almacen
CREATE TABLE Almacen (
    ID_Almacen INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(50),
    Ubicacion VARCHAR(200)
);

-- Creación de la tabla Inventario
CREATE TABLE Inventario (
    ID_Inventario INT PRIMARY KEY AUTO_INCREMENT,
    ID_Producto INT,
    ID_Almacen INT,
    Cantidad INT,
    FOREIGN KEY (ID_Producto) REFERENCES Producto(ID_Producto),
    FOREIGN KEY (ID_Almacen) REFERENCES Almacen(ID_Almacen)
);

-- Creación de la tabla Carrito
CREATE TABLE Carrito (
    ID_Carrito INT PRIMARY KEY AUTO_INCREMENT,
    ID_Cliente INT,
    FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente)
);

-- Creación de la tabla Pedido
CREATE TABLE Pedido (
    ID_Pedido INT PRIMARY KEY AUTO_INCREMENT,
    ID_Cliente INT,
    Fecha_Pedido DATETIME,
    Total DECIMAL(12,2),
    FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente)
);

-- Creación de la tabla Detalle_Pedido
CREATE TABLE Detalle_Pedido (
    ID_Detalle_Pedido INT PRIMARY KEY AUTO_INCREMENT,
    ID_Pedido INT,
    ID_Carrito INT,
    Cantidad INT,
    Precio_Unitario DECIMAL(10,2),
    Impuestos DECIMAL(10,2),
    FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID_Pedido),
    FOREIGN KEY (ID_Carrito) REFERENCES Carrito(ID_Carrito)
);

-- Creación de la tabla Detalle_Carrito
CREATE TABLE Detalle_Carrito (
    ID_Detalle_Carrito INT PRIMARY KEY AUTO_INCREMENT,
    ID_Carrito INT,
    ID_Producto INT,
    Cantidad INT,
    FOREIGN KEY (ID_Carrito) REFERENCES Carrito(ID_Carrito),
    FOREIGN KEY (ID_Producto) REFERENCES Producto(ID_Producto)
);