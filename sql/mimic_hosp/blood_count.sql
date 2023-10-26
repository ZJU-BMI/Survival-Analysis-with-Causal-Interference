DROP MATERIALIZED VIEW IF EXISTS blood_count;
CREATE MATERIALIZED VIEW blood_count AS (
	SELECT 
		MAX ( subject_id ) AS subject_id,
		MAX ( hadm_id ) AS hadm_id,
		MAX ( charttime ) AS charttime,
		le.specimen_id,
		MAX ( CASE WHEN itemid = 51221 AND valuenum > 20 AND valuenum < 45 THEN valuenum ELSE NULL END ) AS hct,
		MAX ( CASE WHEN itemid = 51222 AND valuenum > 5 AND valuenum < 20 THEN valuenum ELSE NULL END ) AS hgb,
		MAX ( CASE WHEN itemid = 51248 AND valuenum > 20 AND valuenum < 45 THEN valuenum ELSE NULL END ) AS mch,
		MAX ( CASE WHEN itemid = 51249 AND valuenum > 20 AND valuenum < 45 THEN valuenum ELSE NULL END ) AS mchc,
		MAX ( CASE WHEN itemid = 51250 AND valuenum > 60 AND valuenum < 120 THEN valuenum ELSE NULL END ) AS mcv,
		MAX ( CASE WHEN itemid = 51265 AND valuenum > 80 AND valuenum < 360 THEN valuenum ELSE NULL END ) AS platelet,
		MAX ( CASE WHEN itemid = 51279 AND valuenum > 0 AND valuenum < 5.5 THEN valuenum ELSE NULL END ) AS rbc,
		MAX ( CASE WHEN itemid = 51277 AND valuenum > 10 AND valuenum < 28 THEN valuenum ELSE NULL END ) AS rdw,
		MAX ( CASE WHEN itemid = 51301 AND valuenum > 5 AND valuenum < 25 THEN valuenum ELSE NULL END ) AS wbc 
	FROM
		mimic_hosp.labevents le 
	WHERE
		le.itemid IN (
			51221,-- hematocrit
			51222,-- hemoglobin
			51248,-- MCH
			51249,-- MCHC
			51250,-- MCV
			51265,-- platelets
			51279,-- RBC
			51277,-- RDW
			52159,-- RDW SD
			51301 -- WBC
		) 
		AND valuenum IS NOT NULL
		AND valuenum > 0 
	GROUP BY
		le.specimen_id 
);
	
	