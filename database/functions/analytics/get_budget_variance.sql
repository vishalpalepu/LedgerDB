CREATE OR REPLACE FUNCTION get_budget_variance(
    p_period_id UUID
)
RETURNS TABLE
(
    category_name VARCHAR(100),
    budget_amount NUMERIC(12,2),
    actual_spending NUMERIC(12,2),
    variance NUMERIC(12,2)
)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY

    SELECT
        c.name,
        b.budget_amount,
        COALESCE(
            SUM(e.amount),
            0
        )::NUMERIC(12,2),
        (
            b.budget_amount -
            COALESCE(SUM(e.amount),0)
        )::NUMERIC(12,2)

    FROM Budget b

    JOIN Category c
        ON c.category_id = b.category_id

    JOIN BudgetPeriod bp
        ON bp.period_id = b.period_id

    LEFT JOIN Expense e
        ON e.category_id = b.category_id
        AND e.expense_date
            BETWEEN bp.start_date
                AND bp.end_date

    WHERE b.period_id = p_period_id

    GROUP BY
        c.name,
        b.budget_amount

    ORDER BY c.name;

END;
$$;