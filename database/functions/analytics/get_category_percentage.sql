CREATE OR REPLACE FUNCTION get_category_percentage(
    p_period_id UUID
)
RETURNS TABLE (
    category_id UUID,
    category_name VARCHAR,
    percentage NUMERIC(12,2)
)
LANGUAGE plpgsql
AS 
$$
DECLARE
    v_total_month_expense NUMERIC(12,2);
BEGIN
    v_total_month_expense := get_monthly_expense(p_period_id);

    RETURN QUERY
    SELECT 
        c.category_id,
        c.name AS category_name,
        CASE 
            WHEN COALESCE(v_total_month_expense, 0) = 0 THEN 0.00
            ELSE ROUND((COALESCE(get_total_category_expense(c.category_id, p_period_id), 0) / v_total_month_expense) * 100, 2)
        END AS percentage
    FROM Category c
    ORDER BY percentage DESC;
END;
$$;