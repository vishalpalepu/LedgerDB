CREATE OR REPLACE FUNCTION is_budget_exceeded(
    p_category_id UUID,
    p_period_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS
$$
BEGIN 
    RETURN get_remaining_category_budget(p_category_id,p_period_id) < 0;
END;
$$;
    
