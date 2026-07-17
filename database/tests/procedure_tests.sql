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

CALL set_budget(

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
),

7500

);

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

CALL update_budget(

(
SELECT budget_id
FROM Budget
LIMIT 1
),

9000

);

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

CALL record_expense(

(
SELECT category_id
FROM Category
WHERE name='Food'
),

350,

CURRENT_DATE,

'Procedure Test Expense'

);

SELECT *

FROM Expense

WHERE description='Procedure Test Expense';

ROLLBACK;

----------------------------------------------------------
-- Test 5
-- update_expense()
----------------------------------------------------------

BEGIN;

CALL update_expense(

(
SELECT expense_id
FROM Expense
LIMIT 1
),

800,

CURRENT_DATE,

'Updated Test Expense'

);

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

CALL delete_expense(

(
SELECT expense_id
FROM Expense
LIMIT 1
)

);

SELECT COUNT(*)
FROM Expense;

ROLLBACK;

----------------------------------------------------------
-- Test 7
-- update_category()
----------------------------------------------------------

BEGIN;

CALL update_category(

(
SELECT category_id
FROM Category
WHERE name='Food'
),

'Food Test',

'#FFFFFF',

'restaurant'

);

SELECT *

FROM Category

WHERE name='Food Test';

ROLLBACK;

----------------------------------------------------------
-- Test 8
-- generate_budget_alerts()
----------------------------------------------------------

BEGIN;

CALL generate_budget_alerts();

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

CALL mark_alert_as_read(

(
SELECT alert_id
FROM Alert
LIMIT 1
)

);

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

CALL complete_import_history(

(
SELECT import_id
FROM ImportHistory
ORDER BY imported_at DESC
LIMIT 1
),

45,
5

);

SELECT *

FROM ImportHistory

ORDER BY imported_at DESC
LIMIT 1;

ROLLBACK;

----------------------------------------------------------
-- End of Procedure Tests
----------------------------------------------------------