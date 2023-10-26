DROP MATERIALIZED VIEW IF EXISTS pat_info;
CREATE MATERIALIZED VIEW pat_info AS (
	WITH height AS (
		SELECT subject_id, hadm_id, ROUND(AVG(height)::numeric, 2) AS height
		FROM height 
		WHERE height > 120 AND height < 250
		GROUP BY subject_id, hadm_id
		
	)
	, weight AS (
		select
				ce.subject_id
			, ce.hadm_id
			, ROUND(AVG(case when itemid in (226512, 224639) and valuenum > 0 and valuenum < 200 then valuenum
						when itemid in (226531) and valuenum > 0 and valuenum < 440 then ROUND((valuenum / 2.2)::numeric, 2) --- 英镑转化为千克
						else null end)::numeric, 2) AS weight
			FROM mimic_icu.chartevents ce
			WHERE itemid IN (
				226512, -- weight
				224639,
 				226531
			)
			group by ce.subject_id, ce.hadm_id
	)

	SELECT idf.subject_id, idf.hadm_id
		, idf.hospital_expire_flag AS label
		, diag
		, to_char(ad.admittime, 'yyyy-MM-dd') AS admittime
		, to_char(ad.deathtime, 'yyyy-MM-dd') AS deathtime
		, to_char(ad.dischtime, 'yyyy-MM-dd') AS dischtime
		, CASE WHEN ad.deathtime IS NOT NULL THEN ROUND((date_part('epoch', ad.deathtime - ad.admittime) / 86400)::numeric, 0)
			ELSE NULL END AS deathtime_diff
		, CASE WHEN ad.dischtime IS NOT NULL THEN ROUND((date_part('epoch', ad.dischtime - ad.admittime) / 86400)::numeric, 0)
			ELSE NULL END AS dischtime_diff
		, sep, neop, ch, arf, mi, hf, pneu, ci, sh, col, akf, ca, leu, hepf, panc, vt, diab 
		, CASE WHEN ad.gender = 'F' THEN 0 WHEN ad.gender = 'M' THEN 1 ELSE NULL END AS gender
		, ad.age, ad.ethnicity
		, CASE WHEN h.height > 120 AND h.height < 300 THEN h.height ELSE NULL END AS height
		, ROUND((w.weight)::numeric, 2) AS weight
		, CASE WHEN h.height > 120 AND h.height < 300 THEN
								ROUND((w.weight * 10000.0 / (h.height * h.height))::numeric, 2) ELSE NULL END AS bmi
	FROM mimic_icu.icu_diag_first idf
	LEFT JOIN mimic_core.admissions_detail_all ad ON idf.subject_id = ad.subject_id AND idf.hadm_id = ad.hadm_id
	LEFT JOIN height h ON idf.subject_id = h.subject_id AND idf.hadm_id = h.hadm_id
	LEFT JOIN weight w ON idf.subject_id = w.subject_id AND idf.hadm_id = w.hadm_id
	WHERE diag > 0 and total = 1
);