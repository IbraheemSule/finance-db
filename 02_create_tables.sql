/*
    02_create_tables.sql
    Builds the core tables for FinanceDB.
    Run after 01_create_database.sql.
*/

USE FinanceDB;
GO

-- Lookup table: departmental classification (G&A, S&M, R&D, CS)
CREATE TABLE dbo.Classifications
(
    ClassCode   VARCHAR(10)     NOT NULL,
    ClassName   VARCHAR(50)     NOT NULL,
    CONSTRAINT PK_Classifications PRIMARY KEY (ClassCode)
);
GO

-- Chart of accounts, with a two-level rollup hierarchy
CREATE TABLE dbo.Accounts
(
    AccountId           INT             NOT NULL,
    AccountCode         INT             NOT NULL,
    AccountName         VARCHAR(100)    NOT NULL,
    RevenueOrExpense    VARCHAR(10)     NOT NULL,
    Level1              VARCHAR(50)     NOT NULL,
    Level2              VARCHAR(50)     NOT NULL,
    CONSTRAINT PK_Accounts PRIMARY KEY (AccountId),
    CONSTRAINT UQ_Accounts_AccountCode UNIQUE (AccountCode),
    CONSTRAINT CK_Accounts_RevenueOrExpense CHECK (RevenueOrExpense IN ('REVENUE', 'EXPENSES'))
);
GO

-- Actual, posted transactions (invoices, bills, deposits, journal entries)
CREATE TABLE dbo.Transactions
(
    TransactionId       INT             NOT NULL,
    TransactionDate     DATE            NOT NULL,
    AccountCode         INT             NOT NULL,
    ClassCode           VARCHAR(10)     NOT NULL,
    TransactionType     VARCHAR(30)     NOT NULL,
    VendorOrClient       VARCHAR(100)    NULL,
    Memo                VARCHAR(200)    NULL,
    RevenueOrExpense    VARCHAR(10)     NOT NULL,
    Amount               DECIMAL(14, 2)  NOT NULL,
    CONSTRAINT PK_Transactions PRIMARY KEY (TransactionId),
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountCode)
        REFERENCES dbo.Accounts (AccountCode),
    CONSTRAINT FK_Transactions_Classifications FOREIGN KEY (ClassCode)
        REFERENCES dbo.Classifications (ClassCode),
    CONSTRAINT CK_Transactions_RevenueOrExpense CHECK (RevenueOrExpense IN ('REVENUE', 'EXPENSES')),
    CONSTRAINT CK_Transactions_Amount CHECK (Amount >= 0)
);
GO

-- Monthly budget targets by account and department
CREATE TABLE dbo.Budget
(
    BudgetId             INT             NOT NULL,
    BudgetDate           DATE            NOT NULL,
    AccountCode          INT             NOT NULL,
    ClassCode            VARCHAR(10)     NOT NULL,
    RevenueOrExpense     VARCHAR(10)     NOT NULL,
    BudgetAmount         DECIMAL(14, 2)  NOT NULL,
    CONSTRAINT PK_Budget PRIMARY KEY (BudgetId),
    CONSTRAINT FK_Budget_Accounts FOREIGN KEY (AccountCode)
        REFERENCES dbo.Accounts (AccountCode),
    CONSTRAINT FK_Budget_Classifications FOREIGN KEY (ClassCode)
        REFERENCES dbo.Classifications (ClassCode),
    CONSTRAINT CK_Budget_RevenueOrExpense CHECK (RevenueOrExpense IN ('REVENUE', 'EXPENSES')),
    CONSTRAINT CK_Budget_Amount CHECK (BudgetAmount >= 0)
);
GO
