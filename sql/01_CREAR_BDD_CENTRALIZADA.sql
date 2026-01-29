-- =============================================
-- Script de Creación: Base de Datos Centralizada
-- Sistema: Sueños de Tela
-- Nodo: QUITO (Central)
-- Modificado para Vistas Particionadas (sin IDENTITY)
-- =============================================

CREATE DATABASE SueñoDeTela;
GO
USE SueñoDeTela;
GO

-- =============================================
-- TABLAS REPLICADAS (Sin fragmentación)
-- =============================================

CREATE TABLE Sucursal (
    idSucursal CHAR(3) NOT NULL,
    nombreSucursal VARCHAR(30) NOT NULL,
    direccionSucursal VARCHAR(50) NOT NULL,
    contactoSucursal VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Sucursal PRIMARY KEY (idSucursal)
);

CREATE TABLE Proveedor (
    idProveedor INT NOT NULL,
    nombreProveedor VARCHAR(30) NOT NULL,
    contactoProveedor VARCHAR(20) NULL,
    direccionProveedor VARCHAR(50) NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (idProveedor)
);

CREATE TABLE Producto (
    idProducto INT NOT NULL,
    nombreProducto VARCHAR(20) NOT NULL,
    precio DECIMAL(6,2) NOT NULL,
    talla DECIMAL(5,2) NULL,
    categoria VARCHAR(20) NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (idProducto)
);

CREATE TABLE Producto_Proveedor (
    idProducto INT NOT NULL,
    idProveedor INT NOT NULL,
    cantidadSuministro SMALLINT NOT NULL,
    fechaSuministro DATETIME NOT NULL,
    CONSTRAINT PK_Producto_Proveedor PRIMARY KEY (idProducto, idProveedor),
    CONSTRAINT FK_PP_Proveedor
        FOREIGN KEY (idProveedor) 
        REFERENCES Proveedor(idProveedor)
        ON DELETE CASCADE,
    CONSTRAINT FK_PP_Producto
        FOREIGN KEY (idProducto) 
        REFERENCES Producto(idProducto)
        ON DELETE CASCADE
);

-- =============================================
-- TABLAS FRAGMENTADAS
-- =============================================

-- Tabla Cliente (Fragmentación Mixta: Vertical + Horizontal)
CREATE TABLE Cliente (
    idCliente INT NOT NULL,
    idSucursal CHAR(3) NOT NULL,
    cedula VARCHAR(10) NULL,
    nombre VARCHAR(30) NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    ciudad VARCHAR(20) NOT NULL,
    telefono VARCHAR(10) NULL,
    correo VARCHAR(50) NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (idCliente),
    CONSTRAINT FK_Cliente_Sucursal
        FOREIGN KEY (idSucursal) 
        REFERENCES Sucursal(idSucursal)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

-- Tabla Inventario (Fragmentación Horizontal)
CREATE TABLE Inventario (
    idSucursal CHAR(3) NOT NULL,
    idProducto INT NOT NULL,
    stock SMALLINT NOT NULL,
    CONSTRAINT PK_Inventario PRIMARY KEY (idSucursal, idProducto),
    CONSTRAINT FK_Inventario_Producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Inventario_Sucursal
        FOREIGN KEY (idSucursal) REFERENCES Sucursal(idSucursal)
        ON DELETE NO ACTION
        ON UPDATE CASCADE    
);

-- Tabla Pedido (Fragmentación Horizontal)
CREATE TABLE Pedido (
    idPedido INT NOT NULL,
    idCliente INT NOT NULL,
    idSucursal CHAR(3) NOT NULL,
    fecha DATETIME NOT NULL,
    total DECIMAL(6,2) NOT NULL,
    CONSTRAINT PK_Pedido PRIMARY KEY (idPedido),
    CONSTRAINT FK_Pedido_Cliente
        FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Pedido_Sucursal
        FOREIGN KEY (idSucursal) REFERENCES Sucursal(idSucursal)
        ON DELETE NO ACTION
);

-- Tabla DetallePedido (Fragmentación Horizontal Derivada)
CREATE TABLE DetallePedido (
    idDetalle INT NOT NULL,
    idPedido INT NOT NULL,
    idProducto INT NOT NULL,
    cantidad SMALLINT NOT NULL,
    precio_unitario DECIMAL(6,2) NULL,
    CONSTRAINT PK_DetallePedido PRIMARY KEY (idDetalle, idPedido),
    CONSTRAINT FK_DetallePedido_Pedido
        FOREIGN KEY (idPedido) 
        REFERENCES Pedido(idPedido)
        ON DELETE CASCADE,
    CONSTRAINT FK_DetallePedido_Producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON DELETE NO ACTION
);


-- =============================================
-- DATOS INICIALES
-- =============================================

INSERT INTO Sucursal VALUES
('UIO','Quito Centro','Av. Amazonas','022345678'),
('GYE','Guayaquil Norte','Av. Francisco Orellana','042345678');

INSERT INTO Proveedor (idProveedor, nombreProveedor, contactoProveedor, direccionProveedor) VALUES
(1, 'Textiles Andinos','0991111111','Quito'),
(2, 'Moda Global','0992222222','Guayaquil'),
(3, 'Fibras del Sur','0993333333','Cuenca'),
(4, 'Distribuidora Norte','0994444444','Quito');

INSERT INTO Producto (idProducto, nombreProducto, precio, talla, categoria) VALUES
(1, 'Camiseta Básica',12.50,38,'Ropa'),
(2, 'Pantalón Jean',25.00,40,'Ropa'),
(3, 'Chaqueta',45.00,42,'Ropa'),
(4, 'Vestido Casual',35.00,36,'Ropa'),
(5, 'Camisa Formal',28.00,39,'Ropa'),
(6, 'Blusa',22.00,36,'Ropa'),
(7, 'Short',18.00,38,'Ropa'),
(8, 'Falda',20.00,36,'Ropa'),
(9, 'Abrigo',60.00,44,'Ropa'),
(10, 'Sudadera',30.00,40,'Ropa'),
(11, 'Polo',15.00,38,'Ropa'),
(12, 'Leggings',19.00,36,'Ropa'),
(13, 'Top Deportivo',14.00,36,'Ropa'),
(14, 'Jogger',27.00,40,'Ropa'),
(15, 'Chompa',50.00,42,'Ropa'),
(16, 'Blazer',55.00,42,'Ropa'),
(17, 'Camisa Manga Corta',24.00,39,'Ropa'),
(18, 'Pijama',29.00,38,'Ropa'),
(19, 'Buzo',32.00,40,'Ropa'),
(20, 'Chaleco',26.00,42,'Ropa');

INSERT INTO Cliente (idCliente, idSucursal, cedula, nombre, apellido, ciudad, telefono, correo) VALUES
(1, 'UIO','1710034065','Ana','Pérez','Quito','0991234567','ana@mail.com'),
(2, 'UIO','1712345678','Luis','Gómez','Quito','0987654321','luis@mail.com'),
(3, 'UIO','1709876544','María','López','Quito','0976543210','maria@mail.com'),
(4, 'UIO','1723456781','Carlos','Vera','Quito','0965432109','carlos@mail.com'),
(5, 'UIO','1704567893','Elena','Ríos','Quito','0954321098','elena@mail.com'),
(6, 'GYE','0923456789','Pedro','Mendoza','Guayaquil','0998765432','pedro@mail.com'),
(7, 'GYE','0912345675','Lucía','Torres','Guayaquil','0982345678','lucia@mail.com'),
(8, 'GYE','0909876543','Jorge','Castro','Guayaquil','0973456789','jorge@mail.com'),
(9, 'GYE','0924567896','Paola','Suárez','Guayaquil','0964567890','paola@mail.com'),
(10, 'GYE','0910987654','Daniel','Morales','Guayaquil','0955678901','daniel@mail.com'),
(11, 'UIO','1713456782','Sofía','León','Quito','0946789012','sofia@mail.com'),
(12, 'UIO','1702345679','Miguel','Cruz','Quito','0937890123','miguel@mail.com'),
(13, 'UIO','1720987657','Andrea','Salas','Quito','0928901234','andrea@mail.com'),
(14, 'GYE','0918765438','Fernando','Paz','Guayaquil','0999012345','fernando@mail.com'),
(15, 'GYE','0921098765','Natalia','Vargas','Guayaquil','0980123456','natalia@mail.com'),
(16, 'GYE','0903456784','Ricardo','Bravo','Guayaquil','0971234567','ricardo@mail.com'),
(17, 'UIO','1715678906','Valeria','Mena','Quito','0962345678','valeria@mail.com'),
(18, 'GYE','0926789013','Hugo','Reyes','Guayaquil','0953456789','hugo@mail.com'),
(19, 'UIO','1706789014','Camila','Ortiz','Quito','0944567890','camila@mail.com'),
(20, 'GYE','0917890126','Esteban','Navarro','Guayaquil','0935678901','esteban@mail.com');

INSERT INTO Inventario (idSucursal, idProducto, stock)
SELECT 'UIO', idProducto, 50 FROM Producto;

INSERT INTO Inventario (idSucursal, idProducto, stock)
SELECT 'GYE', idProducto, 40 FROM Producto;

INSERT INTO Producto_Proveedor (idProducto, idProveedor, cantidadSuministro, fechaSuministro)
SELECT idProducto, 1, 100, '2025-08-15'
FROM Producto
WHERE idProducto BETWEEN 1 AND 8;

INSERT INTO Producto_Proveedor (idProducto, idProveedor, cantidadSuministro, fechaSuministro)
SELECT idProducto, 2, 120, '2025-09-10'
FROM Producto
WHERE idProducto BETWEEN 5 AND 14;

INSERT INTO Producto_Proveedor (idProducto, idProveedor, cantidadSuministro, fechaSuministro)
SELECT idProducto, 3, 90, '2025-10-05'
FROM Producto
WHERE idProducto BETWEEN 10 AND 20;

INSERT INTO Pedido (idPedido, idCliente, idSucursal, fecha, total) VALUES
(1, 1, 'UIO', '2025-11-01', 0),
(2, 2, 'UIO', '2025-11-01', 0),
(3, 3, 'UIO', '2025-11-01', 0),
(4, 4, 'UIO', '2025-11-01', 0),
(5, 5, 'UIO', '2025-11-01', 0),
(6, 11, 'UIO', '2025-11-01', 0),
(7, 12, 'UIO', '2025-11-01', 0),
(8, 13, 'UIO', '2025-11-01', 0),
(9, 17, 'UIO', '2025-11-01', 0),
(10, 19, 'UIO', '2025-11-01', 0),
(11, 6, 'GYE', '2025-12-05', 0),
(12, 7, 'GYE', '2025-12-05', 0),
(13, 8, 'GYE', '2025-12-05', 0),
(14, 9, 'GYE', '2025-12-05', 0),
(15, 10, 'GYE', '2025-12-05', 0),
(16, 14, 'GYE', '2025-12-05', 0),
(17, 15, 'GYE', '2025-12-05', 0),
(18, 16, 'GYE', '2025-12-05', 0),
(19, 18, 'GYE', '2025-12-05', 0),
(20, 20, 'GYE', '2025-12-05', 0);

INSERT INTO DetallePedido (idDetalle, idPedido, idProducto, cantidad, precio_unitario) VALUES
(1, 2, 1, 2, 12.50),
(2, 3, 3, 1, 45.00),
(3, 4, 1, 2, 12.50),
(4, 4, 5, 3, 28.00),
(5, 6, 1, 2, 12.50),
(6, 6, 3, 1, 45.00),
(7, 8, 1, 2, 12.50),
(8, 8, 5, 3, 28.00),
(9, 9, 3, 1, 45.00),
(10, 10, 1, 2, 12.50),
(11, 12, 1, 2, 12.50),
(12, 12, 3, 1, 45.00),
(13, 13, 3, 1, 45.00),
(14, 14, 1, 2, 12.50),
(15, 15, 3, 1, 45.00),
(16, 16, 1, 2, 12.50),
(17, 16, 5, 3, 28.00),
(18, 18, 1, 2, 12.50),
(19, 18, 3, 1, 45.00),
(20, 20, 1, 2, 12.50),
(21, 20, 5, 3, 28.00);

UPDATE Pedido
SET total = (
    SELECT ISNULL(SUM(cantidad * precio_unitario), 0)
    FROM DetallePedido dp
    WHERE dp.idPedido = Pedido.idPedido
);

GO