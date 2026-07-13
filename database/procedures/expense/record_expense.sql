CREATE OR REPLACE PROCEDURE record_expense(
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
        FROM Category
        WHERE category_id = p_category_id
    )
    THEN
        RAISE EXCEPTION 'Category does not exist.';
    END IF;

    INSERT INTO Expense
    (
        category_id,
        amount,
        expense_date,
        description
    )
    VALUES
    (
        p_category_id,
        p_amount,
        p_expense_date,
        p_description
    );

END;
$$;