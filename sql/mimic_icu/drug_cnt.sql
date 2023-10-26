DROP MATERIALIZED VIEW IF EXISTS drug_cnt CASCADE;
CREATE MATERIALIZED VIEW drug_cnt AS(
	WITH ids_cnt AS (
		SELECT itemid, count(*) AS cnt, max(amountuom) AS unit FROM inputevents GROUP BY itemid
	)

	SELECT ic.itemid, ic.cnt, ic.unit, label, abbreviation
	FROM ids_cnt ic
	LEFT JOIN d_items ON d_items.itemid = ic.itemid
	ORDER BY cnt DESC
)