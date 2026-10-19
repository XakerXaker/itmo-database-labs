--
-- «Факт покупки» – строка в Sales.SalesOrderDetail,
-- стоимость чека – SUM(UnitPrice * OrderQty).

-- 1. Среднее количество покупок на чек для каждого покупателя
-- Способ 1: запрос как источник данных (количество строк в каждом чеке, затем среднее)
SELECT t.CustomerID, AVG(1.0 * t.PurchaseCount) AS AvgPurchasesPerOrder
FROM (
    SELECT soh.CustomerID, soh.SalesOrderID, COUNT(*) AS PurchaseCount
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
) AS t
GROUP BY t.CustomerID;

-- Способ 2: общее число покупок, деленное на число чеков
SELECT soh.CustomerID,
       1.0 * COUNT(*) / COUNT(DISTINCT soh.SalesOrderID) AS AvgPurchasesPerOrder
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID;

-- 2. Для каждого продукта и покупателя: доля фактов покупки данного продукта
--    в общем числе фактов покупки покупателя
WITH CustomerTotals AS (
    SELECT soh.CustomerID, COUNT(*) AS TotalCount
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID
),
CustomerProducts AS (
    SELECT soh.CustomerID, sod.ProductID, COUNT(*) AS ProductCount
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID, sod.ProductID
)
SELECT cp.ProductID, cp.CustomerID,
       1.0 * cp.ProductCount / ct.TotalCount AS PurchaseRatio
FROM CustomerProducts AS cp
JOIN CustomerTotals AS ct ON ct.CustomerID = cp.CustomerID;

-- 3. Название продукта, число фактов покупки, число покупателей
SELECT p.Name,
       COUNT(*) AS PurchaseCount,
       COUNT(DISTINCT soh.CustomerID) AS CustomerCount
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod ON sod.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY p.ProductID, p.Name;

-- 4. Для каждого покупателя: максимальная и минимальная стоимость чека
SELECT t.CustomerID, MAX(t.OrderTotal) AS MaxTotal, MIN(t.OrderTotal) AS MinTotal
FROM (
    SELECT soh.CustomerID, soh.SalesOrderID,
           SUM(sod.UnitPrice * sod.OrderQty) AS OrderTotal
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
) AS t
GROUP BY t.CustomerID;

-- 5. Покупатели, у которых нет ни одной пары чеков с одинаковым
--    количеством наименований товаров
WITH OrderSizes AS (
    SELECT soh.CustomerID, soh.SalesOrderID,
           COUNT(DISTINCT sod.ProductID) AS ProductKinds
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
)
SELECT DISTINCT os.CustomerID
FROM OrderSizes AS os
WHERE os.CustomerID NOT IN (
    SELECT o.CustomerID
    FROM OrderSizes AS o
    GROUP BY o.CustomerID, o.ProductKinds
    HAVING COUNT(*) > 1
);

-- 6. Покупатели, у которых все купленные товары покупались минимум в двух разных чеках
WITH CustomerProducts AS (
    SELECT soh.CustomerID, sod.ProductID,
           COUNT(DISTINCT soh.SalesOrderID) AS OrderCount
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID, sod.ProductID
)
SELECT cp.CustomerID
FROM CustomerProducts AS cp
GROUP BY cp.CustomerID
HAVING MIN(cp.OrderCount) >= 2;
