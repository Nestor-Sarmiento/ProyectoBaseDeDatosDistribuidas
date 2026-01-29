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