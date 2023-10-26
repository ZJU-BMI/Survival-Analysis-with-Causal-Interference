-- SELECT medication, count(*) FROM "emar" GROUP BY medication ORDER BY count(*) DESC;

DROP MATERIALIZED VIEW IF EXISTS medication;
CREATE MATERIALIZED VIEW medication AS (
	SELECT 
		MAX(subject_id) AS subject_id, MAX(hadm_id) AS hadm_id, MAX(charttime) AS charttime
		-- blood count
		, CASE WHEN medication = 'Sodium Chloride 0.9%  Flush' THEN valuenum ELSE NULL END ) AS hct
		, CASE WHEN medication = 51222 THEN valuenum ELSE NULL END ) AS hgb
		, CASE WHEN medication = 51248 THEN valuenum ELSE NULL END ) AS mch
		, CASE WHEN medication = 51249 THEN valuenum ELSE NULL END ) AS mchc
		, CASE WHEN medication = 51250 THEN valuenum ELSE NULL END ) AS mcv
		, CASE WHEN medication = 51265 THEN valuenum ELSE NULL END ) AS platelet
		
	FROM mimic_hosp.emar em
	WHERE
		em.medication IN (
			 
			
	)
	-- exclude 'Not Given' type
	AND event_txt != 'Not Given'
)

-- SELECT medication, event_txt FROM "emar" WHERE event_txt = 'Not Given'
