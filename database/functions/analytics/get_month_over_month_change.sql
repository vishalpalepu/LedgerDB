CREATE OR REPLACE FUNCTION get_month_over_month_change()
RETURNS TABLE
(
    month SMALLINT,
    year INTEGER,
    current_spending NUMERIC(12,2),
    previous_spending NUMERIC(12,2),
    change_in_spending NUMERIC(12,2),
    change_percentage NUMERIC(12,2)
)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY

    -- CRAETE A TEMP TABLE WHICH ACTUALLY TAKES THE IMPORTANT DATA 
    WITH monthly_spending AS
    (
        SELECT
            bp.month,
            bp.year,
            COALESCE(SUM(e.amount),0)::NUMERIC(12,2) AS current_spending
        FROM BudgetPeriod bp
        LEFT JOIN Expense e
            ON e.expense_date BETWEEN bp.start_date AND bp.end_date
        GROUP BY bp.month,bp.year
    )

    -- USES THE ABOVE TEMP TABLE TO DO EXTRA CALCULATION FROM THE ACQUIRED DATA 
    SELECT
        ms.month,
        ms.year,
        ms.current_spending,

        LAG(ms.current_spending)
        OVER(ORDER BY ms.year,ms.month)
        AS previous_spending,

        (
            ms.current_spending -
            LAG(ms.current_spending)
            OVER(ORDER BY ms.year,ms.month)
        )::NUMERIC(12,2),

        (
            (
                ms.current_spending -
                LAG(ms.current_spending)
                OVER(ORDER BY ms.year,ms.month)
            )
            /
            NULLIF(
                LAG(ms.current_spending)
                OVER(ORDER BY ms.year,ms.month),
                0
            )
            *100
        )::NUMERIC(12,2)

    FROM monthly_spending ms
    ORDER BY ms.year,ms.month;
END;
$$;