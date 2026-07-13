CREATE OR REPLACE PROCEDURE update_budget(
    IN p_budget_id UUID,
    IN p_budget_amount NUMERIC(12,2)
)
LANGUAGE plpgsql
AS
$$
BEGIN

    IF p_budget_amount <= 0 THEN
        RAISE EXCEPTION 'Budget amount must be greater than zero.';
    END IF;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Budget
        WHERE budget_id = p_budget_id
    )
    THEN
        RAISE EXCEPTION 'Budget does not exist.';
    END IF;

    UPDATE Budget

    SET
        budget_amount = p_budget_amount,
        updated_at = CURRENT_TIMESTAMP

    WHERE budget_id = p_budget_id;

END;
$$;