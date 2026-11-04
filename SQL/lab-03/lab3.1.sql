USE AdventureWorks2012;

-- 1. Scalar-valued функция

CREATE FUNCTION dbo.fn_SpecialOfferDate
(
    @SpecialOfferID INT
)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @StartDate DATETIME;
    DECLARE @Result NVARCHAR(100);

    SELECT @StartDate = StartDate
    FROM Sales.SpecialOffer
    WHERE SpecialOfferID = @SpecialOfferID;

    SET @Result =
        DATENAME(MONTH, @StartDate)
        + ', '
        + CAST(DAY(@StartDate) AS NVARCHAR(2))
        + '. '
        + DATENAME(WEEKDAY, @StartDate);

    RETURN @Result;
END;

-- 2. Inline table-valued функция

CREATE FUNCTION dbo.fn_SpecialOfferProducts
(
    @SpecialOfferID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductID,
        p.Name
    FROM Sales.SpecialOfferProduct AS sop
    INNER JOIN Production.Product AS p
        ON sop.ProductID = p.ProductID
    WHERE sop.SpecialOfferID = @SpecialOfferID
);


-- 3. CROSS APPLY

SELECT
    so.SpecialOfferID,
    so.Description,
    f.ProductID,
    f.Name
FROM Sales.SpecialOffer AS so
CROSS APPLY dbo.fn_SpecialOfferProducts(so.SpecialOfferID) AS f;

-- 4. OUTER APPLY

SELECT
    so.SpecialOfferID,
    so.Description,
    f.ProductID,
    f.Name
FROM Sales.SpecialOffer AS so
OUTER APPLY dbo.fn_SpecialOfferProducts(so.SpecialOfferID) AS f;

DROP FUNCTION dbo.fn_SpecialOfferProducts;

-- 5. Multistatement table-valued функция

CREATE FUNCTION dbo.fn_SpecialOfferProducts
(
    @SpecialOfferID INT
)
RETURNS @Products TABLE
(
    ProductID INT,
    Name NVARCHAR(50)
)
AS
BEGIN
    INSERT INTO @Products (ProductID, Name)
    SELECT
        p.ProductID,
        p.Name
    FROM Sales.SpecialOfferProduct AS sop
    INNER JOIN Production.Product AS p
        ON sop.ProductID = p.ProductID
    WHERE sop.SpecialOfferID = @SpecialOfferID;

    RETURN;
END;











