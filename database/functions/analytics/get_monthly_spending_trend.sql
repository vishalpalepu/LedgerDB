CREATE OR REPLACE FUNCTION get_monthly_spending_trend()
RETURNS TABLE(
    month SMALLINT,
    year INTEGER,
    total_spending NUMERIC(12,2)
)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
    SELECT
        bp.month,
        bp.year,
        COALESCE(SUM(e.amount), 0)::NUMERIC(12,2)
    FROM BudgetPeriod bp
    LEFT JOIN Expense e
        ON e.expense_date BETWEEN bp.start_date AND bp.end_date
    GROUP BY bp.month, bp.year
    ORDER BY bp.year, bp.month;
END;
$$;