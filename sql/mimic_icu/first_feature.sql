-- 心率表
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.heart_rate;
CREATE MATERIALIZED VIEW mimic_icu.heart_rate AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 220045) AS ce
	WHERE ce.rid = 1
);  

-- 血压收缩压
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.abp_systolic;
CREATE MATERIALIZED VIEW mimic_icu.abp_systolic AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 220050) AS ce
	WHERE ce.rid = 1
); 

-- 血压舒张压
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.abp_diastolic;
CREATE MATERIALIZED VIEW mimic_icu.abp_diastolic AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 220051) AS ce
	WHERE ce.rid = 1
); 

-- 体温
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.Temperature;
CREATE MATERIALIZED VIEW mimic_icu.Temperature AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 223762) AS ce
	WHERE ce.rid = 1
); 

-- 呼吸频率
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.respiratory_rate;
CREATE MATERIALIZED VIEW mimic_icu.respiratory_rate AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 220210) AS ce
	WHERE ce.rid = 1
); 

-- 血红蛋白含量
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.Hemoglobin;
CREATE MATERIALIZED VIEW mimic_icu.Hemoglobin AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 220228) AS ce
	WHERE ce.rid = 1
); 


-- 身高
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.height;
CREATE MATERIALIZED VIEW mimic_icu.height AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 226730) AS ce
	WHERE ce.rid = 1
); 

-- 体重
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.weight;
CREATE MATERIALIZED VIEW mimic_icu.weight AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 226512) AS ce
	WHERE ce.rid = 1
); 

-- 血糖220621
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.glucose;
CREATE MATERIALIZED VIEW mimic_icu.glucose AS (
	SELECT 
	 ce.subject_id,
	 ce.hadm_id,
	 ce.stay_id,
	 ce.value, 
	 ce.valuenum, 
	 ce.valueuom
	FROM (SELECT ROW_NUMBER() OVER ( PARTITION BY subject_id ORDER BY charttime ASC ) AS rid, * FROM mimic_icu.chartevents WHERE itemid = 220621) AS ce
	WHERE ce.rid = 1
); 





