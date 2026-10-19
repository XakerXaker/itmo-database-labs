-- Практическая работа 4. Подзапросы
-- СУБД: Microsoft SQL Server (T-SQL), база данных AdventureWorks
--
-- Принятые трактовки:
--  * «самый продаваемый» – наибольшая суммарная величина OrderQty;
--  * «купили N раз» – количество строк в Sales.SalesOrderDetail (фактов покупки);
--  * сумма чека – SUM(UnitPrice * OrderQty).

-- 1. Название самого продаваемого продукта
SELECT p.Name
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
HAVING SUM(sod.OrderQty) >= ALL (
    SELECT SUM(d.OrderQty)
    FROM Sales.SalesOrderDetail AS d
    GROUP BY d.ProductID
);

-- 2. Покупатель, совершивший покупку (чек) на самую большую сумму по UnitPrice
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesOrderID IN (
    SELECT sod.SalesOrderID
    FROM Sales.SalesOrderDetail AS sod
    GROUP BY sod.SalesOrderID
    HAVING SUM(sod.UnitPrice * sod.OrderQty) >= ALL (
        SELECT SUM(d.UnitPrice * d.OrderQty)
        FROM Sales.SalesOrderDetail AS d
        GROUP BY d.SalesOrderID
    )
);

-- 3. Продукты, которые покупал только один покупатель
SELECT p.ProductID, p.Name
FROM Production.Product AS p
WHERE p.ProductID IN (
    SELECT sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY sod.ProductID
    HAVING COUNT(DISTINCT soh.CustomerID) = 1
);

-- 4. Продукты, цена которых выше средней цены в их подкатегории
SELECT p.ProductID, p.Name, p.ListPrice
FROM Production.Product AS p
WHERE p.ListPrice > (
    SELECT AVG(p2.ListPrice)
    FROM Production.Product AS p2
    WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
);

-- 5. Товары, купленные более чем одним покупателем, при этом каждый покупатель
--    товара покупал товары только одного цвета, и товар не входит в покупки
--    покупателей, купивших товары ровно двух цветов
WITH CustomerColors AS (
    SELECT soh.CustomerID, COUNT(DISTINCT p.Color) AS ColorCount
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product AS p ON p.ProductID = sod.ProductID
    GROUP BY soh.CustomerID
)
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY sod.ProductID
HAVING COUNT(DISTINCT soh.CustomerID) > 1
   AND NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail AS d
        JOIN Sales.SalesOrderHeader AS h ON h.SalesOrderID = d.SalesOrderID
        JOIN CustomerColors AS cc ON cc.CustomerID = h.CustomerID
        WHERE d.ProductID = sod.ProductID
          AND cc.ColorCount <> 1
   );

-- 6. Товары, которые покупатель покупал в каждом своем чеке
SELECT DISTINCT sod.ProductID
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID, sod.ProductID
HAVING COUNT(DISTINCT soh.SalesOrderID) = (
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader AS h
    WHERE h.CustomerID = soh.CustomerID
);

-- 7. Покупатели, у которых есть товар, присутствующий в каждом их чеке
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID, sod.ProductID
HAVING COUNT(DISTINCT soh.SalesOrderID) = (
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader AS h
    WHERE h.CustomerID = soh.CustomerID
);

-- 8. Товары, купленные не более чем тремя различными покупателями
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY sod.ProductID
HAVING COUNT(DISTINCT soh.CustomerID) <= 3;

-- 9. Товары, которые всегда покупали вместе с товаром, имеющим максимальную цену
--    в категории (категория – категория самого товара)
WITH ProductCategory AS (
    SELECT p.ProductID, p.ListPrice, ps.ProductCategoryID
    FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
),
TopInCategory AS (
    SELECT pc.ProductID, pc.ProductCategoryID
    FROM ProductCategory AS pc
    WHERE pc.ListPrice = (
        SELECT MAX(pc2.ListPrice)
        FROM ProductCategory AS pc2
        WHERE pc2.ProductCategoryID = pc.ProductCategoryID
    )
)
SELECT DISTINCT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
JOIN ProductCategory AS pc ON pc.ProductID = sod.ProductID
WHERE NOT EXISTS (
    -- чек с этим товаром, в котором нет самого дорогого товара категории
    SELECT 1
    FROM Sales.SalesOrderDetail AS d
    WHERE d.ProductID = sod.ProductID
      AND NOT EXISTS (
            SELECT 1
            FROM Sales.SalesOrderDetail AS d2
            JOIN TopInCategory AS t ON t.ProductID = d2.ProductID
            WHERE d2.SalesOrderID = d.SalesOrderID
              AND t.ProductCategoryID = pc.ProductCategoryID
      )
);

-- 10. Покупатели, у которых не менее двух чеков, и каждый из них содержит
--     не менее трех товаров, купленных другими покупателями не менее трех раз
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
WHERE (
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader AS h
    WHERE h.CustomerID = soh.CustomerID
) >= 2
GROUP BY soh.CustomerID
HAVING NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderHeader AS h
    WHERE h.CustomerID = soh.CustomerID
      AND (
        SELECT COUNT(DISTINCT d.ProductID)
        FROM Sales.SalesOrderDetail AS d
        WHERE d.SalesOrderID = h.SalesOrderID
          AND (
            SELECT COUNT(*)
            FROM Sales.SalesOrderDetail AS d2
            JOIN Sales.SalesOrderHeader AS h2 ON h2.SalesOrderID = d2.SalesOrderID
            WHERE d2.ProductID = d.ProductID
              AND h2.CustomerID <> h.CustomerID
          ) >= 3
      ) < 3
);

-- 11. Чеки, в которых каждый товар был куплен дважды этим же покупателем
--     (товар встречается ровно в двух чеках покупателя)
SELECT soh.SalesOrderID
FROM Sales.SalesOrderHeader AS soh
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS d
    WHERE d.SalesOrderID = soh.SalesOrderID
      AND (
        SELECT COUNT(DISTINCT h.SalesOrderID)
        FROM Sales.SalesOrderHeader AS h
        JOIN Sales.SalesOrderDetail AS d2 ON d2.SalesOrderID = h.SalesOrderID
        WHERE h.CustomerID = soh.CustomerID
          AND d2.ProductID = d.ProductID
      ) <> 2
);

-- 12. Товары, купленные минимум три раза различными покупателями
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY sod.ProductID
HAVING COUNT(DISTINCT soh.CustomerID) >= 3;

-- 13. Подкатегории, содержащие более трех товаров, купленных более трех раз
SELECT ps.ProductSubcategoryID, ps.Name
FROM Production.ProductSubcategory AS ps
WHERE (
    SELECT COUNT(*)
    FROM Production.Product AS p
    WHERE p.ProductSubcategoryID = ps.ProductSubcategoryID
      AND (
        SELECT COUNT(*)
        FROM Sales.SalesOrderDetail AS sod
        WHERE sod.ProductID = p.ProductID
      ) > 3
) > 3;

-- 14. Товары, купленные не более трех раз и как минимум дважды одним покупателем
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID
HAVING COUNT(*) <= 3
   AND sod.ProductID IN (
        SELECT d.ProductID
        FROM Sales.SalesOrderDetail AS d
        JOIN Sales.SalesOrderHeader AS h ON h.SalesOrderID = d.SalesOrderID
        GROUP BY h.CustomerID, d.ProductID
        HAVING COUNT(*) >= 2
   );
