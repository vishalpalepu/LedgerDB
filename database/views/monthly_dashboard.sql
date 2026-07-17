CREATE OR REPLACE VIEW monthly_dashboard AS
SELECT

    ms.month,

    ms.year,

    ms.total_budget,

    ms.total_expenses,

    ms.remaining_budget,

    ms.budget_utilization,

    (
        SELECT get_highest_spending_category(bp.period_id)
        FROM BudgetPeriod bp
        WHERE bp.month = ms.month
        AND bp.year = ms.year
    ) AS highest_spending_category,

    (
        SELECT COUNT(*)
        FROM Alert a
        JOIN BudgetPeriod bp
        ON a.period_id = bp.period_id
        WHERE bp.month = ms.month
        AND bp.year = ms.year
    ) AS total_alerts

FROM monthly_summary ms;