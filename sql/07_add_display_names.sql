-- ============================================================
-- 07_add_display_names.sql
-- Agrega nombres ficticios a dim_product y dim_store
-- para mejorar legibilidad del dashboard de portafolio.
-- ============================================================

USE inventory;
GO

-- --------------------------------------------------------
-- dim_store: agregar store_name
-- --------------------------------------------------------
ALTER TABLE dw.dim_store ADD store_name VARCHAR(100) NULL;
GO

UPDATE dw.dim_store
SET store_name = CASE store_id
    WHEN 'S001' THEN 'Downtown Flagship'
    WHEN 'S002' THEN 'Northside Branch'
    WHEN 'S003' THEN 'Southgate Mall'
    WHEN 'S004' THEN 'Eastview Center'
    WHEN 'S005' THEN 'Westfield Plaza'
    ELSE store_id
END;
GO

-- --------------------------------------------------------
-- dim_product: agregar product_name
-- Nombres asignados por ROW_NUMBER dentro de cada categoria
-- --------------------------------------------------------
ALTER TABLE dw.dim_product ADD product_name VARCHAR(100) NULL;
GO

WITH ranked AS (
    SELECT
        product_key,
        category,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY product_id) AS rn
    FROM dw.dim_product
)
UPDATE p
SET p.product_name = CASE r.category

    WHEN 'Groceries' THEN CASE r.rn
        WHEN 1  THEN 'Whole Grain Bread'
        WHEN 2  THEN 'Fresh Orange Juice'
        WHEN 3  THEN 'Greek Yogurt'
        WHEN 4  THEN 'Brown Rice 2kg'
        WHEN 5  THEN 'Extra Virgin Olive Oil'
        WHEN 6  THEN 'Canned Tuna Pack'
        WHEN 7  THEN 'Granola Bars Box'
        WHEN 8  THEN 'Almond Milk 1L'
        WHEN 9  THEN 'Pasta Sauce Jar'
        WHEN 10 THEN 'Frozen Mixed Vegetables'
        WHEN 11 THEN 'Peanut Butter'
        WHEN 12 THEN 'Sea Salt Crackers'
        WHEN 13 THEN 'Premium Coffee Blend'
        ELSE 'Grocery Item ' + CAST(r.rn AS VARCHAR)
    END

    WHEN 'Furniture' THEN CASE r.rn
        WHEN 1  THEN 'Oak Dining Table'
        WHEN 2  THEN 'Ergonomic Office Chair'
        WHEN 3  THEN 'Bookshelf 5-Tier'
        WHEN 4  THEN 'Sofa 3-Seater'
        WHEN 5  THEN 'Queen Bed Frame'
        WHEN 6  THEN 'Glass Coffee Table'
        WHEN 7  THEN 'Wardrobe 2-Door'
        WHEN 8  THEN 'Adjustable Desk Lamp'
        WHEN 9  THEN 'TV Media Stand'
        WHEN 10 THEN 'Bedside Nightstand'
        WHEN 11 THEN 'Dresser 4-Drawer'
        WHEN 12 THEN 'Outdoor Garden Chair'
        WHEN 13 THEN 'Filing Cabinet 2-Drawer'
        ELSE 'Furniture Item ' + CAST(r.rn AS VARCHAR)
    END

    WHEN 'Clothing' THEN CASE r.rn
        WHEN 1  THEN 'Classic Denim Jeans'
        WHEN 2  THEN 'Cotton Crew T-Shirt'
        WHEN 3  THEN 'Merino Wool Sweater'
        WHEN 4  THEN 'Winter Parka Jacket'
        WHEN 5  THEN 'Running Sneakers'
        WHEN 6  THEN 'Casual Summer Dress'
        WHEN 7  THEN 'Oxford Business Shirt'
        WHEN 8  THEN 'High-Waist Yoga Pants'
        WHEN 9  THEN 'Leather Braided Belt'
        WHEN 10 THEN 'Snapback Baseball Cap'
        WHEN 11 THEN 'Athletic Socks 6-Pack'
        WHEN 12 THEN 'Waterproof Rain Coat'
        WHEN 13 THEN 'Chelsea Ankle Boots'
        ELSE 'Clothing Item ' + CAST(r.rn AS VARCHAR)
    END

    WHEN 'Electronics' THEN CASE r.rn
        WHEN 1  THEN 'Wireless Noise-Cancel Headphones'
        WHEN 2  THEN 'Portable Bluetooth Speaker'
        WHEN 3  THEN 'Smart Watch Fitness Band'
        WHEN 4  THEN 'USB-C 7-in-1 Hub'
        WHEN 5  THEN 'Portable Power Bank 20000mAh'
        WHEN 6  THEN 'LED Desk Lamp RGB'
        WHEN 7  THEN 'HD Webcam 1080p'
        WHEN 8  THEN 'Mechanical Gaming Keyboard'
        WHEN 9  THEN 'Wireless Ergonomic Mouse'
        WHEN 10 THEN 'HDMI 2.1 Cable 2m'
        WHEN 11 THEN 'Adjustable Phone Stand'
        WHEN 12 THEN 'Tablet Protective Case'
        WHEN 13 THEN 'Smart Plug Wi-Fi'
        ELSE 'Electronics Item ' + CAST(r.rn AS VARCHAR)
    END

    WHEN 'Toys' THEN CASE r.rn
        WHEN 1  THEN 'Building Blocks 500pc Set'
        WHEN 2  THEN 'Remote Control Car'
        WHEN 3  THEN 'Jigsaw Puzzle 500pc'
        WHEN 4  THEN 'Action Hero Figure Set'
        WHEN 5  THEN 'Classic Board Game'
        WHEN 6  THEN 'Plush Teddy Bear'
        WHEN 7  THEN 'Kids Learning Tablet'
        WHEN 8  THEN 'DIY Craft Kit'
        WHEN 9  THEN 'Foam Dart Blaster'
        WHEN 10 THEN 'Fashion Doll Playset'
        WHEN 11 THEN 'Card Game Pack'
        WHEN 12 THEN 'Wooden Train Set'
        WHEN 13 THEN 'Outdoor Flying Disc'
        ELSE 'Toy Item ' + CAST(r.rn AS VARCHAR)
    END

    ELSE product_id
END
FROM dw.dim_product p
JOIN ranked r ON p.product_key = r.product_key;
GO

-- Verificacion
SELECT product_key, product_id, category, product_name FROM dw.dim_product ORDER BY category, product_key;
SELECT store_key, store_id, region, store_name FROM dw.dim_store ORDER BY store_key;
GO
