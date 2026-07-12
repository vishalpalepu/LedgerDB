CREATE OR REPLACE FUNCTION get_average_daily_spend(
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS  
$$
DECLARE
    v_total_expense NUMERIC(12,2);
    v_days INT;
BEGIN
    v_total_expense := get_monthly_expense(p_period_id);

    SELECT (end_date - start_date + 1)::INT
    INTO v_days
    FROM BudgetPeriod bp 
    WHERE bp.period_id = p_period_id;

    IF v_days = 0 THEN
        RETURN 0;
    END IF;

    RETURN v_total_expense / v_days;
END;
$$;