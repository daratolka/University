USE AdventureWorks2012;

-- 1. Создание хранимой процедуры с PIVOT

CREATE PROCEDURE dbo.WorkOrdersByMonths
    @Categories NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    SELECT
        Name,
        ' + @Categories + '
    FROM
    (
        SELECT
            p.Name,
            so.Category,
            so.DiscountPct
        FROM Sales.SpecialOffer AS so
        INNER JOIN Sales.SpecialOfferProduct AS sop
            ON so.SpecialOfferID = sop.SpecialOfferID
        INNER JOIN Production.Product AS p
            ON sop.ProductID = p.ProductID
    ) AS SourceTable
    PIVOT
    (
        MAX(DiscountPct)
        FOR Category IN (' + @Categories + ')
    ) AS PivotTable
    ORDER BY Name;';

    EXEC sp_executesql @SQL;
END;

 
