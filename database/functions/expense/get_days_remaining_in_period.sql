CREATE OR REPLACE FUNCTION get_days_remaining_in_period(
    p_period_id UUID
)
RETURNS INT
LANGUAGE plpgsql
AS 
$$
DECLARE 
    v_end_date DATE;
BEGIN
    SELECT end_date
    INTO v_end_date
    FROM BudgetPeriod
    WHERE period_id = p_period_id;
    
    RETURN GREATEST((v_end_date - CURRENT_DATE)::INT , 0);
END;
$$