CREATE OR REPLACE FUNCTION get_budget_utilization(
    p_category_id UUID,
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
AS $$
DECLARE
    v_category_expense NUMERIC(12,2);
    v_category_budget NUMERIC(12,2);
    v_utilization NUMERIC(12,2);
BEGIN
    v_category_expense := get_total_category_expense(p_category_id,p_period_id);

    SELECT COALESCE(b.budget_amount,0)
    INTO v_category_budget
    FROM Budget b
    WHERE b.category_id = p_category_id AND b.period_id = p_period_id;

    IF v_category_budget = 0 THEN
        RETURN 0;
    END IF;

    v_utilization := (v_category_expense / v_category_budget) * 100;
    RETURN v_utilization;
END;
$$ LANGUAGE plpgsql;