-- BUCKET SALARIES
-- <25 = 'LOW'
-- 25-50 = 'MEDIUM'
-- > 50 = 'HIGH'

SELECT 
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
LIMIT 10;

-- Handing Missing Data (NUll)
-- Filter NULL salary values
SELECT 
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg IS NULL THEN 'Missing'
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
LIMIT 10;


-- Categorizing / classify the 'job_title'
SELECT 
    job_title,
    CASE
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Analyst%' THEN 'Data Anlyst'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 20;

-- Conditional Aggregation
-- Calculate Median Salaries for diff buckets
--  < $100k
-- >= $100k

SELECT 
    job_title_short,
    COUNT(*) AS total_postings,
    MEDIAN(
        CASE 
            WHEN salary_year_avg < 100_000 THEN salary_year_avg
        END
    ) AS median_low_salary,
    MEDIAN(
        CASE 
            WHEN salary_year_avg >= 100_000 THEN salary_year_avg
        END
    ) AS median_high_salary,
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short;

-- FINAL: CONDITIONAL CALCULATIONS
-- < 75K 'LOW'
-- 75K - 100K 'MEDIUM'
-- >= 150K 'HIGH'

WITH salaries AS (
    SELECT
        job_title_short,
        salary_hour_avg,
        salary_year_avg,
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg*2080
            ELSE NULL
        END AS standardized_salary
        FROM 
            job_postings_fact
        WHERE salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
)

SELECT 
    *, 
    CASE
        WHEN standardized_salary IS NULL THEN 'Missing'
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Median'
        ELSE 'High'
    END AS salary_avg_categoty
FROM salaries
ORDER BY RANDOM()
LIMIT 50;
