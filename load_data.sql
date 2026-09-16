/*
    load_data.sql
    Loads the CSV files under /data into the FinanceDB tables using
    BULK INSERT.

    Before running this script, update @DataFolder below to the
    absolute path where you placed the /data folder on the machine
    running SQL Server (SSMS runs on your workstation, but BULK
    INSERT reads the file from the server's own file system, so the
    path has to be one the SQL Server service account can reach).

    Run this after 01 to 05 in the /database folder.
*/

USE FinanceDB;
GO

DECLARE @DataFolder NVARCHAR(260) = N'C:\FinanceDB\data\';

DECLARE @sql NVARCHAR(MAX);

-- Classifications
SET @sql = N'
BULK INSERT dbo.Classifications
FROM ''' + @DataFolder + N'classifications.csv''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0a'',
    CODEPAGE = ''65001'',
    TABLOCK
);';
EXEC sp_executesql @sql;

-- Accounts
SET @sql = N'
BULK INSERT dbo.Accounts
FROM ''' + @DataFolder + N'accounts.csv''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0a'',
    CODEPAGE = ''65001'',
    TABLOCK
);';
EXEC sp_executesql @sql;

-- Transactions
SET @sql = N'
BULK INSERT dbo.Transactions
FROM ''' + @DataFolder + N'transactions.csv''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0a'',
    CODEPAGE = ''65001'',
    TABLOCK
);';
EXEC sp_executesql @sql;

-- Budget
SET @sql = N'
BULK INSERT dbo.Budget
FROM ''' + @DataFolder + N'budget.csv''
WITH (
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0a'',
    CODEPAGE = ''65001'',
    TABLOCK
);';
EXEC sp_executesql @sql;
GO

-- Quick sanity check on row counts
SELECT 'Classifications' AS TableName, COUNT(*) AS RowCount FROM dbo.Classifications
UNION ALL
SELECT 'Accounts', COUNT(*) FROM dbo.Accounts
UNION ALL
SELECT 'Transactions', COUNT(*) FROM dbo.Transactions
UNION ALL
SELECT 'Budget', COUNT(*) FROM dbo.Budget;
GO
