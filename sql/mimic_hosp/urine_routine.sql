DROP MATERIALIZED VIEW IF EXISTS urine_routine;
CREATE MATERIALIZED VIEW urine_routine AS (
	SELECT 
		MAX ( subject_id ) AS subject_id,
		MAX ( hadm_id ) AS hadm_id,
		MAX ( charttime ) AS charttime,
		le.specimen_id,
		MAX ( CASE WHEN itemid = 51498 THEN valuenum ELSE NULL END ) AS sg,
		MAX ( CASE WHEN itemid = 51484 THEN valuenum ELSE NULL END ) AS ket,
		MAX ( CASE WHEN itemid = 51486 THEN valuenum ELSE NULL END ) AS leu,
		MAX ( CASE WHEN itemid = 51487 THEN valuenum ELSE NULL END ) AS nit,
		MAX ( CASE WHEN itemid = 51464 THEN valuenum ELSE NULL END ) AS bil,
		MAX ( CASE WHEN itemid = 51514 THEN valuenum ELSE NULL END ) AS ubg
	FROM
		mimic_hosp.labevents le 
	WHERE
		le.itemid IN (
			51498,-- Specific Gravity
			51484,-- Ketone
			51486,-- Leukocytes
			51487,-- Nitrite
			51464,-- Bilirubin
			51514 -- Urobilinogen
		) 
		AND valuenum IS NOT NULL
		AND valuenum > 0 
	GROUP BY
		le.specimen_id 
);