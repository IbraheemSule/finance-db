# Data dictionary

This describes every table and column in FinanceDB. The source data
came from a company's transaction and budget export covering January
2022 through December 2024.

## dbo.Classifications

Departmental groupings used across both transactions and budget.

| Column    | Type        | Notes                                  |
|-----------|-------------|-----------------------------------------|
| ClassCode | VARCHAR(10) | Primary key. Short code, e.g. `G&A`     |
| ClassName | VARCHAR(50) | Full name, e.g. `General & Administrative` |

Values: `G&A`, `S&M`, `R&D`, `CS`.

## dbo.Accounts

The chart of accounts, with a two-level rollup hierarchy for
statement-style reporting.

| Column           | Type          | Notes                                      |
|------------------|---------------|----------------------------------------------|
| AccountId        | INT           | Primary key                                   |
| AccountCode      | INT           | Unique account number, e.g. `40100`           |
| AccountName      | VARCHAR(100)  | e.g. `SaaS Revenue`                           |
| RevenueOrExpense | VARCHAR(10)   | `REVENUE` or `EXPENSES`                       |
| Level1           | VARCHAR(50)   | Top-level statement category, e.g. `Income`, `Cost of Goods Sold`, `Operating Expenses`, `Other Income`, `Other Expense` |
| Level2           | VARCHAR(50)   | Sub-category, e.g. `Payroll`, `Professional Fees` |

## dbo.Transactions

Every posted transaction: invoices, bills, deposits, journal entries
and standalone expenses.

| Column           | Type           | Notes                                     |
|------------------|----------------|--------------------------------------------|
| TransactionId    | INT            | Primary key                                |
| TransactionDate  | DATE           | Date the transaction was posted            |
| AccountCode      | INT            | Foreign key to Accounts                    |
| ClassCode        | VARCHAR(10)    | Foreign key to Classifications             |
| TransactionType  | VARCHAR(30)    | `Invoice`, `Bill`, `Deposit`, `Journal Entry`, `Expense` |
| VendorOrClient   | VARCHAR(100)   | Counterparty name, nullable                |
| Memo             | VARCHAR(200)   | Free-text description, nullable            |
| RevenueOrExpense | VARCHAR(10)    | `REVENUE` or `EXPENSES`                    |
| Amount           | DECIMAL(14,2)  | Always a positive amount                   |

## dbo.Budget

Planned monthly amounts by account and department. Budget dates fall
on month-end.

| Column           | Type           | Notes                          |
|------------------|----------------|----------------------------------|
| BudgetId         | INT            | Primary key                      |
| BudgetDate       | DATE           | Month-end date of the budget line |
| AccountCode      | INT            | Foreign key to Accounts          |
| ClassCode        | VARCHAR(10)    | Foreign key to Classifications   |
| RevenueOrExpense | VARCHAR(10)    | `REVENUE` or `EXPENSES`          |
| BudgetAmount     | DECIMAL(14,2)  | Planned amount for that account and month |

## Views

- **vw_MonthlyActuals** — transactions summed by month, account and class.
- **vw_MonthlyBudget** — budget lines summed the same way, so it lines up with vw_MonthlyActuals.
- **vw_BudgetVsActual** — actual and budget side by side, with variance and variance percentage.
- **vw_ProfitAndLoss** — actuals rolled up to the Level1 category per month, ready for a P&L statement.

## Stored procedures

- **usp_GetProfitAndLossByMonth** `@Year, @Month` — revenue, expenses and net income for one month.
- **usp_GetProfitAndLossByRange** `@StartDate, @EndDate` — P&L by category across a date range.
- **usp_GetBudgetVariance** `@StartDate, @EndDate, @ClassCode = NULL` — budget vs actual, optionally scoped to one department.
- **usp_GetTopVendorsByExpense** `@StartDate, @EndDate, @TopN = 10` — biggest vendors by total spend.
