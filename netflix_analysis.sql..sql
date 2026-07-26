-- ============================================
-- PROJECT  : Netflix Content Analysis
-- AUTHOR   : Srishti Dass
-- TOOL     : MySQL (Netflix dataset Project)

USE netflix_project;

select * from netflix_titles;


-- PHASE 1: DATA CLEANING

select * from netflix_titles
where type = "TV show";

SELECT * FROM netflix_titles
WHERE type = 'Movie' AND country = 'India';

SELECT * FROM netflix_titles
WHERE release_year > 2004;

SELECT COUNT(*) FROM netflix_titles
WHERE director is NULL;

-- NULLIF replaces empty string with proper NULL value

UPDATE netflix_titles
SET
  director = NULLIF(director, ''),
  cast     = NULLIF(cast, ''),
  country  = NULLIF(country, ''),
  rating   = NULLIF(rating, ''),
  date_added = NULLIF(date_added, '');


-- to check for duplicate titles for data cleaning and count the number of rows 
-- we might remove if they are identical in all aspects but if diifrent info are there depends
SELECT title, COUNT(*) AS count
FROM netflix_titles
GROUP BY title
HAVING count > 1;

-- Check distinct ratings
-- (spot any weird/incorrect values)
SELECT DISTINCT rating
FROM netflix_titles
ORDER BY rating;

-- Step 5: Check release year range of years dataset we are looking at 
-- (any unrealistic years?)

SELECT MIN(release_year), MAX(release_year)
FROM netflix_titles;


SELECT title, type, release_year, date_added
FROM netflix_titles
WHERE release_year < 1940
ORDER BY release_year;

-- counting the total no of titles released in the given years 
SELECT release_year,
       COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY release_year
ORDER BY total_titles DESC;

-- Make the show id your primary key as it's unique for every row 
DESCRIBE netflix_titles;



SELECT 
  COUNT(*) AS total_rows,
  COUNT(*) - COUNT(director)   AS null_director,
  COUNT(*) - COUNT(cast)       AS null_cast,
  COUNT(*) - COUNT(country)    AS null_country,
  COUNT(*) - COUNT(rating)     AS null_rating,
  COUNT(*) - COUNT(date_added) AS null_date_added
FROM netflix_titles;

-- Fill the moderate-null columns so rows aren't lost in aggregations
UPDATE netflix_titles SET director = 'Unknown' WHERE director IS NULL;
UPDATE netflix_titles SET cast     = 'Unknown' WHERE cast IS NULL;
UPDATE netflix_titles SET country  = 'Unknown' WHERE country IS NULL;

-- For rating/date_added, since it's tiny, either leave as-is or drop those rows
-- (dropping 4 + 10 rows out of 8,907 won't skew anything)
DELETE FROM netflix_titles WHERE rating IS NULL;
DELETE FROM netflix_titles WHERE date_added IS NULL;


SELECT COUNT(*) AS total_rows_after_cleaning FROM netflix_titles;

SELECT show_id, COUNT(*) AS times_appeared
FROM netflix_titles
GROUP BY show_id
HAVING COUNT(*) > 1;

SELECT title, type, release_year, COUNT(*) AS times_appeared
FROM netflix_titles
GROUP BY title, type, release_year
HAVING COUNT(*) > 1;


-- PHASE 2: the DATA EXPLORATORY neeed to be in the netflix titles and make it 

-- to check that how many types of genere ared there 
SELECT DISTINCT type
FROM netflix_titles;

SELECT type, COUNT(*) AS total
FROM netflix_titles
GROUP BY type;

SELECT type,
       COUNT(*) AS total,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM netflix_titles
GROUP BY type;


SELECT 
  show_id,
  TRIM(
    SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)
  ) AS genre
FROM netflix_titles
JOIN (
  SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
) AS numbers
  ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= n - 1;


SELECT genre, COUNT(*) AS total
FROM (
  SELECT 
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre
  FROM netflix_titles
  JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
  ) AS numbers
    ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= n - 1
) AS split_genres
GROUP BY genre
ORDER BY total DESC;




SELECT country, COUNT(*) AS total
FROM netflix_titles
GROUP BY country
ORDER BY total DESC
LIMIT 15;


SELECT country, COUNT(*) AS total
FROM (
  SELECT 
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS country
  FROM netflix_titles
  JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
  ) AS numbers
    ON CHAR_LENGTH(country) CHAR_LENGTH(REPLACE(country, ',', '')) >= n - 1
  WHERE country IS NOT NULL AND country != 'Unknown'
) AS split_country
GROUP BY country
ORDER BY total DESC
LIMIT 15;   

DESCRIBE netflix_titles;

SELECT date_added
FROM netflix_titles
LIMIT 10;

SELECT 
  YEAR(STR_TO_DATE(TRIM(date_added), '%M %d, %Y')) AS year_added,
  COUNT(*) AS titles_added
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY YEAR(STR_TO_DATE(TRIM(date_added), '%M %d, %Y'))
ORDER BY year_added;

SELECT MAX(STR_TO_DATE(TRIM(date_added), '%M %d, %Y')) AS latest_date_in_data
FROM netflix_titles;


SELECT YEAR(STR_TO_DATE(TRIM(date_added), '%M %d, %Y')) AS year_added,
       COUNT(*) AS titles_added
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added;


-- what age/maturity ratings dominate the catalog

SELECT rating, COUNT(*) AS total
FROM netflix_titles
GROUP BY rating
ORDER BY total DESC;


--  Most frequent directors — who has the most titles on Netflix

SELECT director, COUNT(*) AS total
FROM netflix_titles
WHERE director != 'Unknown'
GROUP BY director
ORDER BY total DESC
LIMIT 10;

-- Average movie duration — are movies getting longer or shorter over time (movies only, since TV shows use "seasons" not minutes)

SELECT release_year, ROUND(AVG(duration), 1) AS avg_duration_minutes
FROM netflix_titles
WHERE type = 'Movie'
GROUP BY release_year
ORDER BY release_year;


