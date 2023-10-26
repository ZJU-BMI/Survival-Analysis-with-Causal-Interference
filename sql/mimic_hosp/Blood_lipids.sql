DROP MATERIALIZED VIEW IF EXISTS Blood_lipids;
CREATE MATERIALIZED VIEW Blood_lipids AS (
	SELECT 
		MAX ( subject_id ) AS subject_id,
		MAX ( hadm_id ) AS hadm_id,
		MAX ( charttime ) AS charttime,
		le.specimen_id,
		MAX ( CASE WHEN itemid = 50907 THEN valuenum ELSE NULL END ) AS tc,
		MAX ( CASE WHEN itemid = 51000 THEN valuenum ELSE NULL END ) AS tg,
		MAX ( CASE WHEN itemid = 50904 THEN valuenum ELSE NULL END ) AS hdlc,
		MAX ( CASE WHEN itemid = 50905 THEN valuenum ELSE NULL END ) AS ldlc
	FROM
		mimic_hosp.labevents le 
	WHERE
		le.itemid IN (
			50907,-- Total cholesterol 
			51000,-- Triglycerides
			50905,-- Low-density lipoprotein cholesterol
			50904 -- High-density lipoprotein cholesterol
		) 
		AND valuenum IS NOT NULL
		AND valuenum > 0 
	GROUP BY
		le.specimen_id 
);