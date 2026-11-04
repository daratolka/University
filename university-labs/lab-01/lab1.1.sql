use newdatabase;
SELECT name
FROM sys.schemas
WHERE name = 'sales';
CREATE SCHEMA  persons;

CREATE TABLE  sales.orders (
orderNum int null 
);

BACKUP DATABASE NewDatabase
TO DISK = '/var/opt/mssql/backup/NewDatabase.bak'
WITH INIT;

use master;
DROP database newdatabase;

RESTORE DATABASE NewDatabase
FROM DISK = '/var/opt/mssql/backup/NewDatabase.bak';