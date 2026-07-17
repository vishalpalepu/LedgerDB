CREATE OR REPLACE VIEW alert_summary AS
SELECT

    COUNT(*) AS total_alerts,

    COUNT(*) FILTER (
        WHERE is_read = TRUE
    ) AS read_alerts,

    COUNT(*) FILTER (
        WHERE is_read = FALSE
    ) AS unread_alerts

FROM Alert;