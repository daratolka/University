USE AdventureWorks2012;


-- 2.a
-- Добавляем новые поля в dbo.StateProvince


ALTER TABLE dbo.StateProvince
ADD
    TaxRate SMALLMONEY,
    CurrencyCode NCHAR(3),
    AverageRate MONEY,
    IntTaxRate AS CEILING(TaxRate);


-- 2.b
-- Создаём временную таблицу #StateProvince


DROP TABLE IF EXISTS #StateProvince;

CREATE TABLE #StateProvince
(
    StateProvinceID INT NOT NULL,
    StateProvinceCode NCHAR(3) NOT NULL,
    CountryRegionCode NVARCHAR(3) NOT NULL,
    IsOnlyStateProvinceFlag SMALLINT NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    TerritoryID INT NOT NULL,
    ModifiedDate DATETIME NOT NULL,
    TaxRate SMALLMONEY NULL,
    CurrencyCode NCHAR(3) NULL,
    AverageRate MONEY NULL,

    CONSTRAINT PK_StateProvince_Temp
        PRIMARY KEY (StateProvinceID)
);


-- 2.c
-- Заполняем временную таблицу


TRUNCATE TABLE #StateProvince;

;WITH TaxData AS
(
    SELECT
        StateProvinceID,
        MAX(TaxRate) AS TaxRate
    FROM Sales.SalesTaxRate
    WHERE TaxType = 1
    GROUP BY StateProvinceID
),
CurrencyData AS
(
    SELECT
        CountryRegionCode,
        MAX(CurrencyCode) AS CurrencyCode
    FROM Sales.CountryRegionCurrency
    GROUP BY CountryRegionCode
),
RateData AS
(
    SELECT
        ToCurrencyCode,
        MAX(AverageRate) AS AverageRate
    FROM Sales.CurrencyRate
    GROUP BY ToCurrencyCode
)
INSERT INTO #StateProvince
(
    StateProvinceID,
    StateProvinceCode,
    CountryRegionCode,
    IsOnlyStateProvinceFlag,
    Name,
    TerritoryID,
    ModifiedDate,
    TaxRate,
    CurrencyCode,
    AverageRate
)
SELECT
    sp.StateProvinceID,
    sp.StateProvinceCode,
    sp.CountryRegionCode,
    sp.IsOnlyStateProvinceFlag,
    sp.Name,
    sp.TerritoryID,
    sp.ModifiedDate,
    COALESCE(td.TaxRate, 0),
    cd.CurrencyCode,
    rd.AverageRate
FROM dbo.StateProvince sp
LEFT JOIN TaxData td
    ON sp.StateProvinceID = td.StateProvinceID
LEFT JOIN CurrencyData cd
    ON sp.CountryRegionCode = cd.CountryRegionCode
LEFT JOIN RateData rd
    ON cd.CurrencyCode = rd.ToCurrencyCode;


-- Проверка пункта C

SELECT *
FROM #StateProvince
ORDER BY StateProvinceID;



-- 2.d
-- Удаляем строки с CountryRegionCode = 'CA'


DELETE FROM dbo.StateProvince
WHERE CountryRegionCode = 'CA';


-- Проверка пункта D

SELECT *
FROM dbo.StateProvince
ORDER BY StateProvinceID;


-- 2.e
-- MERGE


SET IDENTITY_INSERT dbo.StateProvince ON;

MERGE dbo.StateProvince AS target
USING #StateProvince AS source
    ON target.StateProvinceID = source.StateProvinceID

WHEN MATCHED THEN
    UPDATE SET
        target.TaxRate = source.TaxRate,
        target.CurrencyCode = source.CurrencyCode,
        target.AverageRate = source.AverageRate

WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        StateProvinceID,
        StateProvinceCode,
        CountryRegionCode,
        IsOnlyStateProvinceFlag,
        Name,
        TerritoryID,
        ModifiedDate,
        TaxRate,
        CurrencyCode,
        AverageRate
    )
    VALUES
    (
        source.StateProvinceID,
        source.StateProvinceCode,
        source.CountryRegionCode,
        source.IsOnlyStateProvinceFlag,
        source.Name,
        source.TerritoryID,
        source.ModifiedDate,
        source.TaxRate,
        source.CurrencyCode,
        source.AverageRate
    )

WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

SET IDENTITY_INSERT dbo.StateProvince OFF;

SELECT
    StateProvinceID,
    StateProvinceCode,
    CountryRegionCode,
    TaxRate,
    CurrencyCode,
    AverageRate
FROM dbo.StateProvince
ORDER BY StateProvinceID;










