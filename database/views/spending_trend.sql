CREATE OR REPLACE VIEW spending_trend AS
SELECT *
FROM get_monthly_spending_trend();