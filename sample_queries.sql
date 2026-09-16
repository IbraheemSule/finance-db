/*
    sample_queries.sql
    A handful of queries that show how the views and stored
    procedures in this project are meant to be used. These are
    examples, not part of the setup, so nothing here needs to be
    run for the database to work.
*/

USE FinanceDB;
GO

-- Net income for March 2024
EXEC dbo.usp_GetProfitAndLossByMonth @Year = 2024, @Month = 3;
GO

-- Full year profit and loss for 2023, grouped by category
EXEC dbo.usp_GetProfitAndLossByRange
    @StartDate = '2023-01-01',
    @EndDate   = '2023-12-31';
GO

-- Budget variance for Sales & Marketing across all of 2024
EXEC dbo.usp_GetBudgetVariance
    @StartDate = '2024-01-01',
    @EndDate   = '2024-12-31',
    @ClassCode = 'S&M';
GO

-- Top 5 vendors by spend in 2024
EXEC dbo.usp_GetTopVendorsByExpense
    @StartDate = '2024-01-01',
    @EndDate   = '2024-12-31',
    @TopN      = 5;
GO

-- Month over month revenue trend, straight from the view
SELECT
    MonthStart,
    SUM(TotalAmount) AS MonthlyRevenue
FROM dbo.vw_ProfitAndLoss
WHERE RevenueOrExpense = 'REVENUE'
GROUP BY MonthStart
ORDER BY MonthStart;
GO

-- Accounts where actual spend ran more than 15 percent over budget
SELECT
    MonthStart,
    AccountName,
    ClassName,
    ActualAmount,
    BudgetAmount,
    VariancePercent
FROM dbo.vw_BudgetVsActual
WHERE RevenueOrExpense = 'EXPENSES'
  AND VariancePercent > 15
ORDER BY VariancePercent DESC;
GO
