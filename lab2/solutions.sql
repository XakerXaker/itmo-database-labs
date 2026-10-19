-- Практическая работа 2. GROUP BY
-- СУБД: Microsoft SQL Server (T-SQL), база данных AdventureWorks

-- 1. Количество товаров каждого цвета, цена которых не меньше 30
SELECT p.Color, COUNT(*) AS ProductCount
FROM Production.Product AS p
WHERE p.ListPrice >= 30
GROUP BY p.Color;

-- 2. Цвета, для которых минимальная цена товара более 100
SELECT p.Color
FROM Production.Product AS p
GROUP BY p.Color
HAVING MIN(p.ListPrice) > 100;

-- 3. Номера подкатегорий и количество товаров в каждой
SELECT p.ProductSubcategoryID, COUNT(*) AS ProductCount
FROM Production.Product AS p
GROUP BY p.ProductSubcategoryID;

-- 4. Номера товаров и количество фактов продаж
SELECT sod.ProductID, COUNT(*) AS SalesCount
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID;

-- 5. Товары, купленные более пяти раз
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID
HAVING COUNT(*) > 5;

-- 6. Покупатели, у которых более одного чека с одинаковой датой
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
GROUP BY soh.CustomerID, soh.OrderDate
HAVING COUNT(*) > 1;

-- 7. Чеки, на которые приходится более трех продуктов
SELECT sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
HAVING COUNT(DISTINCT sod.ProductID) > 3;

-- 8. Продукты, купленные более трех раз
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID
HAVING COUNT(*) > 3;

-- 9. Продукты, купленные три или пять раз
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID
HAVING COUNT(*) IN (3, 5);

-- 10. Подкатегории, к которым относится более десяти товаров
SELECT p.ProductSubcategoryID
FROM Production.Product AS p
WHERE p.ProductSubcategoryID IS NOT NULL
GROUP BY p.ProductSubcategoryID
HAVING COUNT(*) > 10;

-- 11. Товары, которые всегда покупались в одном экземпляре за одну покупку
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID
HAVING MAX(sod.OrderQty) = 1;

-- 12. Чек (чеки) с наибольшим разнообразием купленных товаров
SELECT TOP 1 WITH TIES sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
ORDER BY COUNT(DISTINCT sod.ProductID) DESC;

-- 13. Чек (чеки) с наибольшей суммой покупки (UnitPrice * OrderQty)
SELECT TOP 1 WITH TIES sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
ORDER BY SUM(sod.UnitPrice * sod.OrderQty) DESC;

-- 14. Количество товаров в каждой подкатегории (подкатегория и цвет определены)
SELECT p.ProductSubcategoryID, COUNT(*) AS ProductCount
FROM Production.Product AS p
WHERE p.ProductSubcategoryID IS NOT NULL
  AND p.Color IS NOT NULL
GROUP BY p.ProductSubcategoryID;

-- 15. Цвета товаров в порядке убывания количества товаров данного цвета
SELECT p.Color
FROM Production.Product AS p
GROUP BY p.Color
ORDER BY COUNT(*) DESC;

-- 16. Товары, которые всегда покупались в количестве более 1 единицы на чек,
--     при этом таких покупок было более двух
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID
HAVING MIN(sod.OrderQty) > 1
   AND COUNT(*) > 2;
