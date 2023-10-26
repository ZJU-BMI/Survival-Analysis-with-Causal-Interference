DROP MATERIALIZED VIEW IF EXISTS item_counts;
CREATE MATERIALIZED VIEW item_counts AS (
		WITH itc AS (
			SELECT itemid, COUNT(itemid) AS "count"
			FROM chartevents
			GROUP BY itemid
		)
		SELECT 
			itc.*,
			di.label,
			di.abbreviation,
			di.category,
			di.unitname,
			di.param_type
		FROM itc
		LEFT JOIN d_items di
		ON itc.itemid = di.itemid
		ORDER BY itc."count" DESC
);