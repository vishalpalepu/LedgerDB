CREATE OR REPLACE PROCEDURE set_budget(
    IN p_category_id UUID,
    IN p_period_id UUID,
    IN p_budget_amount NUMERIC(12,2)
)
LANGUAGE plpgsql
AS
$$
BEGIN

    IF p_budget_amount <= 0 THEN
        RAISE EXCEPTION 'Budget must be greater than zero.';
    END IF;


    IF NOT EXISTS (
        Select 1
        FROM Category
        WHERE category_id = p_category_id
    )
    THEN
        RAISE EXCEPTION 'Category not found.';
    END IF;

    IF NOT EXISTS (
        Select 1
        FROM BudgetPeriod
        WHERE period_id = p_period_id
    )
    THEN
        RAISE EXCEPTION 'Period not found.';
    END IF;

    INSERT INTO Budget
    (
        category_id,
        period_id,
        budget_amount
    )

    VALUES
    (
        p_category_id,
        p_period_id,
        p_budget_amount
    )

    ON CONFLICT(category_id,period_id) -- unique / primary key so avoid insert but update it

    DO UPDATE

    SET
        budget_amount = EXCLUDED.budget_amount,
        updated_at = CURRENT_TIMESTAMP;

END;
$$;