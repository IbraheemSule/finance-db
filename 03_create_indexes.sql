/*
    03_create_indexes.sql
    Supporting indexes for the reporting queries and joins used
    by the views and stored procedures in this project.
    Run after the tables are populated with data.
*/

USE FinanceDB;
GO

CREATE NONCLUSTERED INDEX IX_Transactions_TransactionDate
    ON dbo.Transactions (TransactionDate)
    INCLUDE (AccountCode, ClassCode, RevenueOrExpense, Amount);
GO

CREATE NONCLUSTERED INDEX IX_Transactions_AccountCode
    ON dbo.Transactions (AccountCode);
GO

CREATE NONCLUSTERED INDEX IX_Transactions_ClassCode
    ON dbo.Transactions (ClassCode);
GO

CREATE NONCLUSTERED INDEX IX_Budget_BudgetDate
    ON dbo.Budget (BudgetDate)
    INCLUDE (AccountCode, ClassCode, RevenueOrExpense, BudgetAmount);
GO

CREATE NONCLUSTERED INDEX IX_Budget_AccountCode
    ON dbo.Budget (AccountCode);
GO
