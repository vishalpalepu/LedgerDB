CREATE OR REPLACE FUNCTION get_consecutive_overspending_streak()
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE

    v_current_streak INT := 0;
    v_max_streak INT := 0;

    rec RECORD;

BEGIN

    FOR rec IN

        SELECT

            bp.period_id,

            COALESCE(SUM(b.budget_amount),0) AS total_budget,

            COALESCE(SUM(e.amount),0) AS total_expense

        FROM BudgetPeriod bp

        LEFT JOIN Budget b
            ON b.period_id = bp.period_id

        LEFT JOIN Expense e
            ON e.expense_date
                BETWEEN bp.start_date
                    AND bp.end_date

        GROUP BY bp.period_id,bp.year,bp.month

        ORDER BY bp.year,bp.month

    LOOP

        IF rec.total_expense > rec.total_budget THEN

            v_current_streak := v_current_streak + 1;

            IF v_current_streak > v_max_streak THEN

                v_max_streak := v_current_streak;

            END IF;

        ELSE

            v_current_streak := 0;

        END IF;

    END LOOP;

    RETURN v_max_streak;

END;
$$;