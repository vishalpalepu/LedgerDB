CREATE OR REPLACE FUNCTION get_category_spending_trend(
    p_category_id UUID
)
RETURNS TABLE(
    month SMALLINT,
    year INTEGER,
    category_spending NUMERIC(12,2)
)
LANGUAGE plpgsql
AS
$$ 
BEGIN 
    RETURN QUERY
    SELECT
        bp.month,
        bp.year,
        COALESCE(SUM(e.amount), 0)
    FROM BudgetPeriod bp
    LEFT JOIN Expense e 
        ON e.expense_date BETWEEN bp.start_date AND bp.end_date
        AND e.category_id = p_category_id
    GROUP BY bp.month, bp.year
    ORDER BY bp.year, bp.month;
END;
$$;
