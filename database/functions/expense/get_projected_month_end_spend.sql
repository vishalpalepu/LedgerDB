CREATE OR REPLACE FUNCTION get_projected_month_end_spend(
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_total_expense NUMERIC(12,2);
    v_start_date DATE;
    v_end_date DATE;
    v_elapsed_days INT;
    v_total_days INT;
BEGIN
    -- Get period details
    SELECT start_date, end_date
    INTO v_start_date, v_end_date
    FROM BudgetPeriod
    WHERE period_id = p_period_id;

    -- Total expense incurred so far
    v_total_expense := get_monthly_expense(p_period_id);

    -- Total number of days in the budget period
    v_total_days := (v_end_date - v_start_date + 1)::INT;

    -- Days elapsed for forecasting
    IF CURRENT_DATE < v_start_date THEN
        RETURN 0;
    ELSIF CURRENT_DATE > v_end_date THEN
        v_elapsed_days := v_total_days;
    ELSE
        v_elapsed_days := (CURRENT_DATE - v_start_date + 1)::INT;
    END IF;

    IF v_elapsed_days = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND(
        (v_total_expense / v_elapsed_days) * v_total_days,
        2
    );
END;
$$;