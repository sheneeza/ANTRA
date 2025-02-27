-- Northwind db
--14. List all Products that has been sold at least once in last 27 years.
SELECT DISTINCT p.ProductName, o.OrderDate
FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID JOIN Orders o  ON od.OrderID = o.OrderID
WHERE o.OrderDate >= DATEADD(YEAR, -27, GETDATE())
ORDER BY p.ProductName

--15. List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS TotalProductSold
FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID JOIN Orders o  ON od.OrderID = o.OrderID
GROUP BY o.ShipPostalCode
ORDER BY TotalProductSold DESC

--16. List top 5 locations (Zip Code) where the products sold most in last 27 years.
SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS TotalProductSold
FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID JOIN Orders o  ON od.OrderID = o.OrderID
WHERE o.OrderDate >= DATEADD(YEAR, -27, GETDATE())
GROUP BY o.ShipPostalCode
ORDER BY TotalProductSold DESC

--17.  List all city names and number of customers in that city.     
-- list city names and number of customers in each city.
SELECT City, COUNT(CustomerID) AS NumOfCustomers
FROM Customers
GROUP BY City
ORDER BY NumOfCustomers DESC

--18. List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(CustomerID) AS NumOfCustomers
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2
ORDER BY NumOfCustomers DESC

--19. List the names of customers who placed orders after 1/1/98 with order date.
SELECT c.ContactName, o.OrderDate
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '1998-01-01'

--20. List the names of all customers with most recent order dates
SELECT c.ContactName, MAX(o.OrderDate) AS MostRecentOrders
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName
ORDER BY MostRecentOrders DESC

--21. Display the names of all customers along with the count of products they bought
SELECT c.ContactName, COUNT(od.ProductID) AS NumOfProductsBought
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.ContactName
ORDER BY NumOfProductsBought DESC

--22. Display the customer ids who bought more than 100 Products with count of products.
SELECT c.CustomerID, COUNT(od.ProductID) AS NumOfProductsBought
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID
HAVING COUNT(od.ProductID) > 100
ORDER BY NumOfProductsBought DESC

--23. List all of the possible ways that suppliers can ship their products. Display the results as below
--    Supplier Company Name                Shipping Company Name
SELECT DISTINCT s.CompanyName AS SupplierCompanyName, sh.CompanyName AS ShippingCompanyName
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Shippers sh ON o.ShipVia = sh.ShipperID
ORDER BY s.CompanyName, sh.CompanyName

--24. Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderDate ASC

--25. Displays pairs of employees who have the same job title.
SELECT e1.FirstName + ' ' + e1.LastName AS Employee1, 
       e2.FirstName + ' ' + e2.LastName AS Employee2, 
       e1.Title AS JobTitle
FROM Employees e1
JOIN Employees e2 ON e1.Title = e2.Title 
                  AND e1.EmployeeID < e2.EmployeeID
ORDER BY e1.Title, e1.FirstName, e2.FirstName

--26. Display all the Managers who have more than 2 employees reporting to them.
SELECT m.EmployeeID, 
       m.FirstName + ' ' + m.LastName AS ManagerName, 
       COUNT(e.EmployeeID) NumOfEmployees
FROM Employees e JOIN Employees m ON e.ReportsTo = m.EmployeeID
GROUP BY m.EmployeeID, m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) > 2
ORDER BY NumOfEmployees DESC

--27. Display the customers and suppliers by city. The results should have the following columns
SELECT City, CompanyName AS Name, ContactName, 'Customer' AS Type
FROM Customers 
UNION 
SELECT City, CompanyName AS Name, ContactName, 'Supplier' AS Type
FROM Suppliers 
ORDER BY City, Type
