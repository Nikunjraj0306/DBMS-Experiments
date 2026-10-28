-- ============================================================
-- EXPERIMENT - 7
-- AIM:
-- Identify functional dependencies in a denormalized Sales table
-- and normalize the relation from Unnormalized Form (UNF) to
-- First Normal Form (1NF), Second Normal Form (2NF), Third Normal
-- Form (3NF), and demonstrate Boyce-Codd Normal Form (BCNF).
-- Verify lossless reconstruction and inspect dependency preservation.
--
-- DATABASE: RetailNormalization
-- DBMS: MySQL
-- ============================================================

-- NOTE:
-- This script drops and recreates RetailNormalization.
-- Do not run it if you need to preserve an existing database of that name.

DROP DATABASE IF EXISTS RetailNormalization;
CREATE DATABASE RetailNormalization;
USE RetailNormalization;


-- ============================================================
-- 1. CREATE THE DENORMALIZED SALES TABLE (UNF)
-- ============================================================

CREATE TABLE Purchase_UNF (
    Order_ID INT,
    Order_Date DATE,
    Customer_ID VARCHAR(10),
    Customer_Name VARCHAR(50),
    Product_ID VARCHAR(10),
    Product_Name VARCHAR(50),
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    Salesperson_ID VARCHAR(10),
    Salesperson_Name VARCHAR(50)
);

INSERT INTO Purchase_UNF VALUES
(2001, '2026-02-05', 'C11', 'Kabir',  'P11', 'Tablet',      2, 32000.00, 'S11', 'Ananya'),
(2001, '2026-02-05', 'C11', 'Kabir',  'P12', 'Headphones',  3,  1800.00, 'S11', 'Ananya'),
(2002, '2026-02-08', 'C12', 'Ishita', 'P11', 'Tablet',      1, 32000.00, 'S12', 'Vikram'),
(2003, '2026-02-12', 'C13', 'Dev',    'P13', 'Printer',     2, 12500.00, 'S11', 'Ananya'),
(2004, '2026-02-16', 'C11', 'Kabir',  'P13', 'Printer',     1, 12500.00, 'S12', 'Vikram'),
(2005, '2026-02-20', 'C14', 'Naina',  'P12', 'Headphones',  4,  1800.00, 'S13', 'Arjun');

SELECT * FROM Purchase_UNF;


-- ============================================================
-- 2. FUNCTIONAL DEPENDENCIES
-- ============================================================
-- Order_ID -> Order_Date
-- Order_ID -> Customer_ID
-- Order_ID -> Salesperson_ID
-- Customer_ID -> Customer_Name
-- Product_ID -> Product_Name
-- Product_ID -> Unit_Price
-- Salesperson_ID -> Salesperson_Name
-- (Order_ID, Product_ID) -> Quantity
--
-- Candidate key: (Order_ID, Product_ID)


-- ============================================================
-- 3. FIRST NORMAL FORM (1NF)
-- Each field contains an atomic value.
-- The composite primary key identifies each order-product row.
-- ============================================================

CREATE TABLE Purchase_1NF (
    Order_ID INT,
    Order_Date DATE,
    Customer_ID VARCHAR(10),
    Customer_Name VARCHAR(50),
    Product_ID VARCHAR(10),
    Product_Name VARCHAR(50),
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    Salesperson_ID VARCHAR(10),
    Salesperson_Name VARCHAR(50),
    PRIMARY KEY (Order_ID, Product_ID)
);

INSERT INTO Purchase_1NF
SELECT * FROM Purchase_UNF;

SELECT * FROM Purchase_1NF;


-- ============================================================
-- 4. SECOND NORMAL FORM (2NF)
-- Remove partial dependencies on part of the composite key.
-- Create Orders, Products, and Order_Details tables.
-- ============================================================

-- Table 1: Orders

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(10),
    Customer_Name VARCHAR(50),
    Salesperson_ID VARCHAR(10),
    Salesperson_Name VARCHAR(50)
);

INSERT INTO Orders
SELECT DISTINCT
    Order_ID,
    Order_Date,
    Customer_ID,
    Customer_Name,
    Salesperson_ID,
    Salesperson_Name
FROM Purchase_1NF;

SELECT * FROM Orders;


-- Table 2: Products

CREATE TABLE Products (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Product_Name VARCHAR(50),
    Unit_Price DECIMAL(10,2)
);

INSERT INTO Products
SELECT DISTINCT
    Product_ID,
    Product_Name,
    Unit_Price
FROM Purchase_1NF;

SELECT * FROM Products;


-- Table 3: Order_Details

CREATE TABLE Order_Details (
    Order_ID INT,
    Product_ID VARCHAR(10),
    Quantity INT,
    PRIMARY KEY (Order_ID, Product_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

INSERT INTO Order_Details
SELECT Order_ID, Product_ID, Quantity
FROM Purchase_1NF;

SELECT * FROM Order_Details;


-- ============================================================
-- 5. THIRD NORMAL FORM (3NF)
-- Remove transitive dependencies by separating customer and
-- salesperson names into their own tables.
-- ============================================================

-- Table 1: Customers

CREATE TABLE Customers (
    Customer_ID VARCHAR(10) PRIMARY KEY,
    Customer_Name VARCHAR(50)
);

INSERT INTO Customers
SELECT DISTINCT Customer_ID, Customer_Name
FROM Purchase_1NF;

SELECT * FROM Customers;


-- Table 2: Salespersons

CREATE TABLE Salespersons (
    Salesperson_ID VARCHAR(10) PRIMARY KEY,
    Salesperson_Name VARCHAR(50)
);

INSERT INTO Salespersons
SELECT DISTINCT Salesperson_ID, Salesperson_Name
FROM Purchase_1NF;

SELECT * FROM Salespersons;


-- Table 3: Orders_3NF

CREATE TABLE Orders_3NF (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(10),
    Salesperson_ID VARCHAR(10),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Salesperson_ID) REFERENCES Salespersons(Salesperson_ID)
);

INSERT INTO Orders_3NF
SELECT DISTINCT
    Order_ID,
    Order_Date,
    Customer_ID,
    Salesperson_ID
FROM Purchase_1NF;

SELECT * FROM Orders_3NF;


-- ============================================================
-- 6. BOYCE-CODD NORMAL FORM (BCNF)
-- Demonstrate the dependency Coordinator_ID -> Project_ID.
-- Decompose the assignment relation into two relations.
-- ============================================================

-- Original relation

CREATE TABLE Consultant_Assignment (
    Consultant_ID VARCHAR(10),
    Project_ID VARCHAR(10),
    Coordinator_ID VARCHAR(10),
    PRIMARY KEY (Consultant_ID, Project_ID)
);

INSERT INTO Consultant_Assignment VALUES
('E11', 'P11', 'S11'),
('E12', 'P11', 'S11'),
('E13', 'P12', 'S12'),
('E14', 'P12', 'S12');

SELECT * FROM Consultant_Assignment;


-- Table 1: Coordinator_Project

CREATE TABLE Coordinator_Project (
    Coordinator_ID VARCHAR(10) PRIMARY KEY,
    Project_ID VARCHAR(10)
);

INSERT INTO Coordinator_Project VALUES
('S11', 'P11'),
('S12', 'P12');

SELECT * FROM Coordinator_Project;


-- Table 2: Consultant_Coordinator

CREATE TABLE Consultant_Coordinator (
    Consultant_ID VARCHAR(10),
    Coordinator_ID VARCHAR(10),
    PRIMARY KEY (Consultant_ID, Coordinator_ID)
);

INSERT INTO Consultant_Coordinator VALUES
('E11', 'S11'),
('E12', 'S11'),
('E13', 'S12'),
('E14', 'S12');

SELECT * FROM Consultant_Coordinator;


-- Verify the BCNF decomposition by joining the two tables

SELECT
    cc.Consultant_ID,
    cp.Project_ID,
    cc.Coordinator_ID
FROM Consultant_Coordinator AS cc
JOIN Coordinator_Project AS cp
    ON cc.Coordinator_ID = cp.Coordinator_ID;


-- ============================================================
-- 7. VERIFY LOSSLESS JOIN
-- Reconstruct the original Sales records from the 3NF tables.
-- Expected: six rows, matching the six original records.
-- ============================================================

SELECT
    o.Order_ID,
    o.Order_Date,
    c.Customer_ID,
    c.Customer_Name,
    od.Product_ID,
    p.Product_Name,
    od.Quantity,
    p.Unit_Price,
    s.Salesperson_ID,
    s.Salesperson_Name
FROM Orders_3NF AS o
JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
JOIN Salespersons AS s
    ON o.Salesperson_ID = s.Salesperson_ID
JOIN Order_Details AS od
    ON o.Order_ID = od.Order_ID
JOIN Products AS p
    ON od.Product_ID = p.Product_ID
ORDER BY o.Order_ID, od.Product_ID;


-- ============================================================
-- 8. VERIFY RECONSTRUCTED ROW COUNT
-- Expected result: reconstructed_rows = 6
-- ============================================================

SELECT COUNT(*) AS reconstructed_rows
FROM Orders_3NF AS o
JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
JOIN Salespersons AS s
    ON o.Salesperson_ID = s.Salesperson_ID
JOIN Order_Details AS od
    ON o.Order_ID = od.Order_ID
JOIN Products AS p
    ON od.Product_ID = p.Product_ID;


-- ============================================================
-- 9. VERIFY DEPENDENCY PRESERVATION
-- Functional dependencies are represented in these relations:
-- Customer_ID -> Customer_Name                 : Customers
-- Salesperson_ID -> Salesperson_Name            : Salespersons
-- Order_ID -> Order_Date, Customer_ID,
--              Salesperson_ID                   : Orders_3NF
-- Product_ID -> Product_Name, Unit_Price        : Products
-- (Order_ID, Product_ID) -> Quantity            : Order_Details
--
-- Inspect the table definitions:
-- ============================================================

SHOW CREATE TABLE Customers;
SHOW CREATE TABLE Salespersons;
SHOW CREATE TABLE Orders_3NF;
SHOW CREATE TABLE Products;
SHOW CREATE TABLE Order_Details;



