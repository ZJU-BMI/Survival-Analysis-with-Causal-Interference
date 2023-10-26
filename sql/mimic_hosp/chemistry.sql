DROP MATERIALIZED VIEW IF EXISTS chemistry; 
CREATE MATERIALIZED VIEW chemistry AS (
	-- extract chemistry labs
	-- excludes point of care tests (very rare)
	-- blood gas measurements are *not* included in this query
	SELECT 
	  MAX ( subject_id ) AS subject_id,
		MAX ( hadm_id ) AS hadm_id,
		MAX ( charttime ) AS charttime,
		le.specimen_id -- convert from itemid into a meaningful column
		,
		MAX ( CASE WHEN itemid = 50862 AND valuenum <= 10 THEN valuenum ELSE NULL END ) AS albumin,
		MAX ( CASE WHEN itemid = 50930 AND valuenum <= 10 THEN valuenum ELSE NULL END ) AS globulin,
		MAX ( CASE WHEN itemid = 50976 AND valuenum <= 20 THEN valuenum ELSE NULL END ) AS total_protein,
		MAX ( CASE WHEN itemid = 50868 AND valuenum > 5 AND valuenum <= 25 THEN valuenum ELSE NULL END ) AS aniongap,
		MAX ( CASE WHEN itemid = 50882 AND valuenum > 15 AND valuenum <= 45 THEN valuenum ELSE NULL END ) AS bicarbonate,
		MAX ( CASE WHEN itemid = 51006 AND valuenum > 10 AND valuenum <= 70 THEN valuenum ELSE NULL END ) AS bun,
		MAX ( CASE WHEN itemid = 50893 AND valuenum > 0 AND valuenum <= 10000 THEN valuenum ELSE NULL END ) AS calcium,
		MAX ( CASE WHEN itemid = 50902 AND valuenum > 0 AND valuenum <= 10000 THEN valuenum ELSE NULL END ) AS chloride,
		MAX ( CASE WHEN itemid = 50912 AND valuenum > 0.3 AND valuenum <= 3.5 THEN valuenum ELSE NULL END ) AS creatinine,
		MAX ( CASE WHEN itemid = 50931 AND valuenum > 80 AND valuenum <= 180 THEN valuenum ELSE NULL END ) AS glucose,
		MAX ( CASE WHEN itemid = 50983 AND valuenum > 5 AND valuenum <= 165 THEN valuenum ELSE NULL END ) AS sodium,
		MAX ( CASE WHEN itemid = 50971 AND valuenum > 0 AND valuenum <= 7 THEN valuenum ELSE NULL END ) AS potassium,
		MAX ( CASE WHEN itemid = 50960 AND valuenum > 0 AND valuenum <= 5 THEN valuenum ELSE NULL END ) AS magnesium,
		MAX ( CASE WHEN itemid = 50970 AND valuenum > 1 AND valuenum <= 7.5 THEN valuenum ELSE NULL END ) AS phosphate,
		MAX ( CASE WHEN itemid = 50820 AND valuenum > 5 AND valuenum <= 30 THEN valuenum ELSE NULL END ) AS ph
	FROM
		mimic_hosp.labevents le 
	WHERE
		le.itemid IN (-- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
			50862,-- ALBUMIN | CHEMISTRY | BLOOD | 146697
			50930,-- Globulin
			50976,-- Total protein
			50868,-- ANION GAP | CHEMISTRY | BLOOD | 769895
			-- 52456, -- Anion gap, point of care test
			50882,-- BICARBONATE | CHEMISTRY | BLOOD | 780733
			50893,-- Calcium
			50912,-- CREATININE | CHEMISTRY | BLOOD | 797476
			-- 52502, Creatinine, point of care
			50902,-- CHLORIDE | CHEMISTRY | BLOOD | 795568
			50931,-- GLUCOSE | CHEMISTRY | BLOOD | 748981
			-- 52525, Glucose, point of care
			50971,-- POTASSIUM | CHEMISTRY | BLOOD | 845825
			-- 52566, -- Potassium, point of care
			50983,-- SODIUM | CHEMISTRY | BLOOD | 808489
			-- 52579, -- Sodium, point of care
			51006, -- UREA NITROGEN | CHEMISTRY | BLOOD | 791925
			-- 52603, Urea, point of care
			50960,
			50802,
			50970,
			50820
			
		) 
		AND valuenum IS NOT NULL -- lab values cannot be 0 and cannot be negative
		-- .. except anion gap.
		AND ( valuenum > 0) 
	GROUP BY
		le.specimen_id
);