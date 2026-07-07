CREATE INDEX idx_expense_category
ON Expense(category_id);

CREATE INDEX idx_expense_data
ON Expense(expense_date);

CREATE INDEX idx_category_expense_date
ON Expense(category_id,expense_date);

CREATE INDEX idx_budget_category
ON Budget(category_id);

CREATE INDEX idx_budget_period
ON Budget(period_id);

CREATE INDEX idx_alert_is_read
ON Alert(is_read);

CREATE INDEX idx_auditlog_table
ON AuditLog(table_name);

CREATE INDEX idx_auditlog_record
ON AuditLog(record_id);

CREATE INDEX idx_importhistory_imported_at
ON ImportHistory(imported_at);