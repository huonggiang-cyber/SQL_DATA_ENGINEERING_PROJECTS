-- Step 2: load data from csv into tables

SELECT '=== LOADING COMPANY_DIM TABLE ===' AS info;

INSERT INTO company_dim (company_id, name)
SELECT company_id, name
FROM read_csv('https://storage.googleapis.com/sql_de/company_dim.csv',
    AUTO_DETECT = TRUE);


SELECT '=== LOADING SKILL_DIM TABLE ===' AS info;

INSERT INTO skill_dim (skill_id, skills, type)
SELECT skill_id, skills, type
FROM read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv',
    AUTO_DETECT = TRUE);

SELECT '=== LOADING JOB_POSTINGS_FACT TABLE ===' AS info;

INSERT INTO job_postings_fact (
    job_id, company_id, job_title_short, job_title, job_location,
    job_via, job_schedule_type, job_work_from_home, search_location,
    job_posted_date, job_no_degree_mention, job_health_insurance,
    job_country, salary_rate, salary_year_avg, salary_hour_avg
)
SELECT 
    job_id, company_id, job_title_short, job_title, job_location,
    job_via, job_schedule_type, job_work_from_home, search_location,
    job_posted_date, job_no_degree_mention, job_health_insurance,
    job_country, salary_rate, salary_year_avg, salary_hour_avg
FROM read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv',
    AUTO_DETECT = TRUE);


SELECT '=== LOADING SKILL_JOB_DIM TABLE ===' AS info;

INSERT INTO skill_job_dim (skill_id, job_id)
SELECT skill_id, job_id
FROM read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv',
    AUTO_DETECT = TRUE);

SELECT 'Company Dim' AS table_name, COUNT(*) AS record_count FROM company_dim
UNION ALL
SELECT 'Skills Dim', COUNT(*) FROM skill_dim
UNION ALL
SELECT 'Job Postings Fact', COUNT(*) FROM job_postings_fact
UNION ALL
SELECT 'Skill Job Dim', COUNT(*) FROM skill_job_dim;

SELECT '=== COMPANY DIMENSION SAMPLE ===' AS info;
SELECT * FROM company_dim LIMIT 5;

SELECT '=== SKILL DIMENSION SAMPLE ===' AS info;
SELECT * FROM skill_dim LIMIT 5;

SELECT '=== Job posting fact SAMPLE ===' AS info;
SELECT * FROM job_postings_fact LIMIT 5;

SELECT '=== Skill Job Bridge SAMPLE ===' AS info;
SELECT * FROM skill_job_dim LIMIT 5;

