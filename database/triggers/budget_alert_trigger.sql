CREATE OR REPLACE FUNCTION check_budget_after_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
    v_period_id UUID;
BEGIN 
    SELECT bp.period_id 
    INTO v_period_id
    FROM BudgetPeriod bp
    WHERE NEW.expense_date BETWEEN bp.start_date AND bp.end_date;
    
    IF v_period_id IS NOT NULL AND is_budget_exceeded(NEW.category_id, v_period_id) THEN
        INSERT INTO Alert(
            budget_id,
            message,
            is_read,
            created_at
        )
        VALUES(
            NEW.budget_id,
            'You have exceeded your budget for ' || NEW.category_id,
            FALSE,
            CURRENT_TIMESTAMP
        );
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER before_expense_insert_check_budget
BEFORE INSERT
ON Expense
FOR EACH ROW
EXECUTE FUNCTION check_budget_after_insert();