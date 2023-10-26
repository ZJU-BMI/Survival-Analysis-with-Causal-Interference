DROP MATERIALIZED VIEW IF EXISTS blood_gas; 
CREATE MATERIALIZED VIEW blood_gas AS (
	SELECT 
	  MAX ( subject_id ) AS subject_id,
		MAX ( hadm_id ) AS hadm_id,
		MAX ( charttime ) AS charttime,
		le.specimen_id -- convert from itemid into a meaningful column
		,
		MAX ( CASE WHEN itemid = 50818 AND valuenum > 20 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS pco2,
		MAX ( CASE WHEN itemid = 50821 AND valuenum > 60 AND valuenum < 125 THEN valuenum ELSE NULL END ) AS po2,
		MAX ( CASE WHEN itemid = 50804 AND valuenum > 15 AND valuenum < 45 THEN valuenum ELSE NULL END ) AS total_co2,
		MAX ( CASE WHEN itemid = 50802 AND valuenum > -5 AND valuenum < 5 THEN valuenum ELSE NULL END ) AS base_excess
	FROM
		mimic_hosp.labevents le 
	WHERE
		le.itemid IN (
			50818,
			50821,
			50804,
			50802
		) 
		AND valuenum IS NOT NULL
		AND (valuenum > 0 OR itemid = 50802)
	GROUP BY
		le.specimen_id
);