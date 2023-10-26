SELECT diagnosisstring, icd9code, "count"(*) FROM icu_diags WHERE LOWER(diagnosisstring)
LIKE '%pneumonia%' GROUP BY icd9code, diagnosisstring

SELECT icd9code FROM diagnosis WHERE LOWER(diagnosisstring)
LIKE '%pneumonia%' GROUP BY icd9code