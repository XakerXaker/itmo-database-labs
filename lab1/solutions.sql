-- 1. Названия продуктов, цвет и размер
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p;

-- 2. Название, цвет и размер продуктов с ценой более 100
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p
WHERE p.ListPrice > 100;

-- 3. Название, цвет и размер продуктов с ценой менее 100 и цветом Black
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p
WHERE p.ListPrice < 100
  AND p.Color = 'Black';

-- 4. То же, упорядочив по возрастанию стоимости
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p
WHERE p.ListPrice < 100
  AND p.Color = 'Black'
ORDER BY p.ListPrice ASC;

-- 5. Название и размер первых трех самых дорогих товаров цвета Black
SELECT TOP 3 p.Name, p.Size
FROM Production.Product AS p
WHERE p.Color = 'Black'
ORDER BY p.ListPrice DESC;

-- 6. Название и цвет продуктов, для которых определены и цвет, и размер
SELECT p.Name, p.Color
FROM Production.Product AS p
WHERE p.Color IS NOT NULL
  AND p.Size IS NOT NULL;

-- 7. Неповторяющиеся цвета продуктов с ценой от 10 до 50 включительно
SELECT DISTINCT p.Color
FROM Production.Product AS p
WHERE p.ListPrice BETWEEN 10 AND 50;

-- 8. Цвета продуктов, у которых в имени первая буква 'L', а третья 'N'
SELECT p.Color
FROM Production.Product AS p
WHERE p.Name LIKE 'L_N%';

-- 9. Названия продуктов, начинающиеся на 'D' или 'M', длина имени более трех символов
SELECT p.Name
FROM Production.Product AS p
WHERE p.Name LIKE '[DM]%'
  AND LEN(p.Name) > 3;

-- 10. Названия продуктов, у которых дата начала продаж не позднее 2012 года
SELECT p.Name
FROM Production.Product AS p
WHERE YEAR(p.SellStartDate) <= 2012;

-- 11. Названия всех подкатегорий товаров
SELECT ps.Name
FROM Production.ProductSubcategory AS ps;

-- 12. Названия всех категорий товаров
SELECT pc.Name
FROM Production.ProductCategory AS pc;

-- 13. Имена клиентов из Person, у которых обращение «Mr.»
SELECT pp.FirstName, pp.MiddleName, pp.LastName
FROM Person.Person AS pp
WHERE pp.Title = 'Mr.';

-- 14. Имена клиентов из Person, у которых обращение не определено
SELECT pp.FirstName, pp.MiddleName, pp.LastName
FROM Person.Person AS pp
WHERE pp.Title IS NULL;
