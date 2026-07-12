CREATE OR REPLACE FUNCTION get_highest_spending_category(
    p_period_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
AS
$$
DECLARE 
    v_catergory_id UUID;
BEGIN
    SELECT e.category_id
    INTO v_catergory_id
    FROM Expense e 
    JOIN BudgetPeriod bp
    ON 
        e.expense_date BETWEEN bp.start_date AND bp.end_date
        AND bp.period_id = p_period_id
    GROUP BY 
        e.category_id
    ORDER BY 
        SUM(e.amount) DESC
    LIMIT 1;

    RETURN v_catergory_id;

END;
$$;
