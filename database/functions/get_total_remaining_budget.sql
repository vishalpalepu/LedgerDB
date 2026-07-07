CREATE OR REPLACE FUNCTION get_total_remaining_budget(
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_row RECORD;
    v_remaining_total NUMERIC(12,2) = 0;
BEGIN
    FOR v_row IN SELECT category_id FROM Category 
    LOOP
        v_remaining_total := v_remaining_total + get_remaining_budget(v_row.category_id,p_period_id);
    END LOOP

    RETURN v_remaining_total
END;
$$;
