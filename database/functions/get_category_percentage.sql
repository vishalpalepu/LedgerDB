CREATE OR REPLACE FUNCTION get_category_percentage(
    p_category_id UUID,
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS 
$$
DECLARE
    v_total_month_expense NUMERIC(12,2);
    v_category_expense NUMERIC(12,2);
    v_percentage NUMERIC(12,2);
BEGIN
    v_total_month_expense := get_monthly_expense(p_period_id);
    v_category_expense := get_total_category_expense(p_category_id,p_period_id);

    IF v_total_month_expense = 0 THEN 
        RETURN 0;
    ELSE 
        v_percentage := (v_category_expense / v_total_month_expense) * 100;
        RETURN v_percentage;
    END IF;
END;
$$;