USE AdventureWorks2012;

-- 3.a
DROP TABLE IF EXISTS Sales.SpecialOfferHst;

CREATE TABLE Sales.SpecialOfferHst
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(10) NOT NULL,
    ModifiedDate DATETIME NOT NULL,
    SourceID INT NOT NULL,
    UserName NVARCHAR(128) NOT NULL
);



-- 3.b
-- Создаём три AFTER-триггера


USE AdventureWorks2012;

-- INSERT
CREATE TRIGGER Sales.tr_SpecialOffer_Insert
ON Sales.SpecialOffer
AFTER INSERT
AS
BEGIN
    INSERT INTO Sales.SpecialOfferHst
    (
        Action,
        ModifiedDate,
        SourceID,
        UserName
    )
    SELECT
        'insert',
        GETDATE(),
        SpecialOfferID,
        SUSER_SNAME()
    FROM inserted;
END;


-- UPDATE
CREATE TRIGGER Sales.tr_SpecialOffer_Update
ON Sales.SpecialOffer
AFTER UPDATE
AS
BEGIN
    INSERT INTO Sales.SpecialOfferHst
    (
        Action,
        ModifiedDate,
        SourceID,
        UserName
    )
    SELECT
        'update',
        GETDATE(),
        SpecialOfferID,
        SUSER_SNAME()
    FROM inserted;
END;


-- DELETE
CREATE TRIGGER Sales.tr_SpecialOffer_Delete
ON Sales.SpecialOffer
AFTER DELETE
AS
BEGIN
    INSERT INTO Sales.SpecialOfferHst
    (
        Action,
        ModifiedDate,
        SourceID,
        UserName
    )
    SELECT
        'delete',
        GETDATE(),
        SpecialOfferID,
        SUSER_SNAME()
    FROM deleted;
END;


-- 3.c
-- Создаём представление VIEW




CREATE VIEW Sales.v_SpecialOffer
WITH ENCRYPTION
AS
SELECT *
FROM Sales.SpecialOffer;


-- 3.d
-- INSERT -> UPDATE -> DELETE через VIEW


INSERT INTO Sales.v_SpecialOffer
(
    Description,
    DiscountPct,
    Type,
    Category,
    StartDate,
    EndDate,
    MinQty,
    MaxQty,
    rowguid,
    ModifiedDate
)
VALUES
(
    'Lab 3 test',
    10.00,
    'No Discount',
    'Reseller',
    GETDATE(),
    DATEADD(DAY, 30, GETDATE()),
    1,
    10,
    NEWID(),
    GETDATE()
);

UPDATE Sales.v_SpecialOffer
SET DiscountPct = 15.00
WHERE Description = 'Lab 3 test';

DELETE FROM Sales.v_SpecialOffer
WHERE Description = 'Lab 3 test';







