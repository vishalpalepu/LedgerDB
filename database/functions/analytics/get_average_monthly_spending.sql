CREATE OR REPLACE FUNCTION get_average_monthly_spending()
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_average NUMERIC(12,2);
BEGIN
    SELECT
        AVG(month_total)::NUMERIC(12,2)
    INTO v_average
    FROM
    (
        SELECT
            bp.period_id,
            COALESCE(SUM(e.amount),0) AS month_total
        FROM BudgetPeriod bp
        LEFT JOIN Expense e
            ON e.expense_date BETWEEN bp.start_date AND bp.end_date
        GROUP BY bp.period_id
    ) monthly_totals;

    RETURN COALESCE(v_average,0);
END;
$$;