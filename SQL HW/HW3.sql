--1. List all cities that have both Employees and Customers.
-- subquery
SELECT DISTINCT City
FROM Customers
WHERE City IN (
    SELECT City
    FROM Employees
)
ORDER BY City

--join
SELECT DISTINCT c.City
FROM Customers c JOIN Employees e ON c.City = e.City
ORDER BY c.City

--2. List all cities that have Customers but no Employee.
-- sub query
SELECT DISTINCT City
FROM Customers
WHERE City NOT IN (
    SELECT City
    FROM Employees
)
ORDER BY City

--join
SELECT DISTINCT c.City
FROM Customers c LEFT JOIN Employees e ON c.City = e.City
WHERE e.City IS NULL
ORDER BY c.City

--3. List all products and their total order quantities throughout all orders.
Select p.ProductName, SUM(od.Quantity) AS TotalOrderQuantity
FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY TotalOrderQuantity DESC

--4. List all Customer Cities and total products ordered by that city.
SELECT c.City, SUM(od.Quantity) AS TotalProductsPerCity
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
ORDER BY TotalProductsPerCity

--5. List all Customer Cities that have at least two customers.
SELECT City, COUNT(CustomerID) AS NumOfCustomers
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) >= 2
ORDER BY NumOfCustomers DESC

--6. List all Customer Cities that have ordered at least two different kinds of products.
SELECT c.City, COUNT(DISTINCT od.ProductID) AS UniqueProducts
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON  p.ProductID = od.ProductID
GROUP BY c.City
HAVING COUNT(DISTINCT od.ProductID) >= 2
ORDER BY UniqueProducts DESC

--7. List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.
SELECT DISTINCT c.ContactName, c.City, o.ShipCity
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City <> o.ShipCity

--8. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
WITH ProductPopularity AS (
    SELECT 
        od.ProductID, 
        p.ProductName, 
        SUM(od.Quantity) AS TotalQuantityOrdered,
        AVG(od.UnitPrice) AS AveragePrice
    FROM [Order Details] od
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY od.ProductID, p.ProductName
),
CityOrders AS (
    SELECT 
        od.ProductID, 
        c.City AS CustomerCity, 
        SUM(od.Quantity) AS TotalQuantityPerCity
    FROM [Order Details] od
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY od.ProductID, c.City
),
MaxCityOrders AS (
    SELECT 
        p.ProductID, 
        p.ProductName, 
        p.AveragePrice,
        p.TotalQuantityOrdered,
        c.CustomerCity
    FROM ProductPopularity p
    JOIN CityOrders c ON p.ProductID = c.ProductID
    WHERE c.TotalQuantityPerCity = (
        SELECT MAX(TotalQuantityPerCity) 
        FROM CityOrders c2 
        WHERE c2.ProductID = c.ProductID
    )
)
SELECT TOP 5 
    ProductName, 
    AveragePrice, 
    CustomerCity, 
    TotalQuantityOrdered
FROM MaxCityOrders
ORDER BY TotalQuantityOrdered DESC

--9. List all cities that have never ordered something but we have employees there.
-- sub query
SELECT City
FROM Employees
WHERE City NOT IN (
    SELECT DISTINCT ShipCity
    FROM Orders
)
ORDER BY City

-- join
SELECT e.City
FROM Employees e LEFT JOIN Orders o ON e.City = o.ShipCity
WHERE o.ShipCity IS NULL
ORDER BY e.City

--10. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
WITH EmployeeTopSales AS (
    SELECT TOP 1 e.City AS EmployeeCity, COUNT(o.OrderID) AS TotalOrders
    FROM Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    GROUP BY e.City
    ORDER BY TotalOrders DESC
),
TopOrderedCity AS (
    SELECT TOP 1 c.City AS OrderCity, SUM(od.Quantity) AS TotalProductQuantity
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY c.City
    ORDER BY TotalProductQuantity DESC
)
SELECT e.EmployeeCity AS City
FROM EmployeeTopSales e
JOIN TopOrderedCity t ON e.EmployeeCity = t.OrderCity

--11. How do you remove the duplicates record of a table?
--example using row_number() and delete()
WITH DuplicateRecords AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY Column1, Column2 ORDER BY ID) AS RowNum
    FROM TableName
)
DELETE FROM TableName 
WHERE ID IN (
    SELECT ID FROM DuplicateRecords WHERE RowNum > 1
);
-- or when combining two tables, use UNION



