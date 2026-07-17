CREATE OR REPLACE VIEW remaining_budget AS
SELECT
    bp.month,
    bp.year,

    c.name AS category_name,

    b.budget_amount,

    get_total_category_expense(
        c.category_id,
        bp.period_id
    ) AS total_spent,

    get_remaining_category_budget(
        c.category_id,
        bp.period_id
    ) AS remaining_budget

FROM Budget b

JOIN Category c
ON b.category_id = c.category_id

JOIN BudgetPeriod bp
ON b.period_id = bp.period_id

ORDER BY
    bp.year,
    bp.month,
    c.name;