DROP MATERIALIZED VIEW IF EXISTS vital_sgin_cnt CASCADE;
CREATE MATERIALIZED VIEW vital_sgin_cnt AS (
	SELECT nursingchartcelltypevallabel, nursingchartcelltypevalname, COUNT(*) AS cnt 
	FROM "nursecharting" 
	GROUP BY nursingchartcelltypevallabel, nursingchartcelltypevalname ORDER BY COUNT(*) DESC
)