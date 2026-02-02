-- =============================================
-- Script de Fragmentación: Nodo QUITO
-- Base de Datos: Sueños de Tela
-- Nota: Posterior a la creación de la BDD
-- Centralizada y creación de tablas replicadas
-- =============================================

USE QUITO;
GO

-- =============================================
-- CONSTRAINT TABLAS REPLICADAS
-- Nota: Mantiene la lógica de la BDD Centralizada
-- =============================================

ALTER TABLE Producto_Proveedor
ADD CONSTRAINT fk_PP_Proveedor_QUITO FOREIGN KEY (idProveedor) 
REFERENCES Proveedor(idProveedor);

ALTER TABLE Producto_Proveedor
ADD CONSTRAINT fk_PP_Producto_QUITO FOREIGN KEY (idProducto) 
REFERENCES Producto(idProducto);

-- =============================================
-- FRAGMENTACIÓN VERTICAL
-- Tabla: Registro_Cliente (solo datos de registro)
-- Nota: Se ubicará únicamente en el nodo QUITO
-- =============================================
SELECT idCliente, cedula, ciudad 
INTO Registro_Cliente
FROM SueñoDeTela.dbo.Cliente;

ALTER TABLE Registro_Cliente 
ADD CONSTRAINT pk_idCliente PRIMARY KEY (idCliente);

-- =============================================
-- FRAGMENTACIÓN MIXTA (Vertical + Horizontal)
-- Tabla: Info_Cliente_QUITO
-- =============================================
SELECT idCliente, nombre, apellido, telefono, correo, idSucursal 
INTO Info_Cliente_QUITO
FROM SueñoDeTela.dbo.Cliente
WHERE idSucursal = 'UIO';

ALTER TABLE Info_Cliente_QUITO 
ADD CONSTRAINT pk_idCliente_idSucursal_QUITO PRIMARY KEY (idCliente, idSucursal);

ALTER TABLE Info_Cliente_QUITO 
ADD CONSTRAINT fk_Cliente_Sucursal_QUITO FOREIGN KEY (idSucursal) 
REFERENCES Sucursal(idSucursal);

-- =============================================
-- FRAGMENTACIÓN HORIZONTAL PRIMARIA
-- Tabla: Pedido_QUITO
-- =============================================
SELECT * 
INTO Pedido_QUITO
FROM SueñoDeTela.dbo.Pedido
WHERE idSucursal = 'UIO';

ALTER TABLE Pedido_QUITO 
ADD CONSTRAINT pk_idPedido_idSucursal_QUITO PRIMARY KEY (idPedido, idSucursal);

ALTER TABLE Pedido_QUITO 
ADD CONSTRAINT fk_Pedido_Sucursal_QUITO FOREIGN KEY (idSucursal) 
REFERENCES Sucursal(idSucursal);

ALTER TABLE Pedido_QUITO 
ADD CONSTRAINT fk_Pedido_Cliente_QUITO FOREIGN KEY (idCliente, idSucursal) 
REFERENCES Info_Cliente_QUITO(idCliente, idSucursal);

-- =============================================
-- FRAGMENTACIÓN HORIZONTAL PRIMARIA
-- Tabla: Inventario_QUITO
-- =============================================
SELECT * 
INTO Inventario_QUITO
FROM SueñoDeTela.dbo.Inventario
WHERE idSucursal = 'UIO';

ALTER TABLE Inventario_QUITO 
ADD CONSTRAINT pk_idSucursal_idProducto_QUITO PRIMARY KEY (idSucursal, idProducto);

ALTER TABLE Inventario_QUITO 
ADD CONSTRAINT fk_Inventario_Sucursal_QUITO FOREIGN KEY (idSucursal) 
REFERENCES Sucursal(idSucursal);

ALTER TABLE Inventario_QUITO 
ADD CONSTRAINT fk_Inventario_Producto_QUITO FOREIGN KEY (idProducto) 
REFERENCES Producto(idProducto);

-- =============================================
-- FRAGMENTACIÓN HORIZONTAL DERIVADA
-- Tabla: DetallePedido_QUITO
-- =============================================
SELECT A.*, B.idSucursal 
INTO DetallePedido_QUITO
FROM SueñoDeTela.dbo.DetallePedido A 
JOIN Pedido_QUITO B ON A.idPedido = B.idPedido;

ALTER TABLE DetallePedido_QUITO 
ADD CONSTRAINT pk_idDetalle_idPedido_idSucursal_QUITO PRIMARY KEY (idPedido, idDetalle, idSucursal);

ALTER TABLE DetallePedido_QUITO 
ADD CONSTRAINT fk_DetallePedido_Pedido_QUITO FOREIGN KEY (idPedido, idSucursal) 
REFERENCES Pedido_QUITO(idPedido, idSucursal);

ALTER TABLE DetallePedido_QUITO 
ADD CONSTRAINT fk_DetallePedido_Producto_QUITO FOREIGN KEY (idProducto) 
REFERENCES Producto(idProducto);

GO

-- =============================================
-- VISTAS PARTICIONADAS
-- =============================================

-- Vista: Cliente Global
IF OBJECT_ID('V_Cliente', 'V') IS NOT NULL DROP VIEW V_Cliente;
GO
CREATE VIEW V_Cliente AS
SELECT * FROM Info_Cliente_QUITO
UNION ALL
SELECT * FROM [LS_DAVO].GUAYAQUIL.dbo.Info_Cliente_GUAYAQUIL ;

ALTER TABLE Info_Cliente_QUITO ADD CONSTRAINT CK_CLIENTE CHECK (idSucursal = 'UIO');


-- Vista: Pedido Global
IF OBJECT_ID('V_Pedido', 'V') IS NOT NULL DROP VIEW V_Pedido;
GO
CREATE VIEW V_Pedido AS
SELECT * FROM Pedido_QUITO 
UNION ALL
SELECT * FROM [LS_DAVO].GUAYAQUIL.dbo.Pedido_GUAYAQUIL ;
GO

ALTER TABLE Pedido_QUITO ADD CONSTRAINT CK_PEDIDO CHECK (idSucursal = 'UIO');

-- Vista: Inventario Global
IF OBJECT_ID('V_Inventario', 'V') IS NOT NULL DROP VIEW V_Inventario;
GO
CREATE VIEW V_Inventario AS
SELECT * FROM Inventario_QUITO 
UNION ALL
SELECT * FROM [LS_DAVO].GUAYAQUIL.dbo.Inventario_GUAYAQUIL ;
GO

ALTER TABLE Inventario_QUITO ADD CONSTRAINT CK_INVENTARIO CHECK (idSucursal = 'UIO');

-- Vista: DetallePedido Global
IF OBJECT_ID('V_DetallePedido', 'V') IS NOT NULL DROP VIEW V_DetallePedido;
GO
CREATE VIEW V_DetallePedido AS
SELECT * FROM DetallePedido_QUITO 
UNION ALL
SELECT * FROM [LS_DAVO].GUAYAQUIL.dbo.DetallePedido_GUAYAQUIL ;
GO

ALTER TABLE DetallePedido_QUITO ADD CONSTRAINT CK_DETALLEPEDIDO CHECK (idSucursal = 'UIO'); 