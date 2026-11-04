USE AdventureWorks2012;

CREATE VIEW Sales.v_SpecialOfferProduct
WITH SCHEMABINDING
AS
SELECT
    sop.SpecialOfferID,
    sop.ProductID,
    so.Description,
    so.DiscountPct,
    so.Type,
    so.Category,
    so.StartDate,
    so.EndDate,
    so.MinQty,
    so.MaxQty,
    p.Name
FROM Sales.SpecialOfferProduct AS sop
INNER JOIN Sales.SpecialOffer AS so
    ON sop.SpecialOfferID = so.SpecialOfferID
INNER JOIN Production.Product AS p
    ON sop.ProductID = p.ProductID;

-- 4.a
-- Создаём уникальный кластерный индекс

CREATE UNIQUE CLUSTERED INDEX IX_v_SpecialOfferProduct
ON Sales.v_SpecialOfferProduct
(
    ProductID,
    SpecialOfferID
);


-- 4.b
-- INSTEAD OF триггер


CREATE TRIGGER Sales.tr_v_SpecialOfferProduct
ON Sales.v_SpecialOfferProduct
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT
    IF EXISTS (SELECT 1 FROM inserted)
       AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        DECLARE @SpecialOfferID INT;
        DECLARE @ProductID INT;

        SELECT TOP 1
            @ProductID = p.ProductID
        FROM inserted i
        INNER JOIN Production.Product p
            ON p.Name = i.Name;

        INSERT INTO Sales.SpecialOffer
        (
            Description,
            DiscountPct,
            Type,
            Category,
            StartDate,
            EndDate,
            MinQty,
            MaxQty
        )
        SELECT
            Description,
            DiscountPct,
            Type,
            Category,
            StartDate,
            EndDate,
            MinQty,
            MaxQty
        FROM inserted;

        SET @SpecialOfferID = SCOPE_IDENTITY();

        INSERT INTO Sales.SpecialOfferProduct
        (
            SpecialOfferID,
            ProductID
        )
        VALUES
        (
            @SpecialOfferID,
            @ProductID
        );
    END;

    -- UPDATE
    IF EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        UPDATE so
        SET
            so.Description = i.Description,
            so.DiscountPct = i.DiscountPct,
            so.Type = i.Type,
            so.Category = i.Category,
            so.StartDate = i.StartDate,
            so.EndDate = i.EndDate,
            so.MinQty = i.MinQty,
            so.MaxQty = i.MaxQty
        FROM Sales.SpecialOffer so
        INNER JOIN inserted i
            ON so.SpecialOfferID = i.SpecialOfferID;
    END;

    -- DELETE
    IF EXISTS (SELECT 1 FROM deleted)
       AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        DELETE sop
        FROM Sales.SpecialOfferProduct sop
        INNER JOIN deleted d
            ON sop.SpecialOfferID = d.SpecialOfferID
           AND sop.ProductID = d.ProductID;

        DELETE so
        FROM Sales.SpecialOffer so
        INNER JOIN deleted d
            ON so.SpecialOfferID = d.SpecialOfferID
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Sales.SpecialOfferProduct sop
            WHERE sop.SpecialOfferID = so.SpecialOfferID
        );
    END;
END;


INSERT INTO Sales.v_SpecialOfferProduct
(
    ProductID,
    Description,
    DiscountPct,
    Type,
    Category,
    StartDate,
    EndDate,
    MinQty,
    MaxQty,
    Name
)
VALUES
(
    (SELECT ProductID
     FROM Production.Product
     WHERE Name = 'Adjustable Race'),
    'Lab 4 test',
    15.00,
    'Reseller',
    'Customer',
    GETDATE(),
    DATEADD(DAY, 30, GETDATE()),
    1,
    10,
    'Adjustable Race'
);


SELECT *
FROM Sales.SpecialOffer
WHERE Description = 'Lab 4 test';

SELECT *
FROM Sales.SpecialOfferProduct
WHERE SpecialOfferID =
(
    SELECT SpecialOfferID
    FROM Sales.SpecialOffer
    WHERE Description = 'Lab 4 test'
);


 -- UPDATE через VIEW

UPDATE Sales.v_SpecialOfferProduct
SET DiscountPct = 20.00
WHERE SpecialOfferID = 18
  AND ProductID = 1;

-- DELETE через VIEW

DELETE FROM Sales.v_SpecialOfferProduct
WHERE SpecialOfferID = 18
  AND ProductID = 1;








