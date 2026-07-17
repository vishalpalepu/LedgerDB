-- =====================================================
-- LedgerDB - Trigger Test Suite
-- =====================================================
-- Tests:
-- 1. Timestamp Trigger
-- 2. Audit Trigger (INSERT)
-- 3. Audit Trigger (UPDATE)
-- 4. Audit Trigger (DELETE)
-- 5. Budget Alert Trigger
--
-- Each test is rolled back.
-- =====================================================

----------------------------------------------------------
-- Test 1
-- updated_at Trigger on Budget
----------------------------------------------------------

BEGIN;

SELECT
    budget_id,
    updated_at
FROM Budget
LIMIT 1;

DO $$ DECLARE v_budget_id UUID; BEGIN
    SELECT budget_id INTO v_budget_id FROM Budget LIMIT 1;
    CALL update_budget(v_budget_id, 9999);
END; $$;

SELECT
    budget_id,
    updated_at
FROM Budget
LIMIT 1;

-- Expected:
-- updated_at should be newer.

ROLLBACK;

----------------------------------------------------------
-- Test 2
-- updated_at Trigger on Expense
----------------------------------------------------------

BEGIN;

SELECT
expense_id,
updated_at
FROM Expense
LIMIT 1;

DO $$ DECLARE v_exp_id UUID; v_cat_id UUID; BEGIN
    SELECT expense_id, category_id INTO v_exp_id, v_cat_id FROM Expense LIMIT 1;
    CALL update_expense(v_exp_id, v_cat_id, 999, CURRENT_DATE, 'Timestamp Trigger Test');
END; $$;

SELECT
expense_id,
updated_at
FROM Expense
LIMIT 1;

-- Expected:
-- updated_at changes automatically.

ROLLBACK;

----------------------------------------------------------
-- Test 3
-- Audit Trigger (INSERT)
----------------------------------------------------------

BEGIN;

DO $$ DECLARE v_cat_id UUID; BEGIN
    SELECT category_id INTO v_cat_id FROM Category WHERE name='Food';
    CALL record_expense(v_cat_id, 250, CURRENT_DATE, 'Audit Insert Test');
END; $$;

SELECT
table_name,
operation,
performed_at
FROM AuditLog
WHERE operation='INSERT'
ORDER BY performed_at DESC
LIMIT 5;

-- Expected:
-- New INSERT audit record exists.

ROLLBACK;

----------------------------------------------------------
-- Test 4
-- Audit Trigger (UPDATE)
----------------------------------------------------------

BEGIN;

DO $$ DECLARE v_budget_id UUID; BEGIN
    SELECT budget_id INTO v_budget_id FROM Budget LIMIT 1;
    CALL update_budget(v_budget_id, 12000);
END; $$;

SELECT
table_name,
operation
FROM AuditLog
WHERE operation='UPDATE'
ORDER BY performed_at DESC
LIMIT 5;

-- Expected:
-- UPDATE audit record inserted.

ROLLBACK;

----------------------------------------------------------
-- Test 5
-- Audit Trigger (DELETE)
----------------------------------------------------------

BEGIN;

DO $$ DECLARE v_exp_id UUID; BEGIN
    SELECT expense_id INTO v_exp_id FROM Expense LIMIT 1;
    CALL delete_expense(v_exp_id);
END; $$;

SELECT
table_name,
operation
FROM AuditLog
WHERE operation='DELETE'
ORDER BY performed_at DESC
LIMIT 5;

-- Expected:
-- DELETE audit record inserted.

ROLLBACK;

----------------------------------------------------------
-- Test 6
-- Budget Alert Trigger
----------------------------------------------------------

BEGIN;

DO
$$
DECLARE
    v_food UUID;
    v_period UUID;
    v_budget NUMERIC;
BEGIN

    SELECT category_id
    INTO v_food
    FROM Category
    WHERE name='Food';

    SELECT period_id
    INTO v_period
    FROM BudgetPeriod
    WHERE month=1
    AND year=2026;

    SELECT budget_amount
    INTO v_budget
    FROM Budget
    WHERE category_id=v_food
    AND period_id=v_period;

    CALL record_expense(
        v_food,
        v_budget + 500,
        '2026-01-25',
        'Budget Alert Test'
    );
END;
$$;

SELECT *
FROM Alert
ORDER BY created_at DESC
LIMIT 5;

-- Expected:
-- New alert generated automatically.

ROLLBACK;

----------------------------------------------------------
-- Test 7
-- Multiple Audit Entries
----------------------------------------------------------

BEGIN;

DO $$ DECLARE v_cat_id UUID; v_exp_id UUID; BEGIN
    SELECT category_id INTO v_cat_id FROM Category WHERE name='Shopping';
    CALL record_expense(v_cat_id, 500, CURRENT_DATE, 'Audit Chain Test');
    
    SELECT expense_id INTO v_exp_id FROM Expense WHERE description='Audit Chain Test' LIMIT 1;
    CALL update_expense(v_exp_id, v_cat_id, 700, CURRENT_DATE, 'Audit Chain Updated');
    
    SELECT expense_id INTO v_exp_id FROM Expense WHERE description='Audit Chain Updated' LIMIT 1;
    CALL delete_expense(v_exp_id);
END; $$;

SELECT
operation,
table_name,
performed_at
FROM AuditLog
ORDER BY performed_at DESC
LIMIT 10;

-- Expected:
-- INSERT
-- UPDATE
-- DELETE
-- all appear in AuditLog.

ROLLBACK;

----------------------------------------------------------
-- End Trigger Tests
----------------------------------------------------------