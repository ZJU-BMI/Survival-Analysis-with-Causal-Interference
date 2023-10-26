DROP MATERIALIZED VIEW IF EXISTS features_part2;
CREATE MATERIALIZED VIEW features_part2 AS (
		SELECT 
			icd.subject_id,
			icd.admittime,
			icd.dischtime,
			
			-- blood_diff
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.wbc ELSE NULL END))::numeric, 2) AS wbc,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.basophils_abs ELSE NULL END))::numeric, 2) AS basophils_abs,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.eosinophils_abs ELSE NULL END))::numeric, 2) AS eosinophils_abs,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.lymphocytes_abs ELSE NULL END))::numeric, 2) AS lymphocytes_abs,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.monocytes_abs ELSE NULL END))::numeric, 2) AS monocytes_abs,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.neutrophils_abs ELSE NULL END))::numeric, 2) AS neutrophils_abs,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.basophils ELSE NULL END))::numeric, 2) AS basophils,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.eosinophils ELSE NULL END))::numeric, 2) AS eosinophils,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.lymphocytes ELSE NULL END))::numeric, 2) AS lymphocytes,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.monocytes ELSE NULL END))::numeric, 2) AS monocytes,
			ROUND((AVG(CASE WHEN bd.charttime BETWEEN icd.admittime AND icd.dischtime THEN bd.neutrophils ELSE NULL END))::numeric, 2) AS neutrophils,
			
			-- coagulation
			ROUND((AVG(CASE WHEN coa.charttime BETWEEN icd.admittime AND icd.dischtime THEN coa.d_dimer ELSE NULL END))::numeric, 2) AS d_dimer,
			ROUND((AVG(CASE WHEN coa.charttime BETWEEN icd.admittime AND icd.dischtime THEN coa.fibrinogen ELSE NULL END))::numeric, 2) AS fibrinogen,
			ROUND((AVG(CASE WHEN coa.charttime BETWEEN icd.admittime AND icd.dischtime THEN coa.thrombin ELSE NULL END))::numeric, 2) AS thrombin,
			ROUND((AVG(CASE WHEN coa.charttime BETWEEN icd.admittime AND icd.dischtime THEN coa.inr ELSE NULL END))::numeric, 2) AS inr,
			ROUND((AVG(CASE WHEN coa.charttime BETWEEN icd.admittime AND icd.dischtime THEN coa.pt ELSE NULL END))::numeric, 2) AS pt,
			ROUND((AVG(CASE WHEN coa.charttime BETWEEN icd.admittime AND icd.dischtime THEN coa.ptt ELSE NULL END))::numeric, 2) AS ptt,
			
			-- blood_lipids
			ROUND((AVG(CASE WHEN bl.charttime BETWEEN icd.admittime AND icd.dischtime THEN bl.tc ELSE NULL END))::numeric, 2) AS tc,
			ROUND((AVG(CASE WHEN bl.charttime BETWEEN icd.admittime AND icd.dischtime THEN bl.tg ELSE NULL END))::numeric, 2) AS tg,
			ROUND((AVG(CASE WHEN bl.charttime BETWEEN icd.admittime AND icd.dischtime THEN bl.hdlc ELSE NULL END))::numeric, 2) AS hdlc,
			ROUND((AVG(CASE WHEN bl.charttime BETWEEN icd.admittime AND icd.dischtime THEN bl.ldlc ELSE NULL END))::numeric, 2) AS ldlc
			
		 FROM mimic_icu.icustays_detail icd
		 LEFT JOIN mimic_hosp.blood_diff bd ON icd.subject_id = bd.subject_id
		 LEFT JOIN mimic_hosp.coagulation coa ON icd.subject_id = coa.subject_id
		 LEFT JOIN mimic_hosp.blood_lipids bl ON icd.subject_id = bl.subject_id
		 GROUP BY icd.subject_id, icd.admittime, icd.dischtime
 );