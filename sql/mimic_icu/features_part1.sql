DROP MATERIALIZED VIEW IF EXISTS features_part1;
CREATE MATERIALIZED VIEW features_part1 AS (
		SELECT 
			icd.subject_id,
			icd.admittime,
			icd.dischtime,

			-- height and weight
			ROUND((AVG(CASE WHEN he.charttime BETWEEN icd.admittime AND icd.dischtime THEN he.height ELSE NULL END))::numeric, 2) AS height,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.weight ELSE NULL END))::numeric, 2) AS weight,
			
			-- vital_signs
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.heart_rate ELSE NULL END))::numeric, 2) AS heart_rate,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.sbp ELSE NULL END))::numeric, 2) AS sbp,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.dbp ELSE NULL END))::numeric, 2) AS dbp,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.mbp ELSE NULL END))::numeric, 2) AS mbp,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.sbp_ni ELSE NULL END))::numeric, 2) AS sbp_ni,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.dbp_ni ELSE NULL END))::numeric, 2) AS dbp_ni,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.mbp_ni ELSE NULL END))::numeric, 2) AS mbp_ni,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.cvp ELSE NULL END))::numeric, 2) AS cvp,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.resp_rate ELSE NULL END))::numeric, 2) AS resp_rate,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.temperature ELSE NULL END))::numeric, 2) AS temperature,
			ROUND((AVG(CASE WHEN vs.charttime BETWEEN icd.admittime AND icd.dischtime THEN vs.spo2 ELSE NULL END))::numeric, 2) AS spo2,
			
			-- blood_counts
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.hematocrit ELSE NULL END))::numeric, 2) AS hematocrit,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.hemoglobin ELSE NULL END))::numeric, 2) AS hemoglobin,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.mch ELSE NULL END))::numeric, 2) AS mch,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.mchc ELSE NULL END))::numeric, 2) AS mchc,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.mcv ELSE NULL END))::numeric, 2) AS mcv,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.platelet ELSE NULL END))::numeric, 2) AS platelet,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.rbc ELSE NULL END))::numeric, 2) AS rbc,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.rdw ELSE NULL END))::numeric, 2) AS rdw,
			ROUND((AVG(CASE WHEN bc.charttime BETWEEN icd.admittime AND icd.dischtime THEN bc.rdwsd ELSE NULL END))::numeric, 2) AS rdwsd
			
		FROM mimic_icu.icustays_detail icd
		LEFT JOIN mimic_icu.height he ON icd.subject_id = he.subject_id
		LEFT JOIN mimic_icu.vital_signs vs ON icd.subject_id = vs.subject_id
		LEFT JOIN mimic_hosp.blood_count bc ON icd.subject_id = bc.subject_id
	  GROUP BY icd.subject_id, icd.admittime, icd.dischtime
 );