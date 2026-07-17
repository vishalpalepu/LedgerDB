-- ==========================================
-- LedgerDB - Default Categories
-- ==========================================

INSERT INTO Category (name, color, icon)
VALUES
    ('Food',           '#FF6B6B', 'restaurant'),
    ('Transport',      '#4ECDC4', 'directions_car'),
    ('Rent',           '#1A535C', 'home'),
    ('Utilities',      '#FFE66D', 'bolt'),
    ('Entertainment',  '#FF9F1C', 'movie'),
    ('Shopping',       '#9B5DE5', 'shopping_bag'),
    ('Healthcare',     '#2EC4B6', 'local_hospital'),
    ('Education',      '#3A86FF', 'school'),
    ('Travel',         '#06D6A0', 'flight'),
    ('Insurance',      '#118AB2', 'verified_user'),
    ('Savings',        '#8AC926', 'savings'),
    ('Investment',     '#6A994E', 'trending_up'),
    ('Gifts',          '#F15BB5', 'card_giftcard'),
    ('Subscriptions',  '#8338EC', 'subscriptions'),
    ('Miscellaneous',  '#6C757D', 'category')
ON CONFLICT (name)
DO NOTHING;

-- ==========================================
-- Verify Seed Data
-- ==========================================

SELECT
    category_id,
    name,
    color,
    icon
FROM Category
ORDER BY name;