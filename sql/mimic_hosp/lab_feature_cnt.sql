DROP MATERIALIZED VIEW IF EXISTS lab_feature_cnt;
CREATE MATERIALIZED VIEW lab_feature_cnt AS (
	WITH lab_cnt AS (
		SELECT itemid, count(*) AS cnt, MAX(valueuom) AS unitname
		FROM labevents 
		GROUP BY itemid
	)
	SELECT lc.itemid, lc.cnt, lc.unitname
		, label, loinc_code
		FROM lab_cnt lc
		LEFT JOIN d_labitems ON lc.itemid = d_labitems.itemid
		ORDER BY cnt DESC
);