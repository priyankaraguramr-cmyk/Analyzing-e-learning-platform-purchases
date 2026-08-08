-- ============================================================================
-- MODULE END ASSIGNMENT: Analyzing E-Learning Platform Purchases using MySQL
-- ============================================================================

-- SECTION 1: DATABASE SETUP & DATA ENTRY

DROP DATABASE IF EXISTS elearning_platform;
CREATE DATABASE elearning_platform;
USE elearning_platform;

-- ---------------------------------------------------------------------------
-- Table: learners
-- ---------------------------------------------------------------------------
CREATE TABLE learners (
    learner_id  INT PRIMARY KEY AUTO_INCREMENT,
    full_name   VARCHAR(100) NOT NULL,
    country     VARCHAR(50)  NOT NULL
);

-- ---------------------------------------------------------------------------
-- Table: courses
-- ---------------------------------------------------------------------------
CREATE TABLE courses (
    course_id   INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100)   NOT NULL,
    category    VARCHAR(50)    NOT NULL,
    unit_price  DECIMAL(10,2)  NOT NULL
);

-- ---------------------------------------------------------------------------
-- Table: purchases
-- ---------------------------------------------------------------------------
CREATE TABLE purchases (
    purchase_id   INT PRIMARY KEY AUTO_INCREMENT,
    learner_id    INT NOT NULL,
    course_id     INT NOT NULL,
    quantity      INT NOT NULL,
    purchase_date DATE NOT NULL,
    CONSTRAINT fk_purchases_learner FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    CONSTRAINT fk_purchases_course  FOREIGN KEY (course_id)  REFERENCES courses(course_id)
);

-- ---------------------------------------------------------------------------
-- Sample Data: learners (5)
-- ---------------------------------------------------------------------------
INSERT INTO learners (full_name, country) VALUES
    ('Alice Johnson', 'USA'),
    ('Rahul Mehta',   'India'),
    ('Sophia Rossi',  'Italy'),
    ('Kenji Sato',    'Japan'),
    ('Maria Garcia',  'USA');

-- ---------------------------------------------------------------------------
-- Sample Data: courses (6, across 5 categories; one course is never purchased)
-- ---------------------------------------------------------------------------
INSERT INTO courses (course_name, category, unit_price) VALUES
    ('Python for Beginners',        'Beginner',        999.00),
    ('Advanced Data Science',       'Data Science',    4999.00),
    ('Digital Marketing Basics',    'Marketing',       2499.00),
    ('Full Stack Web Development',  'Web Development', 5999.00),
    ('Excel Fundamentals',          'Beginner',         799.00),
    ('UX Design Basics',            'Design',          3499.00);

-- ---------------------------------------------------------------------------
-- Sample Data: purchases (8)
-- ---------------------------------------------------------------------------
INSERT INTO purchases (learner_id, course_id, quantity, purchase_date) VALUES
    (1, 1, 3, '2026-01-05'),  -- Alice  - Python for Beginners
    (1, 4, 1, '2026-02-10'),  -- Alice  - Full Stack Web Development
    (2, 2, 2, '2026-01-15'),  -- Rahul  - Advanced Data Science
    (2, 3, 2, '2026-03-01'),  -- Rahul  - Digital Marketing Basics
    (3, 1, 1, '2026-01-20'),  -- Sophia - Python for Beginners
    (4, 4, 2, '2026-02-25'),  -- Kenji  - Full Stack Web Development
    (4, 2, 1, '2026-03-10'),  -- Kenji  - Advanced Data Science
    (5, 5, 3, '2026-01-30');  -- Maria  - Excel Fundamentals
    -- Note: course_id 6 (UX Design Basics) is intentionally never purchased


-- ============================================================================
-- SECTION 2: DATA EXPLORATION USING JOINS
-- ============================================================================

-- INNER JOIN: only purchases that have a matching learner and course
SELECT
    l.full_name                              AS learner_name,
    c.course_name                            AS course_name,
    c.category                               AS category,
    p.quantity                               AS quantity,
    FORMAT(p.quantity * c.unit_price, 2)     AS total_amount,
    p.purchase_date                          AS purchase_date
FROM purchases p
INNER JOIN learners l ON p.learner_id = l.learner_id
INNER JOIN courses  c ON p.course_id  = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- LEFT JOIN: all learners, including any with no purchases (none in this sample, but query is NULL-safe)
SELECT
    l.full_name                                          AS learner_name,
    c.course_name                                        AS course_name,
    c.category                                           AS category,
    p.quantity                                           AS quantity,
    FORMAT(IFNULL(p.quantity * c.unit_price, 0), 2)      AS total_amount,
    p.purchase_date                                      AS purchase_date
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses   c ON p.course_id  = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- RIGHT JOIN: all courses, including any never purchased (surfaces UX Design Basics)
SELECT
    l.full_name                                          AS learner_name,
    c.course_name                                        AS course_name,
    c.category                                           AS category,
    p.quantity                                           AS quantity,
    FORMAT(IFNULL(p.quantity * c.unit_price, 0), 2)      AS total_amount,
    p.purchase_date                                      AS purchase_date
FROM purchases p
RIGHT JOIN courses  c ON p.course_id  = c.course_id
LEFT JOIN  learners l ON p.learner_id = l.learner_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- ============================================================================
-- SECTION 3: CORE ANALYTICAL QUERIES ===============================================================

-- Q1. Each learner's total spending with their country
SELECT
    l.full_name                                 AS learner_name,
    l.country                                   AS country,
    FORMAT(SUM(p.quantity * c.unit_price), 2)   AS total_spending
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses   c ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- Q2. Top 3 most purchased courses by quantity
SELECT
    c.course_name         AS course_name,
    c.category             AS category,
    SUM(p.quantity)         AS total_quantity_sold
FROM courses c
JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name, c.category
ORDER BY total_quantity_sold DESC, c.course_name ASC
LIMIT 3;

-- Q3. Each category's total revenue and number of unique learners
SELECT
    c.category                                   AS category,
    FORMAT(SUM(p.quantity * c.unit_price), 2)    AS total_revenue,
    COUNT(DISTINCT p.learner_id)                 AS unique_learners
FROM courses c
JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.category
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- Q4. Learners who purchased from more than one category
SELECT
    l.full_name                     AS learner_name,
    COUNT(DISTINCT c.category)      AS categories_purchased
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses   c ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING COUNT(DISTINCT c.category) > 1
ORDER BY categories_purchased DESC;

-- Q5. Courses never purchased
SELECT
    c.course_name   AS course_name,
    c.category      AS category
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL;

-- ============================================================================
-- SECTION 4: SUBQUERIES & CORRELATED SUBQUERIES (Q6-Q8)
-- ============================================================================

-- Q6. Learners whose total spending is above the average learner spending
SELECT
    learner_name,
    FORMAT(total_spending, 2) AS total_spending
FROM (
    SELECT
        l.full_name                        AS learner_name,
        SUM(p.quantity * c.unit_price)      AS total_spending
    FROM learners l
    JOIN purchases p ON l.learner_id = p.learner_id
    JOIN courses   c ON p.course_id  = c.course_id
    GROUP BY l.learner_id, l.full_name
) AS learner_totals
WHERE total_spending > (
    SELECT AVG(learner_total)
    FROM (
        SELECT SUM(p.quantity * c.unit_price) AS learner_total
        FROM purchases p
        JOIN courses c ON p.course_id = c.course_id
        GROUP BY p.learner_id
    ) AS avg_calc
)
ORDER BY total_spending DESC;

-- Q7. Courses whose price is higher than any course in the 'Beginner' category
SELECT
    course_name,
    category,
    FORMAT(unit_price, 2) AS unit_price
FROM courses
WHERE unit_price > ANY (
    SELECT unit_price FROM courses WHERE category = 'Beginner'
)
ORDER BY unit_price DESC;

-- Q8. Learners who spent more than the average spending in their own country (correlated subquery)
SELECT
    l.full_name AS learner_name,
    l.country   AS country,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_spending
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses   c ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
HAVING SUM(p.quantity * c.unit_price) > (
    SELECT AVG(country_total.spend)
    FROM (
        SELECT l2.learner_id, l2.country AS learner_country, SUM(p2.quantity * c2.unit_price) AS spend
        FROM learners l2
        JOIN purchases p2 ON l2.learner_id = p2.learner_id
        JOIN courses   c2 ON p2.course_id  = c2.course_id
        GROUP BY l2.learner_id, l2.country
    ) AS country_total
    WHERE country_total.learner_country = l.country
)
ORDER BY total_spending DESC;

-- ============================================================================
-- SECTION 5: CTE, CASE, VIEW, AND NULL HANDLING (Q9-Q12)
-- ============================================================================

-- Q9. CTE: total spending per learner, then filter learners spending above 10,000
WITH learner_spending AS (
    SELECT
        l.learner_id,
        l.full_name                          AS learner_name,
        SUM(p.quantity * c.unit_price)        AS total_spending
    FROM learners l
    JOIN purchases p ON l.learner_id = p.learner_id
    JOIN courses   c ON p.course_id  = c.course_id
    GROUP BY l.learner_id, l.full_name
)
SELECT
    learner_name,
    FORMAT(total_spending, 2) AS total_spending
FROM learner_spending
WHERE total_spending > 10000
ORDER BY total_spending DESC;

-- Q10. CASE: classify learners by spending tier
WITH learner_spending AS (
    SELECT
        l.full_name                          AS learner_name,
        SUM(p.quantity * c.unit_price)        AS total_spending
    FROM learners l
    JOIN purchases p ON l.learner_id = p.learner_id
    JOIN courses   c ON p.course_id  = c.course_id
    GROUP BY l.learner_id, l.full_name
)
SELECT
    learner_name,
    FORMAT(total_spending, 2) AS total_spending,
    CASE
        WHEN total_spending > 15000 THEN 'High Value'
        WHEN total_spending BETWEEN 8000 AND 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS spending_tier
FROM learner_spending
ORDER BY total_spending DESC;

-- Q11. NULL Handling: all courses, replacing NULL purchase counts with 0
SELECT
    c.course_name                              AS course_name,
    c.category                                 AS category,
    IFNULL(COUNT(p.purchase_id), 0)            AS purchase_count,
    COALESCE(SUM(p.quantity), 0)               AS total_quantity_sold
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name, c.category
ORDER BY purchase_count DESC;

-- Q12. VIEW: category_performance_view
CREATE OR REPLACE VIEW category_performance_view AS
SELECT
    c.category                                                        AS category,
    SUM(p.quantity * c.unit_price)                                     AS total_revenue,
    COUNT(p.purchase_id)                                               AS number_of_purchases,
    ROUND(SUM(p.quantity * c.unit_price) / COUNT(p.purchase_id), 2)    AS avg_revenue_per_purchase
FROM courses c
JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.category;

-- Query the view
SELECT
    category,
    FORMAT(total_revenue, 2)            AS total_revenue,
    number_of_purchases,
    FORMAT(avg_revenue_per_purchase, 2) AS avg_revenue_per_purchase
FROM category_performance_view
ORDER BY total_revenue DESC;
