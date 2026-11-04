RESTORE FILELISTONLY
FROM DISK = '/var/opt/mssql/backup/AdventureWorks2012.bak';

USE master;

RESTORE DATABASE AdventureWorks2012
FROM DISK = '/var/opt/mssql/backup/AdventureWorks2012.bak'
WITH
MOVE 'AdventureWorks2012_Data' TO '/var/opt/mssql/data/AdventureWorks2012.mdf',
MOVE 'AdventureWorks2012_Log' TO '/var/opt/mssql/data/AdventureWorks2012.ldf';


USE AdventureWorks2012;
-- 9 вариант 


--  1
SELECT BusinessEntityID, JobTitle, BirthDate, HireDate
FROM HumanResources.Employee
WHERE BirthDate >= '1981-01-01'
  AND HireDate > '2003-04-01';


-- 2
SELECT
    SUM(VacationHours) AS SumVacationHours,
    SUM(SickLeaveHours) AS SumSickLeaveHours
FROM HumanResources.Employee;


-- 3
SELECT TOP 3
    BusinessEntityID,
    JobTitle,
    BirthDate,
    Gender,
    HireDate
FROM HumanResources.Employee
ORDER BY HireDate ASC;
