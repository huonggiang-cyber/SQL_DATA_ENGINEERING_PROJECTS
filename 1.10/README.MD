# TIÊU ĐỀ CHUNG

## TIÊU ĐỀ VỪA

### TIÊU ĐỀ NHỎ

*BIN THỐI IN NGHIÊNG*

**BIN THỐI IN ĐẬM**

- Ý 1
- Ý 2

CỘT `BIN THỐI`

1. [`Data_modeling.sql`](./Data_modeling.sql) - demand analysis

2. [`Data_modeling.sql`](README.MD) - read this before go

if you are bin, you are welcome!

3. ![project 1](image.png)


``` sql
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    company_id
FROM    
    job_postings_fact
LIMIT 10;

SELECT  
    company_id,
    name
FROM
    company_dim
LIMIT 10;

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_catalog = 'data_jobs';

DESCRIBE job_postings_fact;pw
```