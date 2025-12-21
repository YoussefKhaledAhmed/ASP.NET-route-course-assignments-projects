/*********************************************************
 * File name: SQL_EntringDataOnlineRetail                *
 * Author: Youssef Khaled                                *
 * Date: 12/13/2025 | dd/mm/yyyy                         *
 * Description: Adding data to OnlineRetail DB           *
 *********************************************************/

-- using the OnlineRetail database instead of master
USE OnlineRetail;

/* 1. Insert operation: */
-- Insert new customer
INSERT INTO Customers
VALUES (1 , 'Youssef Khaled' , '01112345678' , 'yousef@gmail.com' , 'Cairo, Egypt' , '2000-11-29')

-- Insert 3 new suppliers
INSERT INTO Suppliers
VALUES 
	  (1 , 'Youssef' , 'Egypt' , 'Yousef@gmail.com' , 'Cairo, Egypt' , '01112345677'),
	  (2 , 'Ahmed' , 'Egypt' , 'Ahmed@gmail.com' , 'Cairo, Egypt' , '01112345678'),
	  (3 , 'Khaled' , 'Egypt' , 'Khaled@gmail.com' , 'Cairo, Egypt' , '01112345679')

-- Insert 2 Categories
INSERT INTO Categories
VALUES
	  (1, 'Electronics' , 'Electronics components' , 1),
	  (2, 'MobilePhones' , 'Electronics components' , 1)

-- Insert a product but only (Name, UnitPrice)
INSERT INTO Products(ProductId , [Name] , UnitPrice)
VALUES 
	  (1, 'DELL-Laptop' , 10000),
	  (2, 'LENOVO-Laptop' , 10000)

-- Create table ArchivedStock (TranId, ProductId, QuantityChange, TranDate) 
CREATE TABLE ArchivedStock(
	TranId INT PRIMARY KEY,
	TranDate DATE NOT NULL,
	QuantityChange INT NOT NULL,
	[Type] TINYINT NULL,
	Reference VARCHAR(20) NULL,
	ProductId INT FOREIGN KEY REFERENCES Products(ProductId)
);

-- Inserting some dummy date in StockTransactions table to be used later
INSERT INTO StockTransactions 
(TranId, TranDate, QuantityChange, Type, Reference, ProductId)
VALUES
    (1, '2022-11-10',  8, 1, 'STK-IN-001', 1),   -- Before 2023
    (2, '2022-12-20', -3, 2, 'STK-OUT-002', 2),  -- Before 2023
    (3, '2023-03-05', 15, 1, 'STK-IN-003', 1),   -- After 2023
    (4, '2023-09-18', -5, 2, 'STK-OUT-004', 2),  -- After 2023
    (5, '2024-01-12', 12, 1, 'STK-IN-005', 1);   -- After 2023

-- Intsert into ArchivedStock all Stock Transactions before 2023.
INSERT INTO ArchivedStock(TranId , ProductId , QuantityChange , TranDate)
SELECT TranId , ProductId , QuantityChange , TranDate
FROM StockTransactions
WHERE TranDate < '2023-01-01';


/* 2. Temporary tables: */

-- Create #CustomerOrders with (OrderId, CustomerId, TotalAmount)
CREATE TABLE #CustomerOrders(
	OrderId INT PRIMARY KEY,
	CustomerId INT,
	TotalAmount INT
);

-- Inserting some dummy data to Orders table to be used
INSERT INTO Orders (OrderId, [Status], TotalAmount, OrderDate, CustomerId)
VALUES
    (1, 1, 3200, '2024-01-05', 1),
    (2, 2, 7500, '2024-01-10', 1),
    (3, 1, 12000, '2024-02-02', 1),
    (4, 3, 4800, '2024-02-15', 1),
    (5, 2, 9900, '2024-03-01', 1),
    (6, 1, 1500, '2024-03-10', 1),
    (7, 3, 6700, '2024-03-20', 1),
    (8, 1, 5200, '2024-04-05', 1);

-- Insert Customers who made orders above 5000
INSERT INTO #CustomerOrders
SELECT OrderId, CustomerId, TotalAmount
FROM Orders
WHERE TotalAmount > 5000

-- Create ##TopRatedProducts with (ProductId , Rating)
CREATE TABLE ##TopRatedProducts(
	ProductId INT,
	Rating DECIMAL(2,1)
);

-- Inserting some dummy data to Reviews to be used
INSERT INTO Reviews (ReviewId, Rating, [Date], Comment, ProductId, CustomerId)
VALUES
    (9, 5, '2024-01-10', 'Excellent product', 1, 1),
    (10, 4.3, '2024-01-12', 'Very good', 2, 1),
    (11, 3, '2024-01-15', 'Average quality', 1, 1),
    (12, 5, '2024-02-01', 'Highly recommended', 2, 1),
    (13, 2, '2024-02-05', 'Not satisfied', 2, 1),
    (14, 4.5, '2024-02-10', 'Good value', 1, 1),
    (15, 1, '2024-02-20', 'Poor experience', 1, 1),
    (16, 5, '2024-03-01', 'Perfect!', 2, 1);

INSERT INTO ##TopRatedProducts
SELECT ProductId, Rating
FROM Reviews
WHERE Rating >= 4.5;


/* 3. Update operation: */
-- Increase all UnitPrice by 10% for products under 100 EGP
UPDATE Products
SET UnitPrice = UnitPrice * 1.1
WHERE UnitPrice < 100;



-- Inserting some more dummy data to be used
INSERT INTO Products (ProductId, [Name], UnitPrice)
VALUES
    (3, 'Logitech-Mouse', 80),
    (4, 'HP-Keyboard', 95),
    (5, 'USB-C-Cable', 50),
    (6, 'Laptop-Stand', 120),
    (7, 'External-HDD', 850),
    (8, 'Webcam', 100),
    (9, 'Headphones', 75),
    (10, 'Cooling-Pad', 110);

-- Update Order Status: If TotalAmount > 5000 → Premium Else → Standard 
-- Where Premium will be 2 and Standard will be 1
UPDATE Orders
SET [Status] = 
	CASE 
		WHEN TotalAmount > 5000 THEN 2
		ELSE 1
	END;

/* 4. Delete Operation: */
-- Delete a Review by ReviewId
DELETE FROM Reviews
WHERE ReviewId = 5;

-- adding some dummy data to Orders
INSERT INTO Orders (OrderId, [Status], TotalAmount, OrderDate, CustomerId)
VALUES
    (9, 0, 1500, '2024-11-01', 1),
    (10, 0, 2300, '2024-11-05', 1),
    (11, 0, 800,  '2024-11-10', 1),
    (12, 0, 1200, '2024-11-15', 1);

-- Delete all Orders with Status = “Cancelled
DELETE FROM Orders
WHERE [Status] = 0;

-- Inserting some dummy data in OrderItems
INSERT INTO OrderItems (OrderItemId, Quantity, UnitPrice, ProductId, OrderId)
VALUES
    -- Order 1
    (1, 1, 10000, 1, 1),
    (2, 2, 100,   3, 1),

    -- Order 2
    (3, 1, 10000, 2, 2),
    (4, 1, 200,   4, 2),

    -- Order 3
    (5, 3, 100,   3, 3),

    -- Order 4
    (6, 1, 150,   5, 4),
    (7, 2, 200,   4, 4),

    -- Order 5
    (8, 1, 10000, 1, 5),

    -- Order 6
    (9, 4, 100,   3, 6),

    -- Order 7
    (10, 2, 150,  5, 7),
    (11, 1, 200,  4, 7),

    -- Order 8
    (12, 1, 10000, 2, 8),
    (13, 2, 100,   3, 8);


-- Delete OrderItems for a given OrderId 
DELETE FROM OrderItems
WHERE OrderId = 6;


/* 5. Merge operation: */
CREATE TABLE #ProductsUpdate(
	ProductId INT PRIMARY KEY,
	[NAME] VARCHAR(30),
	UnitPrice INT,
	StockQuantity INT
);

INSERT INTO #ProductsUpdate (ProductId, [Name], UnitPrice, StockQuantity)
VALUES
    (1, 'DELL-Laptop',   15000, 1),   -- existing → UPDATE
    (2, 'LENOVO-Laptop', 9800,  1),   -- existing → UPDATE
    (11, 'HP-Laptop',    11000, 1),   -- new → INSERT
    (12, 'ASUS-Laptop',  9500,  1);  -- new → INSERT

ALTER TABLE Products
ADD IsDeleted BIT NOT NULL
    CONSTRAINT DF_Products_IsDeleted DEFAULT 0;

MERGE INTO Products as target
USING #ProductsUpdate as source
ON target.ProductId = source.ProductId

-- If product exists → UPDATE price & stock
WHEN MATCHED THEN
	UPDATE SET 
		target.[Name] = source.[Name],
        target.UnitPrice = source.UnitPrice,
        target.StockQuantity = source.StockQuantity

-- If new → INSERT
WHEN NOT MATCHED BY target THEN
	INSERT (ProductId, [Name], UnitPrice, StockQuantity)
    VALUES (source.ProductId, source.[Name], source.UnitPrice, source.StockQuantity)
-- If a product exists in main table but not in update table → DELETE
WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET
		target.IsDeleted = 1; -- Soft delete