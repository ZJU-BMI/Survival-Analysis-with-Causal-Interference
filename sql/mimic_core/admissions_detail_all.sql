-- 入院信息
DROP MATERIALIZED VIEW IF EXISTS mimic_core.admissions_detail_all CASCADE;
CREATE MATERIALIZED VIEW mimic_core.admissions_detail_all AS (
	SELECT
		adm.*,
		pat.gender,
		(EXTRACT(YEAR FROM adm.admittime) - pat.anchor_year + pat.anchor_age) AS age,
		pat.dod,
		round((date_part('epoch', (adm.dischtime - adm.admittime)) / 86400)::numeric, 2) AS hosp_stay,
		ROW_NUMBER ( ) OVER ( PARTITION BY adm.subject_id ORDER BY adm.admittime ASC ) AS rid
	FROM
		mimic_core.admissions adm
		LEFT JOIN mimic_core.patients pat ON adm.subject_id = pat.subject_id 
);
