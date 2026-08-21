-- .read 07_CREATE_COMPANY_MART.sql
-- STEP 7: MART - CREATE COMPANY MART
DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;

-- STEP 1: CREATE TABLE DIM_DATE_MONTH
SELECT '=== CREATE TABLE DIM_DATE_MONTH ===' AS info;
CREATE TABLE company_mart.dim_date_month (
    month_start_date           DATE PRIMARY KEY,
    year                       INTEGER,
    month                      INTEGER           
);

SELECT '=== LOADING DIM_DATE_MONTH TABLE ===' AS info;
INSERT INTO company_mart.dim_date_month(
    month_start_date,
    year,
    month
)
SELECT DISTINCT
    DATE_TRUNC ('month', job_posted_date) AS month_start_date,
    EXTRACT (YEAR FROM job_posted_date) AS year,
    EXTRACT (MONTH FROM job_posted_date) AS month
FROM job_postings_fact 
ORDER BY month_start_date;


-- STEP 2: CREATE TABLE DIM_LOCATION
SELECT '=== CREATE TABLE DIM_LOCATION ===' AS info;

CREATE TABLE company_mart.dim_location (
    location_id           INTEGER PRIMARY KEY,
    job_country           VARCHAR,
    job_location          VARCHAR          
);

SELECT '=== LOADING DIM_LOCATION TABLE ===' AS info;
INSERT INTO company_mart.dim_location (
    location_id,
    job_country,
    job_location
)
WITH prep AS(
    SELECT DISTINCT
        job_country,
        job_location
    FROM job_postings_fact
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY job_location) AS location_id,
    job_country,
    job_location
FROM prep;


-- STEP 3: CREATE TABLE DIM_COMPANY
SELECT '=== CREATE TABLE DIM_COMPANY ===' AS info;

CREATE TABLE company_mart.dim_company (
    company_id            INTEGER   PRIMARY KEY,
    company_name          VARCHAR       
);

SELECT '=== LOADING DIM_COMPANY TABLE ===' AS info;
INSERT INTO company_mart.dim_company (
    company_id,
    company_name
)
SELECT 
    company_id,
    name AS company_name 
FROM company_dim;


-- STEP 4: CREATE TABLE BRIDGE_COMPANY_LOCATION
SELECT '=== CREATE TABLE BRIDGE_COMPANY_LOCATION ===' AS info;

CREATE TABLE company_mart.bridge_company_location (
    company_id             INTEGER,
    location_id            INTEGER, 
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id)  REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id),
);

SELECT '=== LOADING DIM_COMPANY TABLE ===' AS info;
INSERT INTO company_mart.bridge_company_location (
    company_id,
    location_id
)
SELECT DISTINCT
    jpf.company_id,
    dl.location_id
FROM job_postings_fact AS jpf
INNER JOIN company_mart.dim_location AS dl
    ON jpf.job_country = dl.job_country AND jpf.job_location = dl.job_location;

-- STEP 5: CREATE TABLE DIM_JOB_TITLE_SHORT
SELECT '=== CREATE TABLE DIM_JOB_TITLE_SHORT ===' AS info;

CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id              INTEGER     PRIMARY KEY,
    job_title_short                 VARCHAR, 
    
);

SELECT '=== LOADING DIM_JOB_TITLE_SHORT ===' AS info;
INSERT INTO company_mart.dim_job_title_short (
    job_title_short_id,
    job_title_short
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY job_title_short) AS job_title_short_id,
    job_title_short
FROM    
    job_postings_fact
GROUP BY job_title_short;

-- STEP 6: CREATE TABLE DIM_JOB_TITLE
SELECT '=== CREATE TABLE DIM_JOB_TITLE ===' AS info;

CREATE TABLE company_mart.dim_job_title (
    job_title_id              INTEGER     PRIMARY KEY,
    job_title                 VARCHAR, 
    
);

SELECT '=== LOADING DIM_JOB_TITLE_SHORT ===' AS info;
INSERT INTO company_mart.dim_job_title(
    job_title_id,
    job_title
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY job_title) AS job_title_id,
    job_title
FROM    
    job_postings_fact
GROUP BY job_title;

-- STEP 7: CREATE TABLE BRIDGE_JOB_TITLE
SELECT '=== CREATE TABLE BRIDGE_JOB_TITLE ===' AS info;

CREATE TABLE company_mart.bridge_job_title (
    job_title_short_id              INTEGER,
    job_title_id                    INTEGER, 
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id)    REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id)          REFERENCES company_mart.dim_job_title (job_title_id),
);

SELECT '=== LOADING BRIDGE_JOB_TITLE TABLE ===' AS info;
INSERT INTO company_mart.bridge_job_title(
    job_title_short_id,
    job_title_id
)
SELECT DISTINCT
    djts.job_title_short_id,
    djt.job_title_id
FROM job_postings_fact AS jpf
INNER JOIN company_mart.dim_job_title_short AS djts
    ON jpf.job_title_short = djts.job_title_short 
INNER JOIN company_mart.dim_job_title AS djt
    ON jpf.job_title = djt.job_title;

-- Grain: company_id + job_title_short_id + job_country + posted_month
CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id INTEGER,
    job_title_short_id INTEGER,
    job_country VARCHAR,
    month_start_date DATE,
    postings_count INTEGER,
    median_salary_year DOUBLE,
    min_salary_year DOUBLE,
    max_salary_year DOUBLE,
    remote_share DOUBLE,
    health_insurance_share DOUBLE,
    no_degree_mention_share DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, job_country, month_start_date),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)
);

INSERT INTO company_mart.fact_company_hiring_monthly (
    company_id,
    job_title_short_id,
    job_country,
    month_start_date,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
)
WITH job_postings_prepared AS (
    SELECT
        jpf.company_id,
        djs.job_title_short_id,
        jpf.job_country,
        DATE_TRUNC('month', jpf.job_posted_date)::DATE AS month_start_date,
        jpf.salary_year_avg,
        -- Convert boolean flags to numeric values (1.0 or 0.0)
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1.0 ELSE 0.0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1.0 ELSE 0.0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1.0 ELSE 0.0 END AS no_degree_required
    FROM
        job_postings_fact jpf
    INNER JOIN company_mart.dim_job_title_short djs 
        ON jpf.job_title_short = djs.job_title_short
    WHERE
        jpf.company_id IS NOT NULL
        AND jpf.job_posted_date IS NOT NULL
        AND jpf.job_country IS NOT NULL
)
SELECT
    company_id,
    job_title_short_id,
    job_country,
    month_start_date,

    COUNT(*) AS postings_count,

    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,

    -- ratio of remote-friendly postings in this group (0-1)
    AVG(is_remote) AS remote_share,

    -- ratio of postings that mention health insurance
    AVG(has_health_insurance) AS health_insurance_share,

    -- ratio of postings where "no degree mentioned" is flagged
    AVG(no_degree_required) AS no_degree_mention_share

FROM
    job_postings_prepared
GROUP BY
    company_id,
    job_title_short_id,
    job_country,
    month_start_date;

SELECT '=== Company Hiring Fact Sample ===' AS info;
SELECT 
    fchm.company_id,
   -- dc.company_name,
    djs.job_title_short,
    fchm.job_country,
    fchm.month_start_date,
    fchm.postings_count,
    fchm.median_salary_year AS me_salary,
    fchm.remote_share,
    fchm.health_insurance_share AS health_share,
    fchm.no_degree_mention_share AS degree_share,
    fchm.min_salary_year AS min_salary,
    fchm.max_salary_year AS max_salary
FROM company_mart.fact_company_hiring_monthly fchm
JOIN company_mart.dim_company dc ON fchm.company_id = dc.company_id
JOIN company_mart.dim_job_title_short djs ON fchm.job_title_short_id = djs.job_title_short_id
ORDER BY fchm.postings_count DESC, fchm.median_salary_year DESC;