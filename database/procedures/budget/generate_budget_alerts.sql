CREATE OR REPLACE PROCEDURE generate_budget_alerts(
    IN p_period_id UUID
)
LANGUAGE plpgsql
AS
$$
DECLARE
    rec RECORD;
BEGIN

    FOR rec IN

        SELECT
            budget_id,
            category_id
        FROM Budget
        WHERE period_id = p_period_id

    LOOP

        IF is_budget_exceeded(
            rec.category_id,
            p_period_id
        ) THEN

            INSERT INTO Alert
            (
                budget_id,
                message
            )
            VALUES
            (
                rec.budget_id,
                'Budget exceeded for category.'
            );

        END IF;

    END LOOP;

END;
$$;