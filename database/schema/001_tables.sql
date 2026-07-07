CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE Category(
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE CHECK(length(name) > 0),
    color VARCHAR(20),
    icon VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE BudgetPeriod(
    period_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    month SMALLINT NOT NULL CHECK (month BETWEEN 1 AND 12),
    year INTEGER NOT NULL CHECK (year >= 2025),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_budget_period UNIQUE(month,year),
    CONSTRAINT valid_period CHECK(start_date <= end_date)
);

CREATE TABLE Budget(
    budget_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL,
    period_id UUID NOT NULL,
    budget_amount NUMERIC(12,2) NOT NULL CHECK (budget_amount > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_budget_category
        FOREIGN KEY (category_id)
        REFERENCES Category(category_id)
        ON DELETE CASCADE,
    
    CONSTRAINT fk_budget_period
        FOREIGN KEY (period_id)
        REFERENCES BudgetPeriod(period_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_category_budget
        UNIQUE(category_id,period_id)
)

CREATE TABLE Expense(
    expense_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK(amount > 0),
    expense_date DATE NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_expense_category
        FOREIGN KEY (category_id)
        REFERENCES Category(category_id)
        ON DELETE CASCADE
);

CREATE TABLE Alert(
    alert_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    budget_id UUID NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alert_budget
        FOREIGN KEY (budget_id)
        REFERENCES Budget(budget_id)
        ON DELETE RESTRICT
);


CREATE TABLE AuditLog(
    auditlog_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (
        operation in ('INSERT' ,'UPDATE', 'DELETE')
    ),

    old_data JSONB,
    new_data JSONB,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
