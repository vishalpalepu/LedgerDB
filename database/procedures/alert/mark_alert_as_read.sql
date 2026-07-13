CREATE OR REPLACE PROCEDURE mark_alert_as_read(
    IN p_alert_id UUID
)
LANGUAGE plpgsql
AS
$$
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Alert
        WHERE alert_id = p_alert_id
    )
    THEN
        RAISE EXCEPTION 'Alert does not exist.';
    END IF;

    UPDATE Alert

    SET is_read = TRUE

    WHERE alert_id = p_alert_id;

END;
$$;