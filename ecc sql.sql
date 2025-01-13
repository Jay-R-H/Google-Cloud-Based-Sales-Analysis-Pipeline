
--Data Analysis

-- Top 5 Most Discounted Products
SELECT  ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 3), ' ') AS short_name, discount_percentage FROM `ecc-project-441804.cleaned_amazon_data.amazon` ORDER BY discount_percentage DESC  LIMIT 5;

-- Products with Ratings Above 4 and More than 500 Reviews

SELECT ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 3), ' ') AS short_name,ratings, no_of_ratings  FROM  `ecc-project-441804.cleaned_amazon_data.amazon`  WHERE ratings > 4 AND no_of_ratings > 500;

-- Average Price of Products by Main Category
SELECT main_category, AVG(actual_price) AS avg_price  FROM `ecc-project-441804.cleaned_amazon_data.amazon`  GROUP BY main_category  ORDER BY avg_price DESC;

-- Brands Offering Maximum Discount Percentage
SELECT ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 1), ' ') AS brand, MAX(discount_percentage) AS max_discount  FROM `ecc-project-441804.cleaned_amazon_data.amazon`  GROUP BY brand ORDER BY max_discount DESC;


-- Number of Products From Each Main Category
SELECT 
main_category, 
COUNT(*) AS total_products 
FROM `ecc-project-441804.cleaned_amazon_data.amazon` 
GROUP BY main_category 
ORDER BY total_products DESC;


-- Average Rating for Each Sub-Category
SELECT 
sub_category, 
AVG(ratings) AS avg_ratings 
FROM `ecc-project-441804.cleaned_amazon_data.amazon` 
GROUP BY sub_category 
ORDER BY avg_ratings DESC;


-- Top 3 Cheapest Products in Each Main Category
WITH ranked_data AS (
SELECT 
main_category, 
ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 3), ' ') AS short_name, 
discount_price,
ROW_NUMBER() OVER (PARTITION BY main_category ORDER BY discount_price ASC) AS rank
FROM `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE discount_price > 0
)
SELECT 
main_category, 
short_name, 
discount_price
FROM ranked_data
WHERE rank <= 3
ORDER BY main_category, discount_price ASC;




-- Total Revenue if All Products Were Sold at Discount Price
SELECT 
SUM(discount_price) AS total_revenue 
FROM `ecc-project-441804.cleaned_amazon_data.amazon`;


-- Products with No Reviews But High Ratings
SELECT 
ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 3), ' ') AS short_name, 
ratings 
FROM `ecc-project-441804.cleaned_amazon_data.amazon` 
WHERE no_of_ratings = 0 AND ratings > 4 ORDER BY ratings asc;



WITH ranked_products AS (
SELECT 
ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 3), ' ') AS short_name, 
ratings,
no_of_ratings, 
main_category,
ROW_NUMBER() OVER (PARTITION BY main_category ORDER BY ratings DESC, no_of_ratings ASC) AS rank
FROM `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE no_of_ratings > 0 AND ratings > 4
)
SELECT 
short_name, 
ratings, 
main_category
FROM ranked_products
WHERE rank = 1
ORDER BY main_category;

-- To find max rating per category
WITH distinct_ratings AS (
SELECT 
ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 3), ' ') AS short_name, 
ratings, 
main_category
FROM `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE no_of_ratings = 0 AND ratings > 4
GROUP BY main_category, ratings, short_name
),
ranked_products AS (
SELECT 
short_name, 
ratings, 
main_category, 
ROW_NUMBER() OVER (PARTITION BY main_category ORDER BY ratings ASC) AS rank
FROM distinct_ratings
)
SELECT 
short_name, 
ratings, 
main_category
FROM ranked_products
WHERE rank = 1
ORDER BY main_category
LIMIT 5;

-- Total Number of Products by Brand
SELECT 
ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 1), ' ') AS brand, 
COUNT(*) AS total_products 
FROM `ecc-project-441804.cleaned_amazon_data.amazon` 
GROUP BY brand 
ORDER BY total_products DESC;


-- Top 5 Brands with Highest Average Ratings
SELECT 
ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(name, ' '), 0, 1), ' ') AS brand, 
AVG(ratings) AS avg_ratings 
FROM `ecc-project-441804.cleaned_amazon_data.amazon` 
WHERE ratings > 0 
GROUP BY brand 
ORDER BY avg_ratings DESC 
LIMIT 5;


-- Product Count for Each Sub-Category
SELECT 
sub_category, 
COUNT(*) AS product_count 
FROM `ecc-project-441804.cleaned_amazon_data.amazon` 
GROUP BY sub_category 
ORDER BY product_count DESC;


-- Average Discount Percentage by Rating Range:
SELECT
    CASE
        WHEN ratings >= 4.5 THEN '4.5 and above'
        WHEN ratings >= 4.0 THEN '4.0 to 4.4'
        WHEN ratings >= 3.5 THEN '3.5 to 3.9'
        ELSE 'Below 3.5'
    END AS rating_range,
    AVG(discount_percentage) AS avg_discount_percentage
FROM
    `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE
    discount_percentage IS NOT NULL AND ratings IS NOT NULL
GROUP BY
    rating_range
ORDER BY
    rating_range;
	
-- Discount Percentage Distribution by Rating Group:
SELECT
    CASE
        WHEN ratings >= 4.5 THEN '4.5 and above'
        WHEN ratings >= 4.0 THEN '4.0 to 4.4'
        WHEN ratings >= 3.5 THEN '3.5 to 3.9'
        ELSE 'Below 3.5'
    END AS rating_group,
    discount_percentage
FROM
    `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE
    discount_percentage IS NOT NULL AND ratings IS NOT NULL;

-- Count of Products by Discount Range and Ratings:
SELECT
    CASE
        WHEN discount_percentage <= 5 THEN '0-5%'
        WHEN discount_percentage <= 10 THEN '5-10%'
        WHEN discount_percentage <= 20 THEN '10-20%'
        WHEN discount_percentage <= 50 THEN '20-50%'
        ELSE '50% and above'
    END AS discount_range,
    CASE
        WHEN ratings >= 4.5 THEN '4.5 and above'
        WHEN ratings >= 4.0 THEN '4.0 to 4.4'
        WHEN ratings >= 3.5 THEN '3.5 to 3.9'
        ELSE 'Below 3.5'
    END AS rating_group,
    COUNT(*) AS product_count
FROM
    `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE
    discount_percentage IS NOT NULL AND ratings IS NOT NULL
GROUP BY
    discount_range, rating_group
ORDER BY
    discount_range, rating_group;

-- Average Rating by Discount Percentage Range:
SELECT
    CASE
        WHEN discount_percentage <= 5 THEN '0-5%'
        WHEN discount_percentage <= 10 THEN '5-10%'
        WHEN discount_percentage <= 20 THEN '10-20%'
        WHEN discount_percentage <= 50 THEN '20-50%'
        ELSE '50% and above'
    END AS discount_range,
    AVG(ratings) AS avg_ratings
FROM
    `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE
    discount_percentage IS NOT NULL AND ratings IS NOT NULL
GROUP BY
    discount_range
ORDER BY
    discount_range;


-- Top Products by Rating and Discount Percentage:
SELECT
    name,
    ratings,
    discount_percentage
FROM
    `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE
    discount_percentage > 20 AND ratings >= 4
ORDER BY
    ratings DESC, discount_percentage DESC
LIMIT 10;

-- Discount and Ratings by Product Category:
SELECT
    category,
    AVG(discount_percentage) AS avg_discount_percentage,
    AVG(ratings) AS avg_ratings
FROM
    `ecc-project-441804.cleaned_amazon_data.amazon`
WHERE
    discount_percentage IS NOT NULL AND ratings IS NOT NULL
GROUP BY
    category
ORDER BY
    avg_discount_percentage DESC;


-- Impact of Discount Percentage on No. of Ratings:
SELECT discount_percentage, AVG(no_of_ratings) AS avg_ratings_count
FROM `ecc-project-441804.cleaned_amazon_data.amazon`
GROUP BY discount_percentage
ORDER BY discount_percentage;


