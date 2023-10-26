SELECT * FROM eicu.diagnosis WHERE icd9code ~ '^((00[1-9])|(0[1-9][0-9])|(1[0-3][0-9])).*' OR icd9code ~ ',((00[1-9])|(0[1-9][0-9])|(1[0-3][0-9])).*';

SELECT *, FROM eicu.diagnosis WHERE icd9code ~ '^((1[4-9][0-9])|(2[0-3][0-9])).*' OR icd9code ~ ',((1[4-9][0-9])|(2[0-3][0-9])).*';

SELECT * FROM eicu.basic_demographics WHERE icu_los_hours < 0 
SELECT * FROM eicu.patient WHERE unitdischargeoffset < 0 