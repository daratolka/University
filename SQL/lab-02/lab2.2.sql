-- ==========================================
-- ЗАДАНИЕ №2
-- ВАРИАНТ 9
-- ==========================================


-- a) Добавляем новые поля в dbo.StateProvince

ALTER TABLE dbo.StateProvince
ADD
    TaxRate SMALLMONEY,
    CurrencyCode NCHAR(3),
    AverageRate MONEY,
    IntTaxRate AS CEILING(TaxRate);


-- b) Создаём временную таблицу

CREATE TABLE #StateProvince
(
    StateProvinceID INT PRIMARY KEY,
    StateProvinceCode NCHAR(3),
    CountryRegionCode NVARCHAR(3),
    IsOnlyStateProvinceFlag BIT,
    Name NVARCHAR(50),
    TerritoryID INT,
    ModifiedDate DATETIME,
    TaxRate SMALLMONEY,
    CurrencyCode NCHAR(3),
    AverageRate MONEY
);


-- c) Заполняем временную таблицу
-- Используем CTE для определения максимального курса валюты

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


-- d) Удаляем строки для Канады

DELETE FROM dbo.StateProvince
WHERE CountryRegionCode = 'CA';


-- e) MERGE

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


-- Проверка результата

SELECT
    StateProvinceID,
    StateProvinceCode,
    CountryRegionCode,
    Name,
    TaxRate,
    CurrencyCode,
    AverageRate,
    IntTaxRate
FROM dbo.StateProvince
ORDER BY StateProvinceID;
