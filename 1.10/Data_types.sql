SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name='job_postings_fact';

DESCRIBE 
SELECT
    job_title_short,
    salary_year_avg
FROM
job_postings_fact;

SELECT CAST(123 AS VARCHAR);

SELECT 
    CAST(job_id AS VARCHAR) || '-' || CAST(company_id AS VARCHAR) AS job_id_company,
    CAST(job_work_from_home AS INT) AS job_work_from_home,
    CAST(job_posted_date AS DATE) AS job_posted_date,
    CAST(salary_year_avg AS DECIMAL (10,0)) AS salary
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

SELECT (3 + 5.5)::INT;