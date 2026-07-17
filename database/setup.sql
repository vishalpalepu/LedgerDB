-- =====================================================
-- LedgerDB Database Setup Script
-- Executes all SQL files in the correct dependency order
-- =====================================================

BEGIN;

-- =====================================================
-- SCHEMA
-- =====================================================

\i schema/001_tables.sql
\i schema/002_indexes.sql

-- =====================================================
-- FUNCTIONS - EXPENSE
-- =====================================================

\i functions/expense/get_monthly_expense.sql
\i functions/expense/get_total_category_expense.sql
\i functions/expense/get_average_daily_spend.sql
\i functions/expense/get_days_remaining_in_period.sql
\i functions/expense/get_projected_month_end_spend.sql

-- =====================================================
-- FUNCTIONS - BUDGET
-- =====================================================

\i functions/budget/get_budget_utilization.sql
\i functions/budget/get_remaining_category_budget.sql
\i functions/budget/get_total_remaining_budget.sql
\i functions/budget/is_budget_exceeded.sql

-- =====================================================
-- FUNCTIONS - ANALYTICS
-- =====================================================

\i functions/analytics/get_average_monthly_spending.sql
\i functions/analytics/get_budget_variance.sql
\i functions/analytics/get_category_percentage.sql
\i functions/analytics/get_category_spending_trend.sql
\i functions/analytics/get_consecutive_overspending_streak.sql
\i functions/analytics/get_highest_spending_category.sql
\i functions/analytics/get_highest_spending_month.sql
\i functions/analytics/get_lowest_spending_month.sql
\i functions/analytics/get_month_over_month_change.sql
\i functions/analytics/get_monthly_spending_trend.sql

-- =====================================================
-- PROCEDURES - BUDGET
-- =====================================================

\i procedures/budget/create_budget_period.sql
\i procedures/budget/set_budget.sql
\i procedures/budget/update_budget.sql
\i procedures/budget/generate_budget_alerts.sql

-- =====================================================
-- PROCEDURES - EXPENSE
-- =====================================================

\i procedures/expense/record_expense.sql
\i procedures/expense/update_expense.sql
\i procedures/expense/delete_expense.sql

-- =====================================================
-- PROCEDURES - CATEGORY
-- =====================================================

\i procedures/category/update_category.sql

-- =====================================================
-- PROCEDURES - ALERT
-- =====================================================

\i procedures/alert/mark_alert_as_read.sql

-- =====================================================
-- PROCEDURES - IMPORT
-- =====================================================

\i procedures/import/complete_import_history.sql

-- =====================================================
-- VIEWS
-- =====================================================

\i views/monthly_summary.sql
\i views/category_summary.sql
\i views/budget_vs_actual.sql
\i views/remaining_budget.sql
\i views/budget_status.sql
\i views/alert_summary.sql
\i views/spending_trend.sql
\i views/monthly_dashboard.sql

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Execute all trigger scripts here once they are added.
-- Example:
-- \i triggers/update_timestamp.sql
-- \i triggers/audit_changes.sql
-- \i triggers/budget_alert.sql

-- =====================================================
-- SEED DATA
-- =====================================================

\i seed/default_categories.sql
\i seed/sample_data.sql

COMMIT;

-- =====================================================
-- LedgerDB Initialization Complete
-- =====================================================