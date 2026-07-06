CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE Category(
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    color VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE BudgetPeriod(
    period_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    month SMALLINT NOT NULL CHECK (month BETWEEN 1 AND 12),
    year INTEGER NOT NULL CHECK (year >= 2025),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_budget_period UNIQUE(month,year),
    CONSTRAINT valid_period CHECK(start_date <= end_date)
);

CREATE TABLE BUDGET(
    budget_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL,
    period_id UUID NOT NULL,
    budget_limit NUMERIC(12,2) NOT NULL CHECK (budget_limit > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

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