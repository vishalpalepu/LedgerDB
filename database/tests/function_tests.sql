-- =====================================================
-- LedgerDB - Function Test Suite
-- =====================================================
-- Prerequisites:
-- 1. schema.sql
-- 2. seed/default_categories.sql
-- 3. seed/sample_data.sql
-- =====================================================

----------------------------------------------------------
-- Test Data
----------------------------------------------------------

SELECT
    period_id
FROM BudgetPeriod
ORDER BY year, month
LIMIT 1;

SELECT
    category_id,
    name
FROM Category
ORDER BY name;

----------------------------------------------------------
-- get_monthly_expense()
----------------------------------------------------------

SELECT
    get_monthly_expense(
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month = 1
            AND year = 2026
        )
    ) AS january_expense;

-- Expected:
-- Returns total expense recorded in January.

----------------------------------------------------------
-- get_total_category_expense()
----------------------------------------------------------

SELECT
    get_total_category_expense(
        (
            SELECT category_id
            FROM Category
            WHERE name='Food'
        ),
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    ) AS food_expense;

-- Expected:
-- Sum of Food expenses during January.

----------------------------------------------------------
-- get_remaining_category_budget()
----------------------------------------------------------

SELECT
    get_remaining_category_budget(
        (
            SELECT category_id
            FROM Category
            WHERE name='Food'
        ),
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- get_total_remaining_budget()
----------------------------------------------------------

SELECT
    get_total_remaining_budget(
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- get_budget_utilization()
----------------------------------------------------------

SELECT
    get_budget_utilization(
        (
            SELECT category_id
            FROM Category
            WHERE name='Food'
        ),
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- is_budget_exceeded()
----------------------------------------------------------

SELECT
    is_budget_exceeded(
        (
            SELECT category_id
            FROM Category
            WHERE name='Food'
        ),
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- get_average_daily_spend()
----------------------------------------------------------

SELECT
    get_average_daily_spend(
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- get_days_remaining_in_period()
----------------------------------------------------------

SELECT
    get_days_remaining_in_period(
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- get_projected_month_end_spend()
----------------------------------------------------------

SELECT
    get_projected_month_end_spend(
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- get_category_percentage()
----------------------------------------------------------

SELECT *
FROM get_category_percentage(
    (
        SELECT period_id
        FROM BudgetPeriod
        WHERE month=1
        AND year=2026
    )
);

----------------------------------------------------------
-- get_highest_spending_category()
----------------------------------------------------------

SELECT
    get_highest_spending_category(
        (
            SELECT period_id
            FROM BudgetPeriod
            WHERE month=1
            AND year=2026
        )
    );

----------------------------------------------------------
-- get_budget_variance()
----------------------------------------------------------

SELECT *
FROM get_budget_variance(
    (
        SELECT period_id
        FROM BudgetPeriod
        WHERE month=1
        AND year=2026
    )
);

----------------------------------------------------------
-- get_monthly_spending_trend()
----------------------------------------------------------

SELECT *
FROM get_monthly_spending_trend();

----------------------------------------------------------
-- get_category_spending_trend()
----------------------------------------------------------

SELECT *
FROM get_category_spending_trend(
    (
        SELECT category_id
        FROM Category
        WHERE name='Food'
    )
);

----------------------------------------------------------
-- get_month_over_month_change()
----------------------------------------------------------

SELECT *
FROM get_month_over_month_change();

----------------------------------------------------------
-- get_average_monthly_spending()
----------------------------------------------------------

SELECT
    get_average_monthly_spending();

----------------------------------------------------------
-- get_highest_spending_month()
----------------------------------------------------------

SELECT *
FROM get_highest_spending_month();

----------------------------------------------------------
-- get_lowest_spending_month()
----------------------------------------------------------

SELECT *
FROM get_lowest_spending_month();

----------------------------------------------------------
-- get_consecutive_overspending_streak()
----------------------------------------------------------

SELECT
    get_consecutive_overspending_streak();

----------------------------------------------------------
-- End of Function Tests
----------------------------------------------------------