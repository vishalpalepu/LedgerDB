CREATE OR REPLACE VIEW budget_vs_actual AS
SELECT
    bp.month,
    bp.year,

    c.name AS category_name,

    b.budget_amount AS budget,

    get_total_category_expense(
        c.category_id,
        bp.period_id
    ) AS actual_spending,

    get_remaining_category_budget(
        c.category_id,
        bp.period_id
    ) AS remaining_budget,

    b.budget_amount -
    get_total_category_expense(
        c.category_id,
        bp.period_id
    ) AS variance

FROM Budget b

JOIN Category c
ON b.category_id = c.category_id

JOIN BudgetPeriod bp
ON b.period_id = bp.period_id

ORDER BY
    bp.year,
    bp.month,
    c.name;