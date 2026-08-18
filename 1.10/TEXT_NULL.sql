SELECT LENGTH('SQL');

SELECT CHAR_LENGTH('SQL');

SELECT UPPER('Sql');

SELECT LOWER('SQL');

SELECT LEFT('SQL', 2);

SELECT RIGHT('SQL', 1);

SELECT SUBSTRING('SQL', 2, 1);

SELECT CONCAT('SQL', '-', 'FUNCTIONS');

SELECT 'SQL' || '-' || 'Functions';

SELECT TRIM('          SQL ');

SELECT REPLACE('SQL', 'Q', '+');

--FINAL
SELECT 
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg*2080) 
FROM
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;


SELECT 
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg*2080) AS standardized_salary, 
    CASE
        WHEN COALESCE(salary_year_avg, salary_hour_avg*2080) IS NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg, salary_hour_avg*2080) < 75_000 THEN 'Low'
        WHEN COALESCE(salary_year_avg, salary_hour_avg*2080) < 150_000 THEN 'Median'
        ELSE 'High'
    END AS salary_avg_categoty
FROM job_postings_fact
ORDER BY standardized_salary DESC;

