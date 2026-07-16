CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER before_budget_update_timestamp
BEFORE UPDATE
ON Budget
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER before_expense_update_timestamp
BEFORE UPDATE
ON Expense
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER before_category_update_timestamp
BEFORE UPDATE
ON Category
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();
