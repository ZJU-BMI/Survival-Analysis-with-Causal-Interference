DROP MATERIALIZED VIEW IF EXISTS features_part3;
CREATE MATERIALIZED VIEW features_part3 AS (
		SELECT 
			icd.subject_id,
			icd.admittime,
			icd.dischtime,
			
			-- urine_routine
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.sg ELSE NULL END))::numeric, 2) AS sg,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.pH ELSE NULL END))::numeric, 2) AS pH,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.ket ELSE NULL END))::numeric, 2) AS ket,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.leu ELSE NULL END))::numeric, 2) AS leu,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.nit ELSE NULL END))::numeric, 2) AS nit,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.pro ELSE NULL END))::numeric, 2) AS pro,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.glu ELSE NULL END))::numeric, 2) AS glu,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.bil ELSE NULL END))::numeric, 2) AS bil,
			ROUND((AVG(CASE WHEN ur.charttime BETWEEN icd.admittime AND icd.dischtime THEN ur.ubg ELSE NULL END))::numeric, 2) AS ubg,
			
			-- chemistry
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.albumin ELSE NULL END))::numeric, 2) AS albumin,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.globulin ELSE NULL END))::numeric, 2) AS globulin,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.total_protein ELSE NULL END))::numeric, 2) AS total_protein,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.aniongap ELSE NULL END))::numeric, 2) AS aniongap,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.bicarbonate ELSE NULL END))::numeric, 2) AS bicarbonate,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.bun ELSE NULL END))::numeric, 2) AS bun,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.calcium ELSE NULL END))::numeric, 2) AS calcium,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.chloride ELSE NULL END))::numeric, 2) AS chloride,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.creatinine ELSE NULL END))::numeric, 2) AS creatinine,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.glucose ELSE NULL END))::numeric, 2) AS glucose,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.sodium ELSE NULL END))::numeric, 2) AS sodium,
			ROUND((AVG(CASE WHEN cms.charttime BETWEEN icd.admittime AND icd.dischtime THEN cms.potassium ELSE NULL END))::numeric, 2) AS potassium,
			
			-- enzyme
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.alt ELSE NULL END))::numeric, 2) AS alt,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.alp ELSE NULL END))::numeric, 2) AS alp,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.ast ELSE NULL END))::numeric, 2) AS ast,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.amylase ELSE NULL END))::numeric, 2) AS amylase,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.bilirubin_total ELSE NULL END))::numeric, 2) AS bilirubin_total,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.bilirubin_direct ELSE NULL END))::numeric, 2) AS bilirubin_direct,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.bilirubin_indirect ELSE NULL END))::numeric, 2) AS bilirubin_indirect,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.ck_cpk ELSE NULL END))::numeric, 2) AS ck_cpk,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.ck_mb ELSE NULL END))::numeric, 2) AS ck_mb,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.ggt ELSE NULL END))::numeric, 2) AS ggt,
			ROUND((AVG(CASE WHEN enz.charttime BETWEEN icd.admittime AND icd.dischtime THEN enz.ld_ldh ELSE NULL END))::numeric, 2) AS ld_ldh
			
		 FROM mimic_icu.icustays_detail icd
		 LEFT JOIN mimic_hosp.urine_routine ur ON icd.subject_id = ur.subject_id
		 LEFT JOIN mimic_hosp.chemistry cms ON icd.subject_id = cms.subject_id
		 LEFT JOIN mimic_hosp.enzyme enz ON icd.subject_id = enz.subject_id
		 GROUP BY icd.subject_id, icd.admittime, icd.dischtime
 );