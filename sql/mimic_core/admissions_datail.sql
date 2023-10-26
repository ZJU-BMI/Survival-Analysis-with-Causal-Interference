-- 入院信息
DROP MATERIALIZED VIEW IF EXISTS mimic_core.admissions_datail;
CREATE MATERIALIZED VIEW mimic_core.admissions_datail AS (
	SELECT
		adm.*,
		pat.gender,
		(EXTRACT(YEAR FROM adm.admittime) - pat.anchor_year + pat.anchor_age) AS age,
		pat.dod 
	FROM
		( SELECT ROW_NUMBER ( ) OVER ( PARTITION BY subject_id ORDER BY admittime ASC ) AS rid, * FROM mimic_core.admissions ) AS adm
		LEFT JOIN mimic_core.patients pat ON adm.subject_id = pat.subject_id 
	WHERE
	  adm.rid = 1 
);


DROP MATERIALIZED VIEW IF EXISTS mimic_core.age;
CREATE MATERIALIZED VIEW mimic_core.age AS (
	SELECT 	
		ad.subject_id,
		ad.hadm_id,
		ad.admittime,
		pa.anchor_age,
		pa.anchor_year,
		(EXTRACT(YEAR FROM ad.admittime) - pa.anchor_year + pa.anchor_age) AS age
	FROM mimic_core.admissions ad
	INNER JOIN mimic_core.patients pa
	ON ad.subject_id = pa.subject_id
);