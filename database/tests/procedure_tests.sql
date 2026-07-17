-- =====================================================
-- LedgerDB - Procedure Test Suite
-- =====================================================
-- Each test runs independently.
-- ROLLBACK is used so the database remains unchanged.
-- =====================================================

----------------------------------------------------------
-- Test 1
-- create_budget_period()
----------------------------------------------------------

BEGIN;

CALL create_budget_period(12, 2030);

SELECT *
FROM BudgetPeriod
WHERE month = 12
AND year = 2030;

ROLLBACK;

----------------------------------------------------------
-- Test 2
-- set_budget()
----------------------------------------------------------

BEGIN;

DO $$ 
DECLARE 
    v_cat UUID; 
    v_per UUID; 
BEGIN
    SELECT category_id INTO v_cat FROM Category WHERE name='Food';
    SELECT period_id INTO v_per FROM BudgetPeriod WHERE month=1 AND year=2026;
    CALL set_budget(v_cat, v_per, 7500);
END; $$;

SELECT
budget_amount
FROM Budget
WHERE category_id =
(
SELECT category_id
FROM Category
WHERE name='Food'
);

ROLLBACK;

----------------------------------------------------------
-- Test 3
-- update_budget()
----------------------------------------------------------

BEGIN;

DO $$
DECLARE
    v_budget_id UUID;
BEGIN
    SELECT budget_id INTO v_budget_id FROM Budget LIMIT 1;
    CALL update_budget(v_budget_id, 9000);
END; $$;

SELECT
budget_amount
FROM Budget
WHERE budget_id =
(
SELECT budget_id
FROM Budget
LIMIT 1
);

ROLLBACK;

----------------------------------------------------------
-- Test 4
-- record_expense()
----------------------------------------------------------

BEGIN;

DO $$
DECLARE
    v_cat UUID;
BEGIN
    SELECT category_id INTO v_cat FROM Category WHERE name='Food';
    CALL record_expense(v_cat, 350, CURRENT_DATE, 'Procedure Test Expense');
END; $$;

SELECT *

FROM Expense

WHERE description='Procedure Test Expense';

ROLLBACK;

----------------------------------------------------------
-- Test 5
-- update_expense()
----------------------------------------------------------

BEGIN;

DO $$
DECLARE
    v_exp_id UUID;
    v_cat_id UUID;
BEGIN
    SELECT expense_id, category_id INTO v_exp_id, v_cat_id FROM Expense LIMIT 1;
    CALL update_expense(v_exp_id, v_cat_id, 800, CURRENT_DATE, 'Updated Test Expense');
END; $$;

SELECT *

FROM Expense

WHERE description='Updated Test Expense';

ROLLBACK;

----------------------------------------------------------
-- Test 6
-- delete_expense()
----------------------------------------------------------

BEGIN;

SELECT COUNT(*)
FROM Expense;

DO $$
DECLARE
    v_exp_id UUID;
BEGIN
    SELECT expense_id INTO v_exp_id FROM Expense LIMIT 1;
    CALL delete_expense(v_exp_id);
END; $$;

SELECT COUNT(*)
FROM Expense;

ROLLBACK;

----------------------------------------------------------
-- Test 7
-- update_category()
----------------------------------------------------------

BEGIN;

DO $$
DECLARE
    v_cat UUID;
BEGIN
    SELECT category_id INTO v_cat FROM Category WHERE name='Food';
    CALL update_category(v_cat, 'Food Test', '#FFFFFF', 'restaurant');
END; $$;

SELECT *

FROM Category

WHERE name='Food Test';

ROLLBACK;

----------------------------------------------------------
-- Test 8
-- generate_budget_alerts()
----------------------------------------------------------

BEGIN;

DO $$
DECLARE
    v_per UUID;
BEGIN
    SELECT period_id INTO v_per FROM BudgetPeriod LIMIT 1;
    CALL generate_budget_alerts(v_per);
END; $$;

SELECT *

FROM Alert
ORDER BY created_at DESC
LIMIT 10;

ROLLBACK;

----------------------------------------------------------
-- Test 9
-- mark_alert_as_read()
----------------------------------------------------------

BEGIN;

DO $$
DECLARE
    v_alert_id UUID;
BEGIN
    SELECT alert_id INTO v_alert_id FROM Alert LIMIT 1;
    
    IF v_alert_id IS NOT NULL THEN
        CALL mark_alert_as_read(v_alert_id);
    END IF;
END; $$;

SELECT

alert_id,
is_read

FROM Alert

LIMIT 1;

ROLLBACK;

----------------------------------------------------------
-- Test 10
-- complete_import_history()
----------------------------------------------------------

BEGIN;

INSERT INTO ImportHistory(

file_name,
total_records

)

VALUES(

'test_import.csv',
50

);

DO $$
DECLARE
    v_import_id UUID;
BEGIN
    SELECT import_id INTO v_import_id FROM ImportHistory ORDER BY imported_at DESC LIMIT 1;
    CALL complete_import_history(v_import_id, 45, 5);
END; $$;

SELECT *

FROM ImportHistory

ORDER BY imported_at DESC
LIMIT 1;

ROLLBACK;

----------------------------------------------------------
-- End of Procedure Tests
----------------------------------------------------------