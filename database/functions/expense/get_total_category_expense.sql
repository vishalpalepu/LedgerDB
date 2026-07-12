CREATE OR REPLACE FUNCTION get_total_category_expense(
    p_category_id UUID,
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS 
$$
DECLARE
    v_total NUMERIC(12,2);
BEGIN
    SELECT COALESCE(SUM(e.amount),0)
    INTO v_total
    FROM Expense e
    JOIN BudgetPeriod bp
        ON e.expense_date BETWEEN bp.start_date AND bp.end_date
    WHERE
        e.category_id = p_category_id AND
        bp.period_id = p_period_id;
    
    RETURN v_total;
END;
$$;


-- how to use this FUNCTION
-- SELECT get_total_category_expense(
--     'category_uuid',
--     'period_uuid'
-- );