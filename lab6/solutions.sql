-- Практическая работа 6. Оконные функции и предложение OVER
-- СУБД: Microsoft SQL Server (T-SQL), база данных AdventureWorks

-- 1. Доля продаж каждого продукта в стоимости чека
SELECT sod.SalesOrderID,
       sod.ProductID,
       sod.UnitPrice * sod.OrderQty AS LineTotal,
       (sod.UnitPrice * sod.OrderQty)
           / SUM(sod.UnitPrice * sod.OrderQty) OVER (PARTITION BY sod.SalesOrderID) AS OrderShare
FROM Sales.SalesOrderDetail AS sod;

-- 2. Продукт, его цена и разница с ценой самого дешевого продукта в подкатегории
SELECT p.ProductID,
       p.Name,
       p.ListPrice,
       p.ListPrice - MIN(p.ListPrice) OVER (PARTITION BY p.ProductSubcategoryID) AS DiffFromCheapest
FROM Production.Product AS p;

-- 3. Порядковый номер чека для каждого покупателя (по возрастанию даты чека)
SELECT soh.CustomerID,
       soh.SalesOrderID,
       ROW_NUMBER() OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate, soh.SalesOrderID) AS OrderNumber
FROM Sales.SalesOrderHeader AS soh;

-- 4. Продукты, цена которых выше средней цены в подкатегории
-- Способ 1: оконная функция
SELECT t.ProductID
FROM (
    SELECT p.ProductID, p.ListPrice,
           AVG(p.ListPrice) OVER (PARTITION BY p.ProductSubcategoryID) AS AvgPrice
    FROM Production.Product AS p
) AS t
WHERE t.ListPrice > t.AvgPrice;

-- Способ 2: ОТВ с агрегацией и соединением
WITH SubcategoryAvg AS (
    SELECT p.ProductSubcategoryID, AVG(p.ListPrice) AS AvgPrice
    FROM Production.Product AS p
    GROUP BY p.ProductSubcategoryID
)
SELECT p.ProductID
FROM Production.Product AS p
JOIN SubcategoryAvg AS sa ON sa.ProductSubcategoryID = p.ProductSubcategoryID
WHERE p.ListPrice > sa.AvgPrice;

-- 5. Среднее количество продукта на чек среди трех последних по дате чеков с этим продуктом
WITH ProductOrders AS (
    SELECT sod.ProductID,
           soh.SalesOrderID,
           SUM(sod.OrderQty) AS Qty,
           ROW_NUMBER() OVER (
               PARTITION BY sod.ProductID
               ORDER BY soh.OrderDate DESC, soh.SalesOrderID DESC
           ) AS rn
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY sod.ProductID, soh.SalesOrderID, soh.OrderDate
)
SELECT po.ProductID,
       p.Name,
       AVG(1.0 * po.Qty) AS AvgQtyLastThreeOrders
FROM ProductOrders AS po
JOIN Production.Product AS p ON p.ProductID = po.ProductID
WHERE po.rn <= 3
GROUP BY po.ProductID, p.Name;
