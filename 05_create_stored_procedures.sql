/*
    05_create_stored_procedures.sql
    Stored procedures for common reporting questions.
    Run after the views are created.
*/

USE FinanceDB;
GO

-- Revenue, expenses and net income for a single calendar month
CREATE OR ALTER PROCEDURE dbo.usp_GetProfitAndLossByMonth
    @Year   INT,
    @Month  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MonthStart DATE = DATEFROMPARTS(@Year, @Month, 1);

    SELECT
        @MonthStart AS MonthStart,
        SUM(CASE WHEN RevenueOrExpense = 'REVENUE' THEN TotalAmount ELSE 0 END)  AS TotalRevenue,
        SUM(CASE WHEN RevenueOrExpense = 'EXPENSES' THEN TotalAmount ELSE 0 END) AS TotalExpenses,
        SUM(CASE WHEN RevenueOrExpense = 'REVENUE' THEN TotalAmount ELSE -TotalAmount END) AS NetIncome
    FROM dbo.vw_ProfitAndLoss
    WHERE MonthStart = @MonthStart;
END
GO

-- Profit and loss by Level1 category over a date range
CREATE OR ALTER PROCEDURE dbo.usp_GetProfitAndLossByRange
    @StartDate  DATE,
    @EndDate    DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Level1,
        RevenueOrExpense,
        SUM(TotalAmount) AS TotalAmount
    FROM dbo.vw_ProfitAndLoss
    WHERE MonthStart >= @StartDate
      AND MonthStart <= @EndDate
    GROUP BY Level1, RevenueOrExpense
    ORDER BY RevenueOrExpense, Level1;
END
GO

-- Budget vs actual, optionally scoped to one department, over a date range
CREATE OR ALTER PROCEDURE dbo.usp_GetBudgetVariance
    @StartDate  DATE,
    @EndDate    DATE,
    @ClassCode  VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MonthStart,
        ClassCode,
        ClassName,
        AccountCode,
        AccountName,
        RevenueOrExpense,
        ActualAmount,
        BudgetAmount,
        Variance,
        VariancePercent
    FROM dbo.vw_BudgetVsActual
    WHERE MonthStart >= @StartDate
      AND MonthStart <= @EndDate
      AND (@ClassCode IS NULL OR ClassCode = @ClassCode)
    ORDER BY MonthStart, ClassCode, AccountCode;
END
GO

-- Highest spending vendors over a date range
CREATE OR ALTER PROCEDURE dbo.usp_GetTopVendorsByExpense
    @StartDate  DATE,
    @EndDate    DATE,
    @TopN       INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        VendorOrClient,
        COUNT(*)          AS TransactionCount,
        SUM(Amount)        AS TotalSpent
    FROM dbo.Transactions
    WHERE RevenueOrExpense = 'EXPENSES'
      AND TransactionDate >= @StartDate
      AND TransactionDate <= @EndDate
      AND VendorOrClient IS NOT NULL
    GROUP BY VendorOrClient
    ORDER BY SUM(Amount) DESC;
END
GO
