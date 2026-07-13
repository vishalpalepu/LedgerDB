CREATE OR REPLACE PROCEDURE update_expense(
    IN p_expense_id UUID,
    IN p_category_id UUID,
    IN p_amount NUMERIC(12,2),
    IN p_expense_date DATE,
    IN p_description TEXT
)
LANGUAGE plpgsql
AS
$$
BEGIN

    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Expense amount must be greater than zero.';
    END IF;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Expense
        WHERE expense_id = p_expense_id
    )
    THEN
        RAISE EXCEPTION 'Expense not found.';
    END IF;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Category
        WHERE category_id = p_category_id
    )
    THEN
        RAISE EXCEPTION 'Category not found.';
    END IF;

    UPDATE Expense

    SET
        category_id = p_category_id,
        amount = p_amount,
        expense_date = p_expense_date,
        description = p_description,
        updated_at = CURRENT_TIMESTAMP

    WHERE expense_id = p_expense_id;

END;
$$;