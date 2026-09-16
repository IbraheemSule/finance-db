/*
    04_create_views.sql
    Reporting views built on top of the base tables.
    Run after the tables are created and populated.
*/

USE FinanceDB;
GO

-- Actual transactions rolled up to a month, with the account hierarchy attached
CREATE OR ALTER VIEW dbo.vw_MonthlyActuals
AS
SELECT
    YEAR(t.TransactionDate)            AS TransactionYear,
    MONTH(t.TransactionDate)           AS TransactionMonth,
    DATEFROMPARTS(YEAR(t.TransactionDate), MONTH(t.TransactionDate), 1) AS MonthStart,
    t.ClassCode,
    c.ClassName,
    t.AccountCode,
    a.AccountName,
    a.Level1,
    a.Level2,
    t.RevenueOrExpense,
    SUM(t.Amount)                      AS ActualAmount
FROM dbo.Transactions AS t
INNER JOIN dbo.Accounts AS a
    ON a.AccountCode = t.AccountCode
INNER JOIN dbo.Classifications AS c
    ON c.ClassCode = t.ClassCode
GROUP BY
    YEAR(t.TransactionDate),
    MONTH(t.TransactionDate),
    t.ClassCode,
    c.ClassName,
    t.AccountCode,
    a.AccountName,
    a.Level1,
    a.Level2,
    t.RevenueOrExpense;
GO

-- Budget rolled up the same way, so it lines up with vw_MonthlyActuals
CREATE OR ALTER VIEW dbo.vw_MonthlyBudget
AS
SELECT
    YEAR(b.BudgetDate)                 AS BudgetYear,
    MONTH(b.BudgetDate)                AS BudgetMonth,
    DATEFROMPARTS(YEAR(b.BudgetDate), MONTH(b.BudgetDate), 1) AS MonthStart,
    b.ClassCode,
    c.ClassName,
    b.AccountCode,
    a.AccountName,
    a.Level1,
    a.Level2,
    b.RevenueOrExpense,
    SUM(b.BudgetAmount)                AS BudgetAmount
FROM dbo.Budget AS b
INNER JOIN dbo.Accounts AS a
    ON a.AccountCode = b.AccountCode
INNER JOIN dbo.Classifications AS c
    ON c.ClassCode = b.ClassCode
GROUP BY
    YEAR(b.BudgetDate),
    MONTH(b.BudgetDate),
    b.ClassCode,
    c.ClassName,
    b.AccountCode,
    a.AccountName,
    a.Level1,
    a.Level2,
    b.RevenueOrExpense;
GO

-- Actual vs budget, side by side, with a variance and a variance percentage
CREATE OR ALTER VIEW dbo.vw_BudgetVsActual
AS
SELECT
    COALESCE(act.MonthStart, bud.MonthStart)           AS MonthStart,
    COALESCE(act.AccountCode, bud.AccountCode)         AS AccountCode,
    COALESCE(act.AccountName, bud.AccountName)         AS AccountName,
    COALESCE(act.ClassCode, bud.ClassCode)             AS ClassCode,
    COALESCE(act.ClassName, bud.ClassName)             AS ClassName,
    COALESCE(act.Level1, bud.Level1)                   AS Level1,
    COALESCE(act.Level2, bud.Level2)                   AS Level2,
    COALESCE(act.RevenueOrExpense, bud.RevenueOrExpense) AS RevenueOrExpense,
    ISNULL(act.ActualAmount, 0)                        AS ActualAmount,
    ISNULL(bud.BudgetAmount, 0)                        AS BudgetAmount,
    ISNULL(act.ActualAmount, 0) - ISNULL(bud.BudgetAmount, 0) AS Variance,
    CASE
        WHEN ISNULL(bud.BudgetAmount, 0) = 0 THEN NULL
        ELSE ROUND((ISNULL(act.ActualAmount, 0) - bud.BudgetAmount) / bud.BudgetAmount * 100, 2)
    END                                                 AS VariancePercent
FROM dbo.vw_MonthlyActuals AS act
FULL OUTER JOIN dbo.vw_MonthlyBudget AS bud
    ON  bud.MonthStart  = act.MonthStart
    AND bud.AccountCode = act.AccountCode;
GO

-- Profit and loss statement, rolled up to the Level1 category per month
CREATE OR ALTER VIEW dbo.vw_ProfitAndLoss
AS
SELECT
    MonthStart,
    Level1,
    RevenueOrExpense,
    SUM(ActualAmount) AS TotalAmount
FROM dbo.vw_MonthlyActuals
GROUP BY MonthStart, Level1, RevenueOrExpense;
GO
