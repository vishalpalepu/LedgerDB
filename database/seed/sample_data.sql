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
-- January Expenses
-- ==========================================

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Food'),
    450,
    '2026-01-03',
    'Grocery shopping'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Food'),
    320,
    '2026-01-06',
    'Restaurant'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Transport'),
    250,
    '2026-01-04',
    'Metro recharge'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Rent'),
    18000,
    '2026-01-01',
    'January Rent'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Entertainment'),
    800,
    '2026-01-09',
    'Movie'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Utilities'),
    1600,
    '2026-01-10',
    'Electricity Bill'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Shopping'),
    2200,
    '2026-01-12',
    'Clothing'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Healthcare'),
    650,
    '2026-01-15',
    'Medicines'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Subscriptions'),
    499,
    '2026-01-18',
    'Netflix'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Education'),
    1500,
    '2026-01-20',
    'Books'
);

-- ==========================================
-- February Expenses
-- ==========================================

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Food'),
    510,
    '2026-02-04',
    'Groceries'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Transport'),
    900,
    '2026-02-05',
    'Fuel'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Shopping'),
    3400,
    '2026-02-10',
    'Electronics'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Travel'),
    2600,
    '2026-02-16',
    'Weekend Trip'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Utilities'),
    1700,
    '2026-02-20',
    'Internet Bill'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Food'),
    610,
    '2026-02-23',
    'Restaurant'
);

-- ==========================================
-- March Expenses
-- ==========================================

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Food'),
    700,
    '2026-03-02',
    'Groceries'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Entertainment'),
    1200,
    '2026-03-08',
    'Concert'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Shopping'),
    4800,
    '2026-03-10',
    'Shoes'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Healthcare'),
    1100,
    '2026-03-18',
    'Clinic Visit'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Travel'),
    3800,
    '2026-03-22',
    'Train Tickets'
);

CALL record_expense(
    (SELECT category_id FROM Category WHERE name='Food'),
    580,
    '2026-03-25',
    'Dinner'
);

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