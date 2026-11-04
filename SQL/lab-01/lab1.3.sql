

USE AdventureWorks2012;

-- 1
SELECT
    e.BusinessEntityID,
    e.JobTitle,
    AVG(eph.Rate) AS AverageRate
FROM HumanResources.Employee AS e
INNER JOIN HumanResources.EmployeePayHistory AS eph
    ON e.BusinessEntityID = eph.BusinessEntityID
GROUP BY
    e.BusinessEntityID,
    e.JobTitle;


-- 2
SELECT
    e.BusinessEntityID,
    e.JobTitle,
    eph.Rate,
    CASE
        WHEN eph.Rate <= 50
            THEN 'less or equal 50'
        WHEN eph.Rate > 50 AND eph.Rate <= 100
            THEN 'more than 50 but less or equal 100'
        ELSE 'more than 100'
    END AS RateReport
FROM HumanResources.Employee AS e
INNER JOIN HumanResources.EmployeePayHistory AS eph
    ON e.BusinessEntityID = eph.BusinessEntityID
ORDER BY
    e.BusinessEntityID,
    eph.RateChangeDate;


-- 3
SELECT
    d.Name,
    MAX(eph.Rate) AS MaxRate
FROM HumanResources.Department AS d
INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
    ON d.DepartmentID = edh.DepartmentID
INNER JOIN HumanResources.Employee AS e
    ON edh.BusinessEntityID = e.BusinessEntityID
INNER JOIN HumanResources.EmployeePayHistory AS eph
    ON e.BusinessEntityID = eph.BusinessEntityID
WHERE edh.EndDate IS NULL
GROUP BY d.Name
HAVING MAX(eph.Rate) > 60
ORDER BY MaxRate;


-- колинчество сотрудников работающих в ночную смену

-- количество сотрудников, работающих в ночную смену
SELECT COUNT(DISTINCT edh.BusinessEntityID) AS NightShiftEmployees
FROM HumanResources.EmployeeDepartmentHistory AS edh
INNER JOIN HumanResources.Shift AS s
    ON edh.ShiftID = s.ShiftID
WHERE s.Name = 'Night'











