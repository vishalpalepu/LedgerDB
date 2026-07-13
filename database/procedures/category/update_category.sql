CREATE OR REPLACE PROCEDURE update_category(
    IN p_category_id UUID,
    IN p_name VARCHAR(100),
    IN p_color VARCHAR(20),
    IN p_icon VARCHAR(50)
)
LANGUAGE plpgsql
AS
$$
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Category
        WHERE category_id = p_category_id
    )
    THEN
        RAISE EXCEPTION 'Category not found.';
    END IF;

    UPDATE Category

    SET
        name = p_name,
        color = p_color,
        icon = p_icon

    WHERE category_id = p_category_id;

END;
$$;