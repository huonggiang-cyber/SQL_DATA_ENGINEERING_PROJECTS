SELECT[1, 2, 3];

SELECT ['apple', 'banana', 'tomato'];


WITH skills AS(
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
)
SELECT ARRAY_AGG(skill) AS skills_array
FROM skills;

WITH skills AS(
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
), skills_array AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skills
    FROM skills
)
SELECT 
    skills[1] AS first_skill,
    skills[2] AS second_skill,
    skills[3] AS third_skill
FROM skills_array;

-- STRUCT
SELECT {skill: 'python', type: 'programming'} AS skill_struct;

SELECT 
    STRUCT_PACK(
        skill := 'python',
        type := 'programming'
    ) AS s;

WITH skill_table AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)
SELECT 
    STRUCT_PACK(
        skill := skills,
        type := types
    )
FROM skill_table;

-- array of structs
SELECT [
    {skill: 'python', type: 'programming'},
    {skill: 'sql', type: 'query_language'}
] AS skills_array_of_structs;

WITH skill_table AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS (
    SELECT 
        ARRAY_AGG(
            STRUCT_PACK(
                skill := skills,
                type := types
            )
        ) AS array_struct
    FROM skill_table
)
SELECT
    array_struct[1].skill,
    array_struct[2].type,
    array_struct[3]
FROM skills_array_struct;

-- json to struct
WITH raw_skill_json AS (
    SELECT '{"skill":"python", "type": "programming"}' :: JSON AS skill_json
)
SELECT
    STRUCT_PACK(
        skill := json_extract_string(skill_json, '$.skill'),
        type := json_extract_string(skill_json, '$.type')
    )
FROM raw_skill_json;

-- json to array of struct
WITH raw_json AS(
    SELECT
        '[
        {"skill":"python", "type": "programming"},
        {"skill":"r", "type": "programming"},
        {"skill":"sql", "type": "query"}
        ]':: JSON AS skills_json
)
SELECT 
    ARRAY_AGG(
        STRUCT_PACK(
        skill := json_extract_string(e.value, '$.skill'),
        type := json_extract_string(e.value, '$.type')
    )
    ORDER BY json_extract_string(e.value, '$.skill')
    ) AS skill
FROM raw_json, json_each(skills_json) AS e;


-- FINAL
CREATE OR REPLACE TEMP TABLE job_skill_array AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS sd_array
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL
;
SELECT * FROM job_skill_array;

--analyze the median salary per skill
WITH flat_skills AS(   
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(sd_array) AS skill
    FROM
        job_skill_array 
    WHERE salary_year_avg IS NOT NULL
)
SELECT
    skill,
    MEDIAN(salary_year_avg) AS median_hour_salary
FROM flat_skills
GROUP BY skill
ORDER BY median_hour_salary DESC;

-- ARRAY OF STRUCT
CREATE OR REPLACE TEMP TABLE job_array_struct AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_type := sd.type,
            skill_name := sd.skills
        )
    ) AS skill_type
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL;


WITH types_skill AS(
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skill_type).skill_type AS type_of_skill
    FROM job_array_struct
)
SELECT
    type_of_skill,
    MEDIAN(salary_year_avg) AS median_type_salary
FROM types_skill
GROUP BY type_of_skill
ORDER BY median_type_salary DESC;