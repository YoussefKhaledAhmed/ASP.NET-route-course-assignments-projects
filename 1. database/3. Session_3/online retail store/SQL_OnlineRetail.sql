/*********************************************************
 * File name: SQL_OnlineRetail                           *
 * Author: Youssef Khaled                                *
 * Date: 12/9/2025 | dd/mm/yyyy                          *
 * Description: Creating OnlineRetail DB containing      *
 *              the DB tables.                           *
 *********************************************************/

-- Creating HotelReservation database
CREATE DATABASE OnlineRetail;


-- using the HotelReservation database instead of master
USE OnlineRetail;


/****************************************
 *           Creating tables            *
 ****************************************/
CREATE TABLE Suppliers(
	SupplierId INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	Country VARCHAR(10) NOT NULL,
	Email VARCHAR(30) NOT NULL,
	[Address] VARCHAR(60) NOT NULL,
	ContactNumber VARCHAR(11) UNIQUE NOT NULL
)

CREATE TABLE Customers(
	CustomerId INT PRIMARY KEY,
	FullName VARCHAR(30) NOT NULL,
	PhoneNumber VARCHAR(11) UNIQUE NOT NULL,
	Email VARCHAR(30) NOT NULL,
	ShippingAddress VARCHAR(60) NOT NULL,
	RegistrationDate DATE NOT NULL
)

CREATE TABLE Categories(
	CategoryId INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	[Description] VARCHAR(60) NOT NULL,
	MainCategory INT FOREIGN KEY REFERENCES Categories(CategoryId)
)

CREATE TABLE Products(
	ProductId INT PRIMARY KEY,
	StockQuantity INT,
	[Name] VARCHAR(30),
	AddedDate DATE ,
	[Description] VARCHAR(60) ,
	UnitPrice INT,
	CategoryId INT FOREIGN KEY REFERENCES Categories(CategoryId)
)

CREATE TABLE Reviews(
	ReviewId INT PRIMARY KEY,
	Rating DECIMAL(2,1) NOT NULL,
	[Date] DATE NOT NULL,
	Comment VARCHAR(30),
	ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
	CustomerId INT FOREIGN KEY REFERENCES Customers(CustomerId)
)

CREATE TABLE Payments(
	PaymentId INT PRIMARY KEY,
	PaymentDate DATE NOT NULL,
	Amount INT NOT NULL,
	[Status] TINYINT NOT NULL,
	Method TINYINT NOT NULL
)

CREATE TABLE Orders(
	OrderId INT PRIMARY KEY,
	[Status] TINYINT NOT NULL,
	TotalAmount INT NOT NULL,
	OrderDate DATE NOT NULL,
	CustomerId INT FOREIGN KEY REFERENCES Customers(CustomerId)
)

CREATE TABLE Shipments(
	ShipmentId INT PRIMARY KEY,
	ShipmentDate DATE NOT NULL,
	[Status] TINYINT NOT NULL,
	DeliveryDate DATE NOT NULL,
	CarrierName VARCHAR(30) NOT NULL,
	TrackingNumber INT NOT NULL,
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId)
)

CREATE TABLE Orders_Payments(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
	PaymentId INT FOREIGN KEY REFERENCES Payments(PaymentId)

	CONSTRAINT PK_Orders_Payments
	  PRIMARY KEY(OrderId,PaymentId)
)

CREATE TABLE StockTransactions(
	TranId INT PRIMARY KEY,
	TranDate DATE NOT NULL,
	QuantityChange INT NOT NULL,
	[Type] TINYINT NOT NULL,
	Reference VARCHAR(20) NOT NULL,
	ProductId INT FOREIGN KEY REFERENCES Products(ProductId)
)

CREATE TABLE Products_Suppliers(
	SupplierId INT FOREIGN KEY REFERENCES Suppliers(SupplierId),
	ProductId INT FOREIGN KEY REFERENCES Products(ProductId)

	CONSTRAINT PK_Products_Suppliers
	  PRIMARY KEY(SupplierId,ProductId)
)

CREATE TABLE OrderItems(
	OrderItemId INT PRIMARY KEY,
	Quantity INT NOT NULL,
	UnitPrice INT NOT NULL,
	ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
)