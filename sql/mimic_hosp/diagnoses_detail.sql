-- 首次入院诊断信息
DROP MATERIALIZED VIEW IF EXISTS mimic_hosp.diagnoses_detail;
CREATE MATERIALIZED VIEW mimic_hosp.diagnoses_detail AS (
	SELECT 
		ad.subject_id, 
		ad.hadm_id,
		ad.age,
		ad.gender,
		ad.hospital_expire_flag, 
		di.icd_code
	FROM
		mimic_core.admissions_datail ad 
	LEFT JOIN mimic_hosp.diagnoses_icd di ON di.subject_id = ad.subject_id AND di.hadm_id = ad.hadm_id 
	WHERE di.seq_num = 1
	ORDER BY di.icd_code
);