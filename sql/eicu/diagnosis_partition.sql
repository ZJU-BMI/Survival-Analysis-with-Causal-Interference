-- (001-139)传染病和寄生虫疾病
DROP MATERIALIZED VIEW IF EXISTS eicu.diag_parasites;
CREATE MATERIALIZED VIEW eicu.diag_parasites AS (	
	SELECT 
		di.patientunitstayid,
		di.icd9code,
		di.diagnosisstring,
		bd.age,
		bd.gender,
		bd.hosp_mortality,
		'Parasites' AS "type"
	FROM
		(SELECT ROW_NUMBER () OVER (PARTITION BY patientunitstayid ORDER BY diagnosisoffset ASC) AS rid, * 
		 FROM eicu.diagnosis
		 WHERE (icd9code ~ '^((00[1-9])|(0[1-9][0-9])|(1[0-3][0-9])).*' 
		 OR icd9code ~ ', ((00[1-9])|(0[1-9][0-9])|(1[0-3][0-9])).*')
		) AS di
	LEFT JOIN basic_demographics bd
	ON di.patientunitstayid = bd.patientunitstayid
	WHERE di.rid = 1 AND (di.diagnosispriority = 'Major' OR di.diagnosispriority = 'Primary')
);

-- (280–289)：血液及造血器官疾病
DROP MATERIALIZED VIEW IF EXISTS eicu.diag_blood;
CREATE MATERIALIZED VIEW eicu.diag_blood AS (	
	SELECT 
		di.patientunitstayid,
		di.icd9code,
		di.diagnosisstring,
		bd.age,
		bd.gender,
		bd.hosp_mortality,
		'Blood' AS "type"
	FROM
		(SELECT ROW_NUMBER () OVER (PARTITION BY patientunitstayid ORDER BY diagnosisoffset ASC) AS rid, * 
		 FROM eicu.diagnosis
		 WHERE icd9code ~ '^28[0-9].*' 
		 OR icd9code ~ ', 28[0-9].*'
		) AS di
	LEFT JOIN basic_demographics bd
	ON di.patientunitstayid = bd.patientunitstayid
	WHERE di.rid = 1 AND (di.diagnosispriority = 'Major' OR di.diagnosispriority = 'Primary')
);

-- (390–459)：循环系统疾病
DROP MATERIALIZED VIEW IF EXISTS eicu.diag_circulatory;
CREATE MATERIALIZED VIEW eicu.diag_circulatory AS (	
	SELECT 
		di.patientunitstayid,
		di.icd9code,
		di.diagnosisstring,
		bd.age,
		bd.gender,
		bd.hosp_mortality,
		'Circulatory' AS "type"
	FROM
		(SELECT ROW_NUMBER () OVER (PARTITION BY patientunitstayid ORDER BY diagnosisoffset ASC) AS rid, * 
		 FROM eicu.diagnosis
		 WHERE icd9code ~ '^((39[0-9])|(4[0-5][0-9])).*' 
		 OR icd9code ~ ', ((39[0-9])|(4[0-5][0-9])).*'
		) AS di
	LEFT JOIN basic_demographics bd
	ON di.patientunitstayid = bd.patientunitstayid
	WHERE di.rid = 1 AND (di.diagnosispriority = 'Major' OR di.diagnosispriority = 'Primary')
);

-- (460–519)：呼吸系统疾病
DROP MATERIALIZED VIEW IF EXISTS eicu.diag_respiratory;
CREATE MATERIALIZED VIEW eicu.diag_respiratory AS (	
	SELECT 
		di.patientunitstayid,
		di.icd9code,
		di.diagnosisstring,
		bd.age,
		bd.gender,
		bd.hosp_mortality,
		'Respiratory' AS "type"
	FROM
		(SELECT ROW_NUMBER () OVER (PARTITION BY patientunitstayid ORDER BY diagnosisoffset ASC) AS rid, * 
		 FROM eicu.diagnosis
		 WHERE icd9code ~ '^((4[6-9][0-9])|(5[0-1][0-9])).*' 
		 OR icd9code ~ ', ((4[6-9][0-9])|(5[0-1][0-9])).*'
		) AS di
	LEFT JOIN basic_demographics bd
	ON di.patientunitstayid = bd.patientunitstayid
	WHERE di.rid = 1 AND (di.diagnosispriority = 'Major' OR di.diagnosispriority = 'Primary')
);

-- (520–579)：消化系统疾病
DROP MATERIALIZED VIEW IF EXISTS eicu.diag_digest;
CREATE MATERIALIZED VIEW eicu.diag_digest AS (	
	SELECT 
		di.patientunitstayid,
		di.icd9code,
		di.diagnosisstring,
		bd.age,
		bd.gender,
		bd.hosp_mortality,
		'Digest' AS "type"
	FROM
		(SELECT ROW_NUMBER () OVER (PARTITION BY patientunitstayid ORDER BY diagnosisoffset ASC) AS rid, * 
		 FROM eicu.diagnosis
		 WHERE icd9code ~ '^5[2-7][0-9].*' 
		 OR icd9code ~ ', 5[2-7][0-9].*'
		) AS di
	LEFT JOIN basic_demographics bd
	ON di.patientunitstayid = bd.patientunitstayid
	WHERE di.rid = 1 AND (di.diagnosispriority = 'Major' OR di.diagnosispriority = 'Primary')
);

-- (800–999)：受伤及中毒
DROP MATERIALIZED VIEW IF EXISTS eicu.diag_injury_poison;
CREATE MATERIALIZED VIEW eicu.diag_injury_poison AS (	
	SELECT 
		di.patientunitstayid,
		di.icd9code,
		di.diagnosisstring,
		bd.age,
		bd.gender,
		bd.hosp_mortality,
		'Injury_poison' AS "type"
	FROM
		(SELECT ROW_NUMBER () OVER (PARTITION BY patientunitstayid ORDER BY diagnosisoffset ASC) AS rid, * 
		 FROM eicu.diagnosis
		 WHERE icd9code ~ '^((8[0-9][0-9])|(9[0-9][0-9])).*' 
		 OR icd9code ~ ', ((8[0-9][0-9])|(9[0-9][0-9])).*'
		) AS di
	LEFT JOIN basic_demographics bd
	ON di.patientunitstayid = bd.patientunitstayid
	WHERE di.rid = 1 AND (di.diagnosispriority = 'Major' OR di.diagnosispriority = 'Primary')
);



