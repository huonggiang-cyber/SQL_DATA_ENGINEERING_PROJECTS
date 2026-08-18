SELECT 
    job_posted_date,
    job_posted_date :: DATE AS date,
    job_posted_date :: TIME AS time,
    job_posted_date :: TIMESTAMP AS timestamp,
    job_posted_date :: TIMESTAMPTZ AS timestamptz
FROM job_postings_fact
LIMIT 10;

SELECT 
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY 
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
ORDER BY job_count DESC;

SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE 
    job_title_short = 'Data Engineer' AND
    EXTRACT(YEAR FROM job_posted_date) = 2025
GROUP BY
    DATE_TRUNC('month', job_posted_date)
ORDER BY 
    job_posted_month;


SELECT
    '2026-01-01 00:00:00+00'::TIMESTAMPTZ AT TIME ZONE 'CST';


