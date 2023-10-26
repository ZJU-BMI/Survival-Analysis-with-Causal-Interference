DROP MATERIALIZED VIEW IF EXISTS height;
CREATE MATERIALIZED VIEW height AS (
	-- prep height
	WITH ht_in AS (
		SELECT 
			C.subject_id,
			C.hadm_id,
			C.stay_id,
			C.charttime, -- Ensure that all heights are in centimeters
			ROUND( (C.valuenum * 2.54)::numeric, 2 ) AS height,
			C.valuenum AS height_orig 
		FROM
			mimic_icu.chartevents C 
		WHERE
			C.valuenum IS NOT NULL -- Height (measured in inches)
			AND C.itemid = 226707 
	), ht_cm AS (
		SELECT 
			C.subject_id,
			C.hadm_id,
			C.stay_id,
			C.charttime, -- Ensure that all heights are in centimeters
			ROUND( C.valuenum::numeric, 2 ) AS height 
		FROM
			mimic_icu.chartevents C 
		WHERE
			C.valuenum IS NOT NULL -- Height cm
			
			AND C.itemid = 226730 
	), ht_stg0 AS (
		SELECT 
			COALESCE( h1.subject_id, h1.subject_id ) AS subject_id,
			COALESCE ( h1.stay_id, h1.stay_id ) AS stay_id,
			COALESCE ( h1.hadm_id, h1.hadm_id ) AS hadm_id,
			COALESCE ( h1.charttime, h1.charttime ) AS charttime,
			COALESCE ( h1.height, h2.height ) AS height 
		FROM
			ht_cm h1
			FULL OUTER JOIN ht_in h2 ON h1.subject_id = h2.subject_id 
			AND h1.charttime = h2.charttime 
	) 
	SELECT
		subject_id,
		stay_id,
		hadm_id,
		charttime,
		height 
	FROM
		ht_stg0 
	WHERE
		height IS NOT NULL AND height > 120 AND height < 230 
	);
	