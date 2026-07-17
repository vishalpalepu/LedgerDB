CREATE OR REPLACE FUNCTION get_remaining_category_budget(
    p_category_id UUID,
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_spent NUMERIC(12,2);
    v_remaining_budget NUMERIC(12,2);
BEGIN
    v_spent := get_total_category_expense(p_category_id,p_period_id);

    SELECT COALESCE(b.budget_amount,0)
    INTO v_remaining_budget
    FROM Budget b
    WHERE b.category_id = p_category_id AND 
        b.period_id = p_period_id;

    RETURN (v_remaining_budget - v_spent);
END;
$$;


-- how to use this FUNCTION
-- SELECT get_remaining_budget(
--     'category_uuid',
--     'period_uuid'
-- );