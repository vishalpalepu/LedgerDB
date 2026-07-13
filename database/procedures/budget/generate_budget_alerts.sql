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
            b.budget_id,
            b.category_id,
            c.name AS category_name
        FROM Budget b
        JOIN Category c
            ON b.category_id = c.category_id
        WHERE b.period_id = p_period_id
    LOOP

        IF is_budget_exceeded(rec.category_id, p_period_id) THEN

            IF NOT EXISTS
            (
                SELECT 1
                FROM Alert a
                WHERE a.budget_id = rec.budget_id
                  AND a.is_read = FALSE
            )
            THEN

                INSERT INTO Alert
                (
                    budget_id,
                    message
                )
                VALUES
                (
                    rec.budget_id,
                    FORMAT(
                        'Budget exceeded for category "%s".',
                        rec.category_name
                    )
                );

            END IF;

        END IF;

    END LOOP;

END;
$$;