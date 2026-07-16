# LedgerDB: Technical Design Document

This document provides a deep dive into the architectural decisions, database design, and technical implementation of LedgerDB. For a high-level overview, setup instructions, and general usage, please refer to the [README.md](../README.md).

## Table of Contents

1. [Architectural Philosophy](#1-architectural-philosophy)
2. [Database Design Deep Dive](#2-database-design-deep-dive)
    - [Tables](#tables)
    - [Views](#views)
    - [Stored Procedures](#stored-procedures)
    - [User Defined Functions](#user-defined-functions)
    - [Triggers](#triggers)
    - [Constraints & Indexes](#constraints--indexes)
3. [Transaction & Security Models](#3-transaction--security-models)
    - [Transaction Model](#transaction-model)
    - [Security Model](#security-model)
4. [Project Structure](#4-project-structure)
5. [Detailed Function & Trigger Reference](#5-detailed-function--trigger-reference)
    - [Analytical Functions](#analytical-functions)
    - [System Triggers](#system-triggers)
6. [Engineering Analysis](#6-engineering-analysis)
    - [Trade-offs](#trade-offs)
    - [Educational Objectives](#educational-objectives)
    - [Future Enhancements](#future-enhancements)

---

## 1. Architectural Philosophy

Modern web applications typically implement business rules inside the backend application, treating the database as a passive storage system. This often leads to duplicated logic across services and weakened data integrity outside the database layer.

LedgerDB inverses this pattern: **PostgreSQL acts as the primary business logic engine.** The backend (FastAPI) is intentionally stateless and contains almost no business logic, serving strictly as a secure HTTP gateway.

By treating PostgreSQL as an active computational layer, LedgerDB handles:
* Validating business rules and enforcing financial constraints
* Calculating summaries and preventing inconsistent states
* Generating audit trails and maintaining derived statistics automatically

### User-Provisioned Database Architecture
Instead of a central multi-tenant database, every user provisions their own PostgreSQL instance (e.g., via Neon). LedgerDB validates credentials and automatically executes a comprehensive schema initialization, granting the user complete data isolation and ownership with almost zero hosting costs.

---

## 2. Database Design Deep Dive

Every business rule is enforced at the database level. Below is a detailed look at the core database objects.

### Tables
Core persistent entities are normalized to ensure data integrity.
* `Users`: Authentication and user metadata.
* `ExpenseCategories`: Defined categories for spending.
* `Budgets`: User-defined monthly financial limits.
* `Expenses`: Individual transaction records.
* `MonthlySummary`: Aggregated tracking data.
* `Alerts` & `AuditLogs`: System-generated notifications and historical change logs.

### Views
The frontend never performs calculations; it merely queries pre-computed views.
* `MonthlyExpenseReport`, `RemainingBudget`, `TopExpenseCategories`, `CurrentMonthDashboard`, `OverspendingUsers`.

### Stored Procedures
Procedures encapsulate complete business transactions. Each executes within its own ACID transaction block.
* **Examples**: `AddExpense()`, `UpdateExpense()`, `DeleteExpense()`, `CreateBudget()`, `TransferBudget()`, `ArchiveMonth()`.

### User Defined Functions
Functions compute values dynamically without modifying state. They act as reusable building blocks for triggers and views.
* **Examples**: `GetRemainingBudget()`, `GetMonthlyExpense()`, `GetAverageDailySpend()`, `GetHighestExpenseCategory()`, `IsBudgetExceeded()`.

### Triggers
Triggers react to DML operations to maintain application state automatically.
* **AFTER INSERT Expense**: Updates Monthly Summary, creates audit records, and checks for budget overruns.
* **AFTER UPDATE Expense**: Recalculates budget utilization and modifies summaries.
* **AFTER DELETE Expense**: Restores budget totals.

### Constraints & Indexes
* **Constraints**: Primary/Foreign Keys, `CHECK`, `UNIQUE`, and `NOT NULL` constraints ensure invalid data never reaches permanent storage.
* **Indexes**: Optimized queries using indexes like `Expenses(UserID)`, `Expenses(CategoryID)`, `Expenses(Date)`, and `AuditLog(Date)`.

---

## 3. Transaction & Security Models

### Transaction Model
Every financial operation executes as a single ACID transaction. If any step fails (e.g., generating an alert or updating the monthly summary), a `ROLLBACK` is issued, ensuring the database remains in a consistent state.

**Execution Flow Example (Add Expense):**
1. Start Transaction
2. Insert Expense
3. Update Monthly Summary (Triggered)
4. Check Budget (Triggered)
5. Generate Alert (If exceeded)
6. Insert Audit Log
7. Commit

### Security Model
The frontend never connects directly to PostgreSQL. The flow is: `Frontend -> FastAPI Gateway -> PostgreSQL`.
* The FastAPI backend manages connection pools, authenticates users, invokes stored procedures, and returns JSON.
* The application database user is granted permissions **only** to execute procedures and read views. Direct modification of base tables is strictly restricted.

---

## 4. Project Structure

The database implementation is organized into modular SQL scripts to maintain clean separation of concerns:

```text
database/
├── schema/
│   ├── 001_tables.sql
│   └── 002_indexes.sql
├── functions/
│   ├── expense/       # get_monthly_expense.sql, get_average_daily_spend.sql, etc.
│   ├── budget/        # get_remaining_category_budget.sql, is_budget_exceeded.sql, etc.
│   └── analytics/     # get_month_over_month_change.sql, get_highest_spending_month.sql, etc.
├── procedures/
│   ├── expense/       # record_expense.sql, update_expense.sql, etc.
│   ├── budget/        # create_budget_period.sql, set_budget.sql, etc.
│   ├── category/      # update_category.sql
│   ├── alerts/        # mark_alert_as_read.sql
│   └── import/        # complete_import_history.sql
├── triggers/
│   ├── audit_trigger.sql
│   ├── budget_alert_trigger.sql
│   └── update_timestamp.sql
├── views/             # monthly_dashboard.sql, budget_vs_actual.sql, etc.
├── seed/              # default_categories.sql, sample_data.sql
├── tests/             # function_tests.sql, procedure_tests.sql, trigger_tests.sql
└── initialize.py
```

---

## 5. Detailed Function & Trigger Reference

### Analytical Functions

| Function | Purpose | Input | Output | Problem Statement |
| :--- | :--- | :--- | :--- | :--- |
| **`get_month_over_month_change()`** | Calculate how monthly spending has changed compared to the previous month. | None | `TABLE(month, year, current_spending, previous_spending, change_amount, change_percentage)` | Identify increasing or decreasing spending trends based on historical budget periods. |
| **`get_highest_spending_month()`** | Identify the month with the highest total expenditure. | None | `TABLE(month, year, total_spending)` | Determine the maximum total expense by aggregating all expenses within each month. |
| **`get_lowest_spending_month()`** | Identify the month with the lowest total expenditure. | None | `TABLE(month, year, total_spending)` | Determine the minimum total expense by aggregating all expenses within each month. |
| **`get_budget_variance()`** | Compare allocated budget with actual spending. | `p_period_id UUID` | `TABLE(category_name, budget_amount, actual_spending, variance)` | Calculate the difference between the allocated budget and actual spent (positive = remaining, negative = overspend). |
| **`get_consecutive_overspending_streak()`** | Determine longest sequence of consecutive overspending months. | None | `INTEGER` | Examine historical budget periods to identify persistent overspending behavior over time. |

### System Triggers

| Trigger File | Trigger Name | Table | Event | Purpose / Action |
| :--- | :--- | :--- | :--- | :--- |
| `update_timestamp.sql` | `before_budget_update_timestamp` | `Budget` | `BEFORE UPDATE` | Set `NEW.updated_at = CURRENT_TIMESTAMP` |
| `update_timestamp.sql` | `before_expense_update_timestamp` | `Expense` | `BEFORE UPDATE` | Set `NEW.updated_at = CURRENT_TIMESTAMP` |
| `audit_trigger.sql` | `audit_category_changes` | `Category` | `AFTER INSERT / UPDATE / DELETE` | Log operation (`TG_OP`), old/new row states to `AuditLog` |
| `audit_trigger.sql` | `audit_budget_changes` | `Budget` | `AFTER INSERT / UPDATE / DELETE` | Log modifications to `Budget` table |
| `audit_trigger.sql` | `audit_expense_changes` | `Expense` | `AFTER INSERT / UPDATE / DELETE` | Log modifications to `Expense` table |
| `budget_alert_trigger.sql` | `check_budget_after_insert` | `Expense` | `AFTER INSERT` | Call `is_budget_exceeded()`, insert alert if budget is exceeded |
| `expense_update.sql` | `check_budget_after_update` | `Expense` | `AFTER UPDATE` | Re-evaluate budget status, create alerts on overspend |
| `expense_delete.sql` | `check_budget_after_delete` | `Expense` | `AFTER DELETE` | Recalculate budget status after expense removal |

---

## 6. Engineering Analysis

### Trade-offs

**Advantages**
* **Centralized business logic:** Prevents logic duplication across potential multiple frontends or microservices.
* **Strong data consistency:** Impossible to bypass business rules since they live with the data.
* **Reduced duplicate calculations:** Views and triggers eliminate redundant server computations.
* **Simpler backend:** The API layer is exceptionally thin and maintainable.

**Limitations**
* **Database Coupling:** Tightly coupled to PostgreSQL; migrating to MySQL or NoSQL would require a complete rewrite of the logic layer.
* **Development Complexity:** SQL debugging and procedural code (PL/pgSQL) can be more complex to version control and test than application code.
* **Schema Migrations:** Changes to logic require careful database migrations rather than simple application deployments.

### Educational Objectives
This architecture serves as an advanced demonstration of DBMS capabilities, showcasing practical usage of:
* Database Normalization & ACID Transactions
* Stored Procedures, Functions, & Triggers
* Query Optimization & Indexing
* Constraint Management & Database Security
* Audit Logging & Transaction Isolation

### Future Enhancements
* Scheduled recurring expenses via `pg_cron` or backend scheduling.
* Multi-currency support handling exchange rates inside functions.
* Shared family budgets with row-level security (RLS).
* Financial forecasting and machine learning expense prediction.
* Database partitioning for long-term historical data.
* Read replicas for complex analytical workloads.
