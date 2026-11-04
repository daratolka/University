USE AdventureWorks2012;

-- a
SELECT TOP 0
    StateProvinceID,
    StateProvinceCode,
    CountryRegionCode,
    IsOnlyStateProvinceFlag,
    Name,
    TerritoryID,
    ModifiedDate
INTO dbo.StateProvince
FROM Person.StateProvince;

-- b
ALTER TABLE dbo.StateProvince
ADD CONSTRAINT PK_StateProvince
PRIMARY KEY (StateProvinceID, StateProvinceCode);

-- c
ALTER TABLE dbo.StateProvince
ADD CONSTRAINT CK_StateProvince_TerritoryID_Even
CHECK (TerritoryID % 2 = 0);

-- d
ALTER TABLE dbo.StateProvince
ADD CONSTRAINT DF_StateProvince_TerritoryID
DEFAULT 2 FOR TerritoryID;

-- e
WITH RankedStateProvinces AS
(
    SELECT
        sp.StateProvinceID,
        sp.StateProvinceCode,
        sp.CountryRegionCode,
        sp.IsOnlyStateProvinceFlag,
        sp.Name,
        sp.ModifiedDate,
        a.AddressID,
        ROW_NUMBER() OVER
        (
            PARTITION BY sp.StateProvinceID, sp.StateProvinceCode
            ORDER BY a.AddressID DESC
        ) AS rn
    FROM Person.StateProvince AS sp
    INNER JOIN Person.Address AS a
        ON sp.StateProvinceID = a.StateProvinceID
    INNER JOIN Person.BusinessEntityAddress AS bea
        ON a.AddressID = bea.AddressID
    INNER JOIN Person.AddressType AS at
        ON bea.AddressTypeID = at.AddressTypeID
    WHERE at.Name = 'Shipping'
)
INSERT INTO dbo.StateProvince
(
    StateProvinceCode,
    CountryRegionCode,
    IsOnlyStateProvinceFlag,
    Name,
    ModifiedDate
)
SELECT
    StateProvinceCode,
    CountryRegionCode,
    IsOnlyStateProvinceFlag,
    Name,
    ModifiedDate
FROM RankedStateProvinces
WHERE rn = 1;


SELECT *
FROM dbo.StateProvince;

-- f
ALTER TABLE dbo.StateProvince
ALTER COLUMN IsOnlyStateProvinceFlag SMALLINT NULL;