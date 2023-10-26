CREATE MATERIALIZED VIEW feature_cnt AS (
	WITH ids AS(
		SELECT itemid, count(*) AS cnt FROM "chartevents" GROUP BY itemid
	)
	SELECT ids.itemid, ids.cnt
				 , label, abbreviation, unitname, param_type 
	FROM ids 
	LEFT JOIN d_items ON ids.itemid = d_items.itemid
	ORDER BY ids.cnt DESC
);