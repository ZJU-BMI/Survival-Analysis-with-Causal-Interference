DROP MATERIALIZED VIEW IF EXISTS icu_diags;
CREATE MATERIALIZED VIEW icu_diags AS(
	WITH diag AS(
		SELECT di.*, did.long_title
		FROM mimic_hosp.diagnoses_icd di
		LEFT JOIN mimic_hosp.d_icd_diagnoses did ON di.icd_code = did.icd_code AND di.icd_version = did.icd_version
	)
	--, test AS(
	SELECT
		icu.subject_id,
		icu.hadm_id,
		hospital_expire_flag,
		d.icd_code,
		d.icd_version,
		d.seq_num,
		d.long_title
	FROM
		"icustays_detail" icu
	LEFT JOIN diag d ON icu.subject_id = d.subject_id AND icu.hadm_id = d.hadm_id
	WHERE
		first_icu_stay = 't'
	ORDER BY
		subject_id,
		hadm_id,
		seq_num
	--)
)
