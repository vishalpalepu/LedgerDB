CREATE OR REPLACE PROCEDURE delete_expense(
    IN p_expense_id UUID
)
LANGUAGE plpgsql
AS
$$
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Expense
        WHERE expense_id = p_expense_id
    )
    THEN
        RAISE EXCEPTION 'Expense not found.';
    END IF;

    DELETE
    FROM Expense
    WHERE expense_id = p_expense_id;

END;
$$;