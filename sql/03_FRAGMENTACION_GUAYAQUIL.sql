-- =============================================
-- Script de Fragmentación: Nodo GUAYAQUIL
-- Base de Datos: Sueños de Tela
-- Nota: Posterior a la creación de la BDD
-- Centralizada y creación de tablas replicadas
-- =============================================

USE GUAYAQUIL;
GO

-- =============================================
-- CONSTRAINT TABLAS REPLICADAS
-- Nota: Mantiene la lógica de la BDD Centralizada
-- =============================================

ALTER TABLE Producto_Proveedor
ADD CONSTRAINT fk_PP_Proveedor_GUAYAQUIL FOREIGN KEY (idProveedor) 
REFERENCES Proveedor(idProveedor);

ALTER TABLE Producto_Proveedor
ADD CONSTRAINT fk_PP_Producto_GUAYAQUIL FOREIGN KEY (idProducto) 
REFERENCES Producto(idProducto);

-- =============================================
-- FRAGMENTACIÓN MIXTA (Vertical + Horizontal)
-- Tabla: Info_Cliente_GUAYAQUIL
-- =============================================
SELECT idCliente, nombre, apellido, telefono, correo, idSucursal
INTO Info_Cliente_GUAYAQUIL
FROM [LS_NATTYRD].SueñoDeTela.dbo.Cliente
WHERE idSucursal = 'GYE';

ALTER TABLE Info_Cliente_GUAYAQUIL 
ADD CONSTRAINT pk_idCliente_idSucursal_GUAYAQUIL PRIMARY KEY (idCliente, idSucursal);

ALTER TABLE Info_Cliente_GUAYAQUIL 
ADD CONSTRAINT fk_Cliente_Sucursal_GUAYAQUIL FOREIGN KEY (idSucursal) 
REFERENCES Sucursal(idSucursal);

-- =============================================
-- FRAGMENTACIÓN HORIZONTAL PRIMARIA
-- Tabla: Pedido_GUAYAQUIL
-- =============================================
SELECT * 
INTO Pedido_GUAYAQUIL
FROM [LS_NATTYRD].SueñoDeTela.dbo.Pedido
WHERE idSucursal = 'GYE';

ALTER TABLE Pedido_GUAYAQUIL 
ADD CONSTRAINT pk_idPedido_idSucursal_GUAYAQUIL PRIMARY KEY (idPedido, idSucursal);

ALTER TABLE Pedido_GUAYAQUIL 
ADD CONSTRAINT fk_Pedido_Sucursal_GUAYAQUIL FOREIGN KEY (idSucursal) 
REFERENCES Sucursal(idSucursal);

ALTER TABLE Pedido_GUAYAQUIL 
ADD CONSTRAINT fk_Pedido_Cliente_GUAYAQUIL FOREIGN KEY (idCliente, idSucursal) 
REFERENCES Info_Cliente_GUAYAQUIL(idCliente, idSucursal);

-- =============================================
-- FRAGMENTACIÓN HORIZONTAL PRIMARIA
-- Tabla: Inventario_GUAYAQUIL
-- =============================================
SELECT * 
INTO Inventario_GUAYAQUIL
FROM [LS_NATTYRD].SueñoDeTela.dbo.Inventario
WHERE idSucursal = 'GYE';

ALTER TABLE Inventario_GUAYAQUIL 
ADD CONSTRAINT pk_idSucursal_idProducto_GUAYAQUIL PRIMARY KEY (idSucursal, idProducto);

ALTER TABLE Inventario_GUAYAQUIL 
ADD CONSTRAINT fk_Inventario_Sucursal_GUAYAQUIL FOREIGN KEY (idSucursal) 
REFERENCES Sucursal(idSucursal);

ALTER TABLE Inventario_GUAYAQUIL 
ADD CONSTRAINT fk_Inventario_Producto_GUAYAQUIL FOREIGN KEY (idProducto) 
REFERENCES Producto(idProducto);

-- =============================================
-- FRAGMENTACIÓN HORIZONTAL DERIVADA
-- Tabla: DetallePedido_GUAYAQUIL
-- =============================================
SELECT A.*, B.idSucursal 
INTO DetallePedido_GUAYAQUIL
FROM [LS_NATTYRD].SueñoDeTela.dbo.DetallePedido A 
JOIN Pedido_GUAYAQUIL B ON A.idPedido = B.idPedido;

ALTER TABLE DetallePedido_GUAYAQUIL 
ADD CONSTRAINT pk_idDetalle_idPedido_idSucursal_GUAYAQUIL PRIMARY KEY (idPedido, idDetalle, idSucursal);

ALTER TABLE DetallePedido_GUAYAQUIL 
ADD CONSTRAINT fk_DetallePedido_Pedido_GUAYAQUIL FOREIGN KEY (idPedido, idSucursal) 
REFERENCES Pedido_GUAYAQUIL(idPedido, idSucursal);

ALTER TABLE DetallePedido_GUAYAQUIL 
ADD CONSTRAINT fk_DetallePedido_Producto_GUAYAQUIL FOREIGN KEY (idProducto) 
REFERENCES Producto(idProducto);

GO

-- =============================================
-- VISTAS PARTICIONADAS
-- =============================================

-- Vista: Cliente Global
IF OBJECT_ID('V_Cliente', 'V') IS NOT NULL DROP VIEW V_Cliente;
GO
CREATE VIEW V_Cliente AS
SELECT * FROM [LS_NATTYRD].QUITO.dbo.Info_Cliente_QUITO
UNION ALL
SELECT * FROM Info_Cliente_GUAYAQUIL;
GO

ALTER TABLE Info_Cliente_GUAYAQUIL ADD CONSTRAINT CK_CLIENTE CHECK (idSucursal = 'GYE');


-- Vista: Pedido Global
IF OBJECT_ID('V_Pedido', 'V') IS NOT NULL DROP VIEW V_Pedido;
GO
CREATE VIEW V_Pedido AS
SELECT * FROM [LS_NATTYRD].QUITO.dbo.Pedido_QUITO 
UNION ALL
SELECT * FROM Pedido_GUAYAQUIL;
GO

ALTER TABLE Pedido_GUAYAQUIL ADD CONSTRAINT CK_PEDIDO CHECK (idSucursal = 'GYE');

-- Vista: Inventario Global
IF OBJECT_ID('V_Inventario', 'V') IS NOT NULL DROP VIEW V_Inventario;
GO
CREATE VIEW V_Inventario AS
SELECT * FROM [LS_NATTYRD].QUITO.dbo.Inventario_QUITO 
UNION ALL
SELECT * FROM Inventario_GUAYAQUIL;
GO

ALTER TABLE Inventario_GUAYAQUIL ADD CONSTRAINT CK_INVENTARIO CHECK (idSucursal = 'GYE');

-- Vista: DetallePedido Global
IF OBJECT_ID('V_DetallePedido', 'V') IS NOT NULL DROP VIEW V_DetallePedido;
GO
CREATE VIEW V_DetallePedido AS
SELECT * FROM [LS_NATTYRD].QUITO.dbo.DetallePedido_QUITO 
UNION ALL
SELECT * FROM DetallePedido_GUAYAQUIL;
GO

ALTER TABLE DetallePedido_GUAYAQUIL ADD CONSTRAINT CK_DETALLEPEDIDO CHECK (idSucursal = 'GYE');