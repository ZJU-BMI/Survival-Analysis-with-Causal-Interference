-- 凝血指标
DROP MATERIALIZED VIEW IF EXISTS coagulation;
CREATE MATERIALIZED VIEW coagulation AS (
	SELECT 
		MAX ( subject_id ) AS subject_id,
		MAX ( hadm_id ) AS hadm_id,
		MAX ( charttime ) AS charttime,
		le.specimen_id -- convert from itemid into a meaningful column
		,
		-- MAX ( CASE WHEN itemid = 51196 THEN valuenum ELSE NULL END ) AS d_dimer,		-- D－二聚体
		-- MAX ( CASE WHEN itemid = 51214 THEN valuenum ELSE NULL END ) AS fibrinogen, -- 纤维蛋白原
		-- MAX ( CASE WHEN itemid = 51297 THEN valuenum ELSE NULL END ) AS thrombin,		-- 凝血酶时间
		MAX ( CASE WHEN itemid = 51237 AND valuenum > 0 AND valuenum < 2.4 THEN valuenum ELSE NULL END ) AS inr,				-- 国际标准化比值
		MAX ( CASE WHEN itemid = 52187 AND valuenum > 5 AND valuenum <= 25 THEN valuenum ELSE NULL END ) AS tt,					-- 凝血酶时间
		MAX ( CASE WHEN itemid = 51274 AND valuenum > 5 AND valuenum <= 28 THEN valuenum ELSE NULL END ) AS pt,					-- 凝血酶原时间
		MAX ( CASE WHEN itemid = 51275 AND valuenum > 20 AND valuenum <= 65 THEN valuenum ELSE NULL END ) AS ptt 				-- 部分凝血酶原时间
	FROM
		mimic_hosp.labevents le 
	WHERE
		le.itemid IN (
			--51196, -- D-Dimer
			--51214, -- Fibrinogen
			--51297, -- thrombin
			51237, -- INR
			51274, -- PT
			52187, -- TT
			51275 -- PTT
			
		) 
		AND valuenum IS NOT NULL 
	GROUP BY le.specimen_id 
);