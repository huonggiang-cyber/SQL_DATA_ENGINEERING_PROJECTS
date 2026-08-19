
--duckdb dw_marts.duckdb -c ".read BUILD_DW_MARTS.sql"  

--STEP 1: DW- create star schema
.read 01_CREAT_TABLES_DW.sql

--STEP 2: DW_LOAD DATA FROM CSV FILES INTO TABLE
.read 02_LOAD_SCHEMA_DW.sql