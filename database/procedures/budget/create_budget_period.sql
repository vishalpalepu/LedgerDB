CREATE OR REPLACE PROCEDURE create_budget_period(
    IN p_month INTEGER,
    IN p_year INTEGER
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_start_date DATE;
    v_end_date DATE;
BEGIN

    IF p_month NOT BETWEEN 1 AND 12 THEN
        RAISE EXCEPTION 'Invalid month.';
    END IF;

    IF p_year < 2025 THEN
        RAISE EXCEPTION 'Invalid year.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM BudgetPeriod
        WHERE month = p_month
          AND year = p_year
    ) THEN
        RAISE EXCEPTION 'Budget period already exists.';
    END IF;

    v_start_date := make_date(p_year, p_month, 1);

    v_end_date :=
        (date_trunc('month', v_start_date)
        + interval '1 month - 1 day')::date;

    INSERT INTO BudgetPeriod
    (
        month,
        year,
        start_date,
        end_date
    )
    VALUES
    (
        p_month,
        p_year,
        v_start_date,
        v_end_date
    );

END;
$$;