-- 心率
DROP MATERIALIZED VIEW IF EXISTS eicu.heart_rate;
CREATE MATERIALIZED VIEW eicu.heart_rate AS (
	SELECT 
		vp.vitalperiodicid,
		vp.patientunitstayid,
		vp.heartrate
	FROM 
		( SELECT ROW_NUMBER ( ) OVER ( PARTITION BY patientunitstayid ORDER BY observationoffset ASC ) AS rid, * FROM eicu.vitalperiodic ) AS vp
	WHERE 
		vp.rid = 1			 
);

-- 血压
DROP MATERIALIZED VIEW IF EXISTS eicu.abp;
CREATE MATERIALIZED VIEW eicu.abp AS (
	SELECT 
		vap.vitalaperiodicid,
		vap.patientunitstayid,
		vap.noninvasivesystolic AS systolic,
		vap.noninvasivediastolic AS diastolic
	FROM 
		( SELECT ROW_NUMBER ( ) OVER ( PARTITION BY patientunitstayid ORDER BY observationoffset ASC ) AS rid, * FROM eicu.vitalaperiodic ) AS vap
	WHERE 
		vap.rid = 1			 
);

-- 体温
DROP MATERIALIZED VIEW IF EXISTS eicu.temperature;
CREATE MATERIALIZED VIEW eicu.temperature AS (
	SELECT 
		vp.vitalperiodicid,
		vp.patientunitstayid,
		vp.temperature
	FROM 
		( SELECT ROW_NUMBER ( ) OVER ( PARTITION BY patientunitstayid ORDER BY observationoffset ASC ) AS rid, * FROM eicu.vitalperiodic ) AS vp
	WHERE 
		vp.rid = 1			 
);

-- 呼吸频率
DROP MATERIALIZED VIEW IF EXISTS eicu.respiration;
CREATE MATERIALIZED VIEW eicu.respiration AS (
	SELECT 
		vp.vitalperiodicid,
		vp.patientunitstayid,
		vp.respiration
	FROM 
		( SELECT ROW_NUMBER ( ) OVER ( PARTITION BY patientunitstayid ORDER BY observationoffset ASC ) AS rid, * FROM eicu.vitalperiodic ) AS vp
	WHERE 
		vp.rid = 1			 
);

-- 铁血红蛋白含量
DROP MATERIALIZED VIEW IF EXISTS eicu.methemoglobin;
CREATE MATERIALIZED VIEW eicu.methemoglobin AS (
	SELECT 
		lab.patientunitstayid,
		lab.labname,
		lab.labresult,
		lab.labmeasurenamesystem,
		lab.labmeasurenameinterface
	FROM 
		( SELECT ROW_NUMBER ( ) OVER ( PARTITION BY patientunitstayid ORDER BY labresultoffset ASC ) AS rid, * FROM eicu.lab WHERE labname = 'Methemoglobin') AS lab
	WHERE 
		lab.rid = 1			 
);

-- 血糖
DROP MATERIALIZED VIEW IF EXISTS eicu.glucose;
CREATE MATERIALIZED VIEW eicu.glucose AS (
	SELECT 
		lab.patientunitstayid,
		lab.labname,
		lab.labresult,
		lab.labmeasurenamesystem,
		lab.labmeasurenameinterface
	FROM 
		( SELECT ROW_NUMBER ( ) OVER ( PARTITION BY patientunitstayid ORDER BY labresultoffset ASC ) AS rid, * FROM eicu.lab WHERE labname = 'glucose') AS lab
	WHERE 
		lab.rid = 1			 
);








