CREATE OR REPLACE VIEW category_summary AS
SELECT
    c.name AS category_name,

    COALESCE(SUM(e.amount), 0) AS total_expense,

    COUNT(e.expense_id) AS number_of_transactions,

    COALESCE(AVG(e.amount), 0) AS average_expense,

    COALESCE(MIN(e.amount), 0) AS lowest_expense,

    COALESCE(MAX(e.amount), 0) AS highest_expense

FROM Category c

LEFT JOIN Expense e
ON c.category_id = e.category_id

GROUP BY
    c.category_id,
    c.name

ORDER BY total_expense DESC;