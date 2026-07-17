-- ==========================================
-- LedgerDB - Sample Data
-- Run after:
-- 1. schema.sql
-- 2. default_categories.sql
-- ==========================================

BEGIN;

-- ==========================================
-- Budget Periods
-- ==========================================

CALL create_budget_period(1, 2026);
CALL create_budget_period(2, 2026);
CALL create_budget_period(3, 2026);
CALL create_budget_period(4, 2026);
CALL create_budget_period(5, 2026);
CALL create_budget_period(6, 2026);

-- ==========================================
-- Budgets
-- ==========================================

DO
$$
DECLARE
    p RECORD;
    c RECORD;
    budget_value NUMERIC;
BEGIN

    FOR p IN
        SELECT period_id
        FROM BudgetPeriod
        ORDER BY year, month
    LOOP

        FOR c IN
            SELECT category_id, name
            FROM Category
        LOOP

            budget_value :=
            CASE c.name
                WHEN 'Rent' THEN 18000
                WHEN 'Food' THEN 6000
                WHEN 'Transport' THEN 3000
                WHEN 'Utilities' THEN 2500
                WHEN 'Shopping' THEN 5000
                WHEN 'Entertainment' THEN 2500
                WHEN 'Healthcare' THEN 3000
                WHEN 'Education' THEN 5000
                WHEN 'Travel' THEN 4000
                WHEN 'Insurance' THEN 2500
                WHEN 'Savings' THEN 8000
                WHEN 'Investment' THEN 6000
                WHEN 'Subscriptions' THEN 1000
                WHEN 'Gifts' THEN 1500
                ELSE 2000
            END;

            CALL set_budget(
                c.category_id,
                p.period_id,
                budget_value
            );

        END LOOP;

    END LOOP;

END;
$$;

-- ==========================================
-- Expenses
-- ==========================================

DO
$$
DECLARE
    v_food UUID;
    v_transport UUID;
    v_rent UUID;
    v_entertainment UUID;
    v_utilities UUID;
    v_shopping UUID;
    v_healthcare UUID;
    v_subscriptions UUID;
    v_education UUID;
    v_travel UUID;
BEGIN
    SELECT category_id INTO v_food FROM Category WHERE name='Food';
    SELECT category_id INTO v_transport FROM Category WHERE name='Transport';
    SELECT category_id INTO v_rent FROM Category WHERE name='Rent';
    SELECT category_id INTO v_entertainment FROM Category WHERE name='Entertainment';
    SELECT category_id INTO v_utilities FROM Category WHERE name='Utilities';
    SELECT category_id INTO v_shopping FROM Category WHERE name='Shopping';
    SELECT category_id INTO v_healthcare FROM Category WHERE name='Healthcare';
    SELECT category_id INTO v_subscriptions FROM Category WHERE name='Subscriptions';
    SELECT category_id INTO v_education FROM Category WHERE name='Education';
    SELECT category_id INTO v_travel FROM Category WHERE name='Travel';

    -- January Expenses
    CALL record_expense(v_food, 450, '2026-01-03', 'Grocery shopping');
    CALL record_expense(v_food, 320, '2026-01-06', 'Restaurant');
    CALL record_expense(v_transport, 250, '2026-01-04', 'Metro recharge');
    CALL record_expense(v_rent, 18000, '2026-01-01', 'January Rent');
    CALL record_expense(v_entertainment, 800, '2026-01-09', 'Movie');
    CALL record_expense(v_utilities, 1600, '2026-01-10', 'Electricity Bill');
    CALL record_expense(v_shopping, 2200, '2026-01-12', 'Clothing');
    CALL record_expense(v_healthcare, 650, '2026-01-15', 'Medicines');
    CALL record_expense(v_subscriptions, 499, '2026-01-18', 'Netflix');
    CALL record_expense(v_education, 1500, '2026-01-20', 'Books');

    -- February Expenses
    CALL record_expense(v_food, 510, '2026-02-04', 'Groceries');
    CALL record_expense(v_transport, 900, '2026-02-05', 'Fuel');
    CALL record_expense(v_shopping, 3400, '2026-02-10', 'Electronics');
    CALL record_expense(v_travel, 2600, '2026-02-16', 'Weekend Trip');
    CALL record_expense(v_utilities, 1700, '2026-02-20', 'Internet Bill');
    CALL record_expense(v_food, 610, '2026-02-23', 'Restaurant');

    -- March Expenses
    CALL record_expense(v_food, 700, '2026-03-02', 'Groceries');
    CALL record_expense(v_entertainment, 1200, '2026-03-08', 'Concert');
    CALL record_expense(v_shopping, 4800, '2026-03-10', 'Shoes');
    CALL record_expense(v_healthcare, 1100, '2026-03-18', 'Clinic Visit');
    CALL record_expense(v_travel, 3800, '2026-03-22', 'Train Tickets');
    CALL record_expense(v_food, 580, '2026-03-25', 'Dinner');

END;
$$;

-- ==========================================
-- Import History
-- ==========================================

INSERT INTO ImportHistory
(
    file_name,
    total_records,
    successful_records,
    failed_records
)
VALUES
(
    'expenses_january.csv',
    100,
    98,
    2
),
(
    'expenses_february.csv',
    95,
    95,
    0
);

COMMIT;

-- ==========================================
-- Verification Queries
-- ==========================================

SELECT COUNT(*) AS total_categories FROM Category;

SELECT COUNT(*) AS total_periods FROM BudgetPeriod;

SELECT COUNT(*) AS total_budgets FROM Budget;

SELECT COUNT(*) AS total_expenses FROM Expense;

SELECT COUNT(*) AS total_alerts FROM Alert;

SELECT COUNT(*) AS imports FROM ImportHistory;