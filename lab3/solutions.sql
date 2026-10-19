-- 1. Название продукта и категории для товаров цвета Red с ценой не менее 100
SELECT p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE p.Color = 'Red'
  AND p.ListPrice >= 100;

-- 2. Названия подкатегорий с совпадающими именами
SELECT ps.Name
FROM Production.ProductSubcategory AS ps
GROUP BY ps.Name
HAVING COUNT(*) > 1;

-- 3. Название категории и количество товаров в ней
SELECT pc.Name AS CategoryName, COUNT(p.ProductID) AS ProductCount
FROM Production.ProductCategory AS pc
LEFT JOIN Production.ProductSubcategory AS ps ON ps.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN Production.Product AS p ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY pc.ProductCategoryID, pc.Name;

-- 4. Название подкатегории и количество товаров (группировка по ID из-за одинаковых имен)
SELECT ps.Name AS SubcategoryName, COUNT(p.ProductID) AS ProductCount
FROM Production.ProductSubcategory AS ps
LEFT JOIN Production.Product AS p ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.ProductSubcategoryID, ps.Name;

-- 5. Три подкатегории с наименьшим количеством товаров
SELECT TOP 3 ps.Name AS SubcategoryName
FROM Production.ProductSubcategory AS ps
LEFT JOIN Production.Product AS p ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.ProductSubcategoryID, ps.Name
ORDER BY COUNT(p.ProductID) ASC;

-- 6. Название подкатегории и максимальная цена товара цвета Red в ней
SELECT ps.Name AS SubcategoryName, MAX(p.ListPrice) AS MaxPrice
FROM Production.ProductSubcategory AS ps
JOIN Production.Product AS p ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE p.Color = 'Red'
GROUP BY ps.ProductSubcategoryID, ps.Name;

-- 7. Название поставщика и количество поставляемых товаров
SELECT v.Name AS VendorName, COUNT(DISTINCT pv.ProductID) AS ProductCount
FROM Purchasing.Vendor AS v
JOIN Purchasing.ProductVendor AS pv ON pv.BusinessEntityID = v.BusinessEntityID
GROUP BY v.BusinessEntityID, v.Name;

-- 8. Товары, которые поставляются более чем одним поставщиком
SELECT p.Name
FROM Production.Product AS p
JOIN Purchasing.ProductVendor AS pv ON pv.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
HAVING COUNT(DISTINCT pv.BusinessEntityID) > 1;

-- 9. Самый продаваемый товар (по суммарному количеству проданных единиц)
SELECT TOP 1 WITH TIES p.Name
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY SUM(sod.OrderQty) DESC;

-- 10. Категория, товары из которой продаются наиболее активно
SELECT TOP 1 WITH TIES pc.Name AS CategoryName
FROM Production.ProductCategory AS pc
JOIN Production.ProductSubcategory AS ps ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Production.Product AS p ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Sales.SalesOrderDetail AS sod ON sod.ProductID = p.ProductID
GROUP BY pc.ProductCategoryID, pc.Name
ORDER BY SUM(sod.OrderQty) DESC;

-- 11. Название категории, количество подкатегорий и количество товаров в них
SELECT pc.Name AS CategoryName,
       COUNT(DISTINCT ps.ProductSubcategoryID) AS SubcategoryCount,
       COUNT(DISTINCT p.ProductID) AS ProductCount
FROM Production.ProductCategory AS pc
LEFT JOIN Production.ProductSubcategory AS ps ON ps.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN Production.Product AS p ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY pc.ProductCategoryID, pc.Name;

-- 12. Кредитный рейтинг и количество товаров, поставляемых компаниями с этим рейтингом
SELECT v.CreditRating, COUNT(DISTINCT pv.ProductID) AS ProductCount
FROM Purchasing.Vendor AS v
JOIN Purchasing.ProductVendor AS pv ON pv.BusinessEntityID = v.BusinessEntityID
GROUP BY v.CreditRating;
