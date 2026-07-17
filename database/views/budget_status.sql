CREATE OR REPLACE VIEW budget_status AS
SELECT
    bp.month,
    bp.year,

    c.name AS category_name,

    b.budget_amount,

    get_total_category_expense(
        c.category_id,
        bp.period_id
    ) AS total_spent,

    get_budget_utilization(
        c.category_id,
        bp.period_id
    ) AS utilization_percentage,

    CASE

        WHEN is_budget_exceeded(
            c.category_id,
            bp.period_id
        )
        THEN 'Exceeded'

        WHEN get_budget_utilization(
            c.category_id,
            bp.period_id
        ) >= 80
        THEN 'Near Limit'

        ELSE 'Under Budget'

    END AS budget_status

FROM Budget b

JOIN Category c
ON b.category_id = c.category_id

JOIN BudgetPeriod bp
ON b.period_id = bp.period_id

ORDER BY
    bp.year,
    bp.month,
    c.name;