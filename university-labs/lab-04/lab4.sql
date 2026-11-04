USE AdventureWorks2012;


-- ============================================================
-- ЗАДАНИЕ 1
-- Employee -> XML -> временная таблица
-- ============================================================

DECLARE @EmployeesXML XML;

SELECT @EmployeesXML =
(
    SELECT
        BusinessEntityID AS [@ID],
        NationalIDNumber,
        JobTitle
    FROM HumanResources.Employee
    FOR XML PATH('Employee'), ROOT('Employees'), TYPE
);

DROP TABLE IF EXISTS #Employees;

CREATE TABLE #Employees
(
    BusinessEntityID INT,
    NationalIDNumber NVARCHAR(15),
    JobTitle NVARCHAR(50)
);

INSERT INTO #Employees
(
    BusinessEntityID,
    NationalIDNumber,
    JobTitle
)
SELECT
    X.Employee.value('(@ID)[1]', 'INT'),
    X.Employee.value('(NationalIDNumber/text())[1]', 'NVARCHAR(15)'),
    X.Employee.value('(JobTitle/text())[1]', 'NVARCHAR(50)')
FROM @EmployeesXML.nodes('/Employees/Employee') AS X(Employee);

SELECT *
FROM #Employees;


-- ============================================================
-- ЗАДАНИЕ 2
-- Product -> XML -> хранимая процедура
-- ============================================================

DROP PROCEDURE IF EXISTS dbo.GetProductsFromXML;

EXEC
(
'CREATE PROCEDURE dbo.GetProductsFromXML
    @XML XML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        X.Product.value(''(@ID)[1]'', ''INT'') AS ProductID,
        X.Product.value(''(Name/text())[1]'', ''NVARCHAR(50)'') AS Name,
        X.Product.value(''(ProductNumber/text())[1]'', ''NVARCHAR(25)'') AS ProductNumber
    FROM @XML.nodes(''/Products/Product'') AS X(Product);
END'
);

DECLARE @ProductsXML XML;

SELECT @ProductsXML =
(
    SELECT
        ProductID AS [@ID],
        Name,
        ProductNumber
    FROM Production.Product
    FOR XML PATH('Product'), ROOT('Products'), TYPE
);

EXEC dbo.GetProductsFromXML @ProductsXML;


-- ============================================================
-- ЗАДАНИЕ 3
-- Person -> XML -> временная таблица
-- ============================================================

DECLARE @PersonsXML XML;

SELECT @PersonsXML =
(
    SELECT
        BusinessEntityID AS [ID],
        FirstName,
        LastName
    FROM Person.Person
    FOR XML PATH('Person'), ROOT('Persons'), TYPE
);

DROP TABLE IF EXISTS #Persons;

CREATE TABLE #Persons
(
    BusinessEntityID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50)
);

INSERT INTO #Persons
(
    BusinessEntityID,
    FirstName,
    LastName
)
SELECT
    X.Person.value('(ID/text())[1]', 'INT'),
    X.Person.value('(FirstName/text())[1]', 'NVARCHAR(50)'),
    X.Person.value('(LastName/text())[1]', 'NVARCHAR(50)')
FROM @PersonsXML.nodes('/Persons/Person') AS X(Person);

SELECT *
FROM #Persons;


-- ============================================================
-- ЗАДАНИЕ 4
-- Vendor -> XML -> хранимая процедура
-- ============================================================

DROP PROCEDURE IF EXISTS dbo.GetVendorsFromXML;

EXEC
(
'CREATE PROCEDURE dbo.GetVendorsFromXML
    @XML XML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        X.Vendor.value(''(ID/text())[1]'', ''INT'') AS BusinessEntityID,
        X.Vendor.value(''(Name/text())[1]'', ''NVARCHAR(50)'') AS Name,
        X.Vendor.value(''(AccountNumber/text())[1]'', ''NVARCHAR(15)'') AS AccountNumber
    FROM @XML.nodes(''/Vendors/Vendor'') AS X(Vendor);
END'
);

DECLARE @VendorsXML XML;

SELECT @VendorsXML =
(
    SELECT
        BusinessEntityID AS [ID],
        Name,
        AccountNumber
    FROM Purchasing.Vendor
    FOR XML PATH('Vendor'), ROOT('Vendors'), TYPE
);

EXEC dbo.GetVendorsFromXML @VendorsXML;


-- ============================================================
-- ЗАДАНИЕ 5
-- Location -> XML -> временная таблица
-- Все значения являются атрибутами
-- ============================================================

DECLARE @LocationsXML XML;

SELECT @LocationsXML =
(
    SELECT
        LocationID AS [@ID],
        Name AS [@Name],
        CostRate AS [@Cost]
    FROM Production.Location
    FOR XML PATH('Location'), ROOT('Locations'), TYPE
);

DROP TABLE IF EXISTS #Locations;

CREATE TABLE #Locations
(
    LocationID INT,
    Name NVARCHAR(50),
    CostRate SMALLMONEY
);

INSERT INTO #Locations
(
    LocationID,
    Name,
    CostRate
)
SELECT
    X.Location.value('(@ID)[1]', 'INT'),
    X.Location.value('(@Name)[1]', 'NVARCHAR(50)'),
    X.Location.value('(@Cost)[1]', 'SMALLMONEY')
FROM @LocationsXML.nodes('/Locations/Location') AS X(Location);

--<History>
--    <Transaction>
 --       <Start>2003-02-15</Start>
   --     <Department>
     --       <Group>Executive General and Administration</Group>
       --     <Name>Executive</Name>
   --     </Department>
    --</Transaction>

  --  <Transaction>
    --    <Start>2002-03-03</Start>
      --  <Department>
        --    <Group>Research and Development</Group>
          --  <Name>Engineering</Name>
  --      </Department>
  --  </Transaction>
--</History>


SELECT *
FROM #Locations;


-- ============================================================
-- ЗАДАНИЕ 6
-- CreditCard -> XML -> хранимая процедура
-- ============================================================

DROP PROCEDURE IF EXISTS dbo.GetCreditCardsFromXML;

EXEC
(
'CREATE PROCEDURE dbo.GetCreditCardsFromXML
    @XML XML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        X.Card.value(''(@ID)[1]'', ''INT'') AS CreditCardID,
        X.Card.value(''(@Type)[1]'', ''NVARCHAR(50)'') AS CardType,
        X.Card.value(''(@Number)[1]'', ''NVARCHAR(25)'') AS CardNumber
    FROM @XML.nodes(''/CreditCards/Card'') AS X(Card);
END'
);

DECLARE @CreditCardsXML XML;

SELECT @CreditCardsXML =
(
    SELECT
        CreditCardID AS [@ID],
        CardType AS [@Type],
        CardNumber AS [@Number]
    FROM Sales.CreditCard
    FOR XML PATH('Card'), ROOT('CreditCards'), TYPE
);

EXEC dbo.GetCreditCardsFromXML @CreditCardsXML;


-- ============================================================
-- ЗАДАНИЕ 7
-- Product + ProductModel -> XML -> временная таблица
-- ============================================================

DECLARE @ProductsModelsXML XML;

SELECT @ProductsModelsXML =
(
    SELECT
        p.ProductID AS [@ID],
        p.Name AS [Name],
        pm.ProductModelID AS [Model/@ID],
        pm.Name AS [Model/Name]
    FROM Production.Product AS p
    INNER JOIN Production.ProductModel AS pm
        ON p.ProductModelID = pm.ProductModelID
    FOR XML PATH('Product'), ROOT('Products'), TYPE
);

DROP TABLE IF EXISTS #ProductsModels;

CREATE TABLE #ProductsModels
(
    ProductID INT,
    ProductName NVARCHAR(50),
    ProductModelID INT,
    ProductModelName NVARCHAR(50)
);

INSERT INTO #ProductsModels
(
    ProductID,
    ProductName,
    ProductModelID,
    ProductModelName
)
SELECT
    X.Product.value('(@ID)[1]', 'INT'),
    X.Product.value('(Name/text())[1]', 'NVARCHAR(50)'),
    X.Product.value('(Model/@ID)[1]', 'INT'),
    X.Product.value('(Model/Name/text())[1]', 'NVARCHAR(50)')
FROM @ProductsModelsXML.nodes('/Products/Product') AS X(Product);

SELECT *
FROM #ProductsModels;


-- ============================================================
-- ЗАДАНИЕ 8
-- Address + StateProvince -> XML -> процедура
-- ============================================================

DROP PROCEDURE IF EXISTS dbo.GetAddressesFromXML;

EXEC
(
'CREATE PROCEDURE dbo.GetAddressesFromXML
    @XML XML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        X.Address.value(''(@ID)[1]'', ''INT'') AS AddressID,
        X.Address.value(''(City/text())[1]'', ''NVARCHAR(30)'') AS City,
        X.Address.value(''(Province/@ID)[1]'', ''INT'') AS StateProvinceID,
        X.Address.value(''(Province/Region/text())[1]'', ''NVARCHAR(3)'') AS CountryRegionCode
    FROM @XML.nodes(''/Addresses/Address'') AS X(Address);
END'
);

DECLARE @AddressesXML XML;

SELECT @AddressesXML =
(
    SELECT
        a.AddressID AS [@ID],
        a.City AS [City],
        sp.StateProvinceID AS [Province/@ID],
        sp.CountryRegionCode AS [Province/Region]
    FROM Person.Address AS a
    INNER JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
    FOR XML PATH('Address'), ROOT('Addresses'), TYPE
);

EXEC dbo.GetAddressesFromXML @AddressesXML;


-- ============================================================
-- ЗАДАНИЕ 9
-- EmployeeDepartmentHistory + Department
-- XML -> временная таблица с одной XML-колонкой
-- ============================================================

DECLARE @HistoryXML XML;

SELECT @HistoryXML =
(
    SELECT
        edh.StartDate AS [Start],
        edh.EndDate AS [End],
        d.GroupName AS [Department/Group],
        d.Name AS [Department/Name]
    FROM HumanResources.EmployeeDepartmentHistory AS edh
    INNER JOIN HumanResources.Department AS d
        ON edh.DepartmentID = d.DepartmentID
    FOR XML PATH('Transaction'), ROOT('History'), TYPE
);

DROP TABLE IF EXISTS #DepartmentsXML;

CREATE TABLE #DepartmentsXML
(
    DepartmentXML XML
);

INSERT INTO #DepartmentsXML
(
    DepartmentXML
)
SELECT
    X.TransactionNode.query('./Department')
FROM @HistoryXML.nodes('/History/Transaction') AS X(TransactionNode);

SELECT *
FROM #DepartmentsXML;


-- ============================================================
-- ЗАДАНИЕ 10
-- Person + Password -> XML -> хранимая процедура
-- ============================================================

DROP PROCEDURE IF EXISTS dbo.GetPasswordsFromXML;

EXEC
(
'CREATE PROCEDURE dbo.GetPasswordsFromXML
    @XML XML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        X.Person.query(''Password'') AS PasswordXML
    FROM @XML.nodes(''/Persons/Person'') AS X(Person);
END'
);

DECLARE @PersonsPasswordXML XML;

SELECT @PersonsPasswordXML =
(
    SELECT TOP 100
        p.FirstName,
        p.LastName,
        pass.ModifiedDate AS [Password/Date],
        pass.BusinessEntityID AS [Password/ID]
    FROM Person.Person AS p
    INNER JOIN Person.Password AS pass
        ON p.BusinessEntityID = pass.BusinessEntityID
    ORDER BY pass.BusinessEntityID
    FOR XML PATH('Person'), ROOT('Persons'), TYPE
);

EXEC dbo.GetPasswordsFromXML @PersonsPasswordXML;