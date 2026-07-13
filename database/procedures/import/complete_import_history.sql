CREATE OR REPLACE PROCEDURE complete_import_history(
    IN p_import_id UUID,
    IN p_successful_records INT,
    IN p_failed_records INT
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_total_records INT;
BEGIN

    SELECT total_records
    INTO v_total_records
    FROM ImportHistory
    WHERE import_id = p_import_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Import record not found.';
    END IF;

    IF p_successful_records + p_failed_records > v_total_records THEN
        RAISE EXCEPTION 'Successful and failed records exceed total records.';
    END IF;

    UPDATE ImportHistory

    SET
        successful_records = p_successful_records,
        failed_records = p_failed_records

    WHERE import_id = p_import_id;

END;
$$;