CREATE OR REPLACE FUNCTION get_highest_spending_month()
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    v_highest_spending_month INT;
BEGIN

    SELECT bp.month
    INTO v_highest_spending_month
    FROM BudgetPeriod bp
    LEFT JOIN Expense e
        ON e.expense_date BETWEEN bp.start_date
                             AND bp.end_date
    WHERE bp.year = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY bp.month
    ORDER BY SUM(e.amount) DESC NULLS LAST
    LIMIT 1;

    RETURN v_highest_spending_month;

END;
$$;