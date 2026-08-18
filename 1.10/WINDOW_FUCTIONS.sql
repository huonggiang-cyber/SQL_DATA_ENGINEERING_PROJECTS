-- count rows - aggregation only
SELECT
    COUNT(*)
FROM
    job_postings_fact;


-- count rows - WINDOW only
SELECT
    job_id,
    COUNT(*) OVER ()
FROM
    job_postings_fact;

SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
    )
FROM
    job_postings_fact
ORDER BY
    RANDOM()
LIMIT 40;

-- PARTITION BY
SELECT
    job_id,
    job_title_short,
    company_id,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short,company_id 
    )AS median_hour_salary
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY
    RANDOM()
LIMIT 40;

-- order by create rank column
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    )AS rank_hour_salary
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC
LIMIT 40;

-- PARTITON BY & ORDER BY - rank by salary
SELECT
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    )AS running_avg_hour_title
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL AND
    job_title_short = 'Data Engineer'
ORDER BY
    job_title_short,
    job_posted_date;

-- PARTITON BY & ORDER BY - rank by job title
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    SUM(salary_hour_avg)  OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date 
    )AS rank_hour_salary
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL AND
    job_title_short = 'Data Engineer'
ORDER BY
    job_title_short,
    job_posted_date DESC
;

-- Ranking func - RANK() DENSE_RANK()
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK_DENSE() OVER (
        ORDER BY salary_hour_avg DESC
    )AS rank_hour_salary
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC
LIMIT 140;

-- LAG - Time based comparison of company yearly salary
SELECT
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_posting_salary
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER by company_id, job_posted_date
LIMIT 60;


SELECT
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_posting_salary,
    salary_year_avg - LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS salary_change
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER by company_id, job_posted_date
LIMIT 60;

SELECT
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_posting_salary,
    salary_year_avg - LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS salary_change
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER by company_id, job_posted_date
LIMIT 60;
