/*
    01_create_database.sql
    Creates the FinanceDB database.
    Run this script first, connected to the master database.
*/

USE master;
GO

IF DB_ID(N'FinanceDB') IS NOT NULL
BEGIN
    ALTER DATABASE FinanceDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FinanceDB;
END
GO

CREATE DATABASE FinanceDB;
GO

ALTER DATABASE FinanceDB SET RECOVERY SIMPLE;
GO

USE FinanceDB;
GO
