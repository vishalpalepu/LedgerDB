CREATE OR REPLACE VIEW monthly_summary AS 
SELECT 
    bp.month,
    bp.year, 
    (
        SELECT COALESCE(SUM(b.budget_amount),0)
        FROM Budget b
        WHERE b.period_id = bp.period_id
    ) as total_budget,

    get_monthly_expense(bp.period_id) AS total_expense,

    get_total_remaining_budget(bp.period_id) AS remaining_budget,

    (
        get_monthly_expense(bp.period_id) / NULLIF(
            (SELECT COALESCE(SUM(b.budget_amount),0)
            FROM Budget b
            WHERE b.period_id = bp.period_id)
        ,0)
    )*100 AS budget_utilization
FROM BudgetPeriod bp
ORDER BY bp.year, bp.month;




    