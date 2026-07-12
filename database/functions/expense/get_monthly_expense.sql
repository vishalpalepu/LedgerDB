CREATE OR REPLACE FUNCTION get_monthly_expense(
    p_period_id UUID
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_total NUMERIC(12,2) := 0;
BEGIN
    SELECT COALESCE(SUM(e.amount),0) 
    INTO v_total
    FROM Expense e
    JOIN BudgetPeriod bp
    ON 
        e.expense_date BETWEEN bp.start_date AND bp.end_date
    WHERE 
        bp.period_id = p_period_id;
    
    RETURN v_total;
END;
$$;


-- how this WORKS 
-- You give the function a "p_period_id" (e.g., January 2026).
--                                │
--                                ▼
-- Find that ID in the BudgetPeriod table to get the Start & End Dates.
--                                │
--                                ▼
-- Look at the Expense table. Keep only the expenses that landed 
--                         BETWEEN those two dates.
--                                │
--                                ▼
-- Add up the 'amount' of all those matched expenses.
--                                │
--                                ▼
-- COALESCE checks the sum. If it is empty (NULL), it turns it into 0.
--                                │
--                                ▼
--                  Return the final v_total number.

