CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
    v_record_id UUID;
BEGIN

    /*
        TG_ARGV[0] contains the primary key column name.

        Examples:
            'budget_id'
            'expense_id'
            'category_id'
    */

    IF TG_OP = 'INSERT' THEN

        v_record_id :=
            (to_jsonb(NEW)->>TG_ARGV[0])::UUID; --gets the record id of the new record ->> is operation of json to extract TG_ARV[0]
            -- is the name of the coloum which is used to get the value from teh json as well

        INSERT INTO AuditLog
        (
            table_name,
            record_id,
            operation,
            old_data,
            new_data
        )
        VALUES
        (
            TG_TABLE_NAME,
            v_record_id,
            TG_OP,
            NULL,
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN

        v_record_id :=
            (to_jsonb(NEW)->>TG_ARGV[0])::UUID;

        INSERT INTO AuditLog
        (
            table_name,
            record_id,
            operation,
            old_data,
            new_data
        )
        VALUES
        (
            TG_TABLE_NAME,
            v_record_id,
            TG_OP,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN

        v_record_id :=
            (to_jsonb(OLD)->>TG_ARGV[0])::UUID;

        INSERT INTO AuditLog
        (
            table_name,
            record_id,
            operation,
            old_data,
            new_data
        )
        VALUES
        (
            TG_TABLE_NAME,
            v_record_id,
            TG_OP,
            to_jsonb(OLD),
            NULL
        );

        RETURN OLD;

    END IF;

    RETURN NULL;

END;
$$;

CREATE TRIGGER audit_budget_changes
AFTER INSERT OR UPDATE OR DELETE
ON Budget
FOR EACH ROW
EXECUTE FUNCTION audit_changes('budget_id');

CREATE TRIGGER audit_expense_changes
AFTER INSERT OR UPDATE OR DELETE
ON Expense
FOR EACH ROW
EXECUTE FUNCTION audit_changes('expense_id');

CREATE TRIGGER audit_category_changes
AFTER INSERT OR UPDATE OR DELETE
ON Category
FOR EACH ROW
EXECUTE FUNCTION audit_changes('category_id');

CREATE TRIGGER audit_budgetperiod_changes
AFTER INSERT OR UPDATE OR DELETE
ON BudgetPeriod
FOR EACH ROW
EXECUTE FUNCTION audit_changes('period_id');

CREATE TRIGGER audit_alert_changes
AFTER INSERT OR UPDATE OR DELETE
ON Alert
FOR EACH ROW
EXECUTE FUNCTION audit_changes('alert_id');

CREATE TRIGGER audit_importhistory_changes
AFTER INSERT OR UPDATE OR DELETE
ON ImportHistory
FOR EACH ROW
EXECUTE FUNCTION audit_changes('import_id');