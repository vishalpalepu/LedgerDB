I think this project can be significantly stronger than a simple Expense Tracker.

Looking at your previous project documentation (FlashLock), you tend to write projects as **engineering systems** rather than CRUD applications. 

I would follow the same style here.

---

# Project LedgerDB

## A Database-Driven Personal Finance Management System

### Technical Design & Rationale

---

# 1. Architectural Preamble: Moving Business Logic into the Database

Modern web applications typically implement business rules inside the backend application. Databases become passive storage systems responsible only for CRUD operations while all validation, aggregation, and decision-making occur inside the application server.

While this architecture offers flexibility, it often duplicates logic across multiple services, increases maintenance overhead, and weakens data integrity because business rules exist outside the database.

LedgerDB explores an alternative architecture where PostgreSQL acts as the primary business logic engine.

Instead of treating the database as storage, the project treats PostgreSQL as an active computational layer capable of:

* validating business rules
* enforcing financial constraints
* calculating summaries
* preventing inconsistent states
* generating audit trails
* maintaining derived statistics automatically

The backend intentionally contains almost no business logic.

Its only responsibility is acting as a secure HTTP gateway between the frontend and the database.

---

# 2. Project Mission

Design a lightweight personal finance management system where almost every operation is executed inside PostgreSQL using native database programming constructs.

The project demonstrates that complex business applications can be implemented using:

* Stored Procedures
* User Defined Functions
* Triggers
* Views
* Transactions
* Constraints
* Indexes

instead of application-side implementations.

---

# 3. Real World Problem

Most personal budgeting applications require the application server to repeatedly calculate:

* monthly expenses
* category spending
* remaining budget
* overspending
* financial summaries
* spending analytics

This creates duplicated computation.

LedgerDB delegates all these operations directly to PostgreSQL.

Whenever new financial data arrives, the database automatically updates all dependent information.

No recalculation is performed by the frontend.

---

# 4. Intended Users

The system is designed for individuals who want to

* monitor monthly expenses
* control spending
* maintain category budgets
* analyse financial habits
* receive automatic overspending notifications

without manually calculating totals.

---

# 5. Core Functional Requirements

The application allows users to

* Create expense categories
* Define monthly budgets
* Record expenses
* Modify expenses
* Delete expenses
* View monthly reports
* View spending trends
* Track remaining budget
* Maintain complete audit history

---

# 6. High-Level Architecture

```text
                    React Frontend
                           │
                     HTTPS Requests
                           │
                    FastAPI Gateway
                           │
                Stored Procedures Only
                           │
                  PostgreSQL Database
        ┌────────────────────────────────────┐
        │ Tables                             │
        │ Constraints                        │
        │ Indexes                            │
        │ Stored Procedures                  │
        │ Functions                          │
        │ Triggers                           │
        │ Views                              │
        └────────────────────────────────────┘
```

Unlike conventional applications, the backend never performs financial calculations.

Every business operation occurs inside PostgreSQL.

---

# 7. User Provisioned Database Architecture

Instead of hosting a central database, every user owns their own PostgreSQL instance hosted on Neon.

First-time setup:

```text
User
      │
      ▼
Creates Free Neon Database
      │
Copies Connection String
      │
      ▼
LedgerDB
      │
Validates Credentials
      │
Creates Complete Schema
      │
Creates Functions
      │
Creates Procedures
      │
Creates Triggers
      │
Creates Views
      │
Application Ready
```

This approach provides

* complete user ownership
* data isolation
* no shared infrastructure
* almost zero hosting cost

---

# 8. Database Responsibilities

The database is responsible for every business rule.

Examples include

## Expense Creation

When a new expense is inserted

the database automatically

* validates category existence
* verifies user ownership
* checks budget
* inserts expense
* updates monthly totals
* logs the action
* generates overspending alerts
* commits transaction

---

## Budget Monitoring

Budgets are never calculated manually.

Whenever expenses change

the database immediately updates

* remaining budget
* percentage used
* exceeded status

---

## Monthly Summary

Monthly reports are maintained automatically through triggers.

The frontend simply requests

```sql
SELECT * FROM MonthlySummary;
```

No calculations occur outside PostgreSQL.

---

# 9. Database Objects

## Tables

Core persistent entities

Examples

```text
Users

ExpenseCategories

Expenses

Budgets

MonthlySummary

Alerts

AuditLogs
```

---

## Views

Views provide pre-computed reports.

Examples

```text
MonthlyExpenseReport

RemainingBudget

TopExpenseCategories

CurrentMonthDashboard

OverspendingUsers
```

The frontend only queries views.

---

## Stored Procedures

Stored procedures perform business transactions.

Examples

```sql
AddExpense()

UpdateExpense()

DeleteExpense()

CreateBudget()

TransferBudget()

ArchiveMonth()
```

Each procedure executes inside a transaction.

---

## User Defined Functions

Functions perform calculations without modifying data.

Examples

```sql
GetRemainingBudget()

GetMonthlyExpense()

GetAverageDailySpend()

GetHighestExpenseCategory()

GetTotalExpenses()

IsBudgetExceeded()

GetCurrentSavings()
```

These functions become reusable building blocks for reports and views.

---

## Triggers

Triggers automatically react to data modifications.

Examples

```sql
AFTER INSERT Expense

Update Monthly Summary

------------

AFTER UPDATE Expense

Recalculate Budget

------------

AFTER DELETE Expense

Restore Budget Totals

------------

AFTER INSERT Expense

Create Audit Record

------------

AFTER INSERT Expense

Generate Alert if Budget Exceeded
```

No application code performs these operations.

---

## Constraints

Data integrity is enforced entirely by PostgreSQL.

Examples

* Primary Keys
* Foreign Keys
* CHECK Constraints
* UNIQUE Constraints
* NOT NULL Constraints

Invalid data never reaches permanent storage.

---

## Indexes

Indexes optimise common operations.

Examples

```sql
Expenses(UserID)

Expenses(CategoryID)

Expenses(Date)

Budgets(UserID)

AuditLog(Date)
```

---

# 10. Transaction Model

Every financial operation executes as a single ACID transaction.

Example

```text
Start Transaction

↓

Insert Expense

↓

Update Monthly Summary

↓

Check Budget

↓

Generate Alert

↓

Insert Audit Log

↓

Commit
```

If any step fails

```sql
ROLLBACK;
```

ensuring the database remains consistent.

---

# 11. Security Model

The frontend never connects directly to PostgreSQL.

Instead

```text
Frontend

↓

FastAPI

↓

PostgreSQL
```

The backend

* authenticates users
* manages connection pools
* invokes stored procedures
* returns JSON responses

The application database user has permissions only to

* execute procedures
* read views

Direct modification of base tables is restricted.

---

# 12. Educational Objectives

This project demonstrates practical usage of

* Database Normalization
* ACID Transactions
* Stored Procedures
* Functions
* Triggers
* Views
* Indexing
* Query Optimization
* Constraint Management
* Database Security
* Connection Management
* Transaction Isolation
* Audit Logging

---

# 13. Engineering Trade-offs

### Advantages

* Centralized business logic
* Strong data consistency
* Reduced duplicate calculations
* Easier auditing
* Simpler backend
* Database-enforced integrity
* Better demonstration of DBMS capabilities

### Limitations

* Greater dependence on PostgreSQL
* More complex SQL development
* Business logic is less portable to other databases
* Schema migrations require additional planning

---

# 14. Future Enhancements

* Scheduled recurring expenses
* Multi-currency support
* Shared family budgets
* Investment portfolio tracking
* Financial forecasting
* Machine learning expense prediction
* Email notifications
* Mobile application
* Export to Excel/PDF
* Role-based access control
* Database partitioning for historical data
* Read replicas for analytical workloads

---

## Interview Summary

> **LedgerDB** is a database-centric personal finance management system designed to demonstrate advanced PostgreSQL capabilities. Unlike conventional CRUD applications, nearly all business logic—including validation, financial calculations, reporting, auditing, and budget enforcement—is implemented inside PostgreSQL using stored procedures, user-defined functions, triggers, views, transactions, constraints, and indexes. The FastAPI backend acts only as a secure HTTP gateway, while each user provides their own Neon PostgreSQL database, allowing automatic schema provisioning and complete ownership of their financial data. This architecture showcases how modern relational databases can function as active business logic engines rather than passive data stores.

---

I think this project is actually **stronger than a typical student CRUD project** because it gives you an opportunity to discuss advanced DBMS concepts in depth—triggers, stored procedures, functions, transactions, views, indexing, normalization, and security—topics that interviewers commonly ask about. It also aligns well with the engineering-focused style of your FlashLock documentation. 



```
database/
│
├── schema/
│   ├── 001_tables.sql
│   └── 002_indexes.sql
│
├── functions/
│   ├── get_remaining_budget.sql
│   ├── get_monthly_expense.sql
│   ├── get_average_daily_spend.sql
│   ├── get_total_expense.sql
│   └── is_budget_exceeded.sql
│
├── procedures/
│   ├── add_expense.sql
│   ├── update_expense.sql
│   ├── delete_expense.sql
│   ├── create_budget.sql
│   └── mark_alert_read.sql
│
├── triggers/
│   ├── expense_insert.sql
│   ├── expense_update.sql
│   ├── expense_delete.sql
│   ├── audit_trigger.sql
│   └── budget_alert_trigger.sql
│
├── views/
│   ├── monthly_dashboard.sql
│   ├── monthly_summary.sql
│   ├── remaining_budget.sql
│   └── budget_status.sql
│
├── seed/
│   ├── default_categories.sql
│   └── sample_data.sql
│
└── initialize.py

```