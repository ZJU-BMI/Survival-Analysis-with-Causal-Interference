SELECT ctid, subject_id, hadm_id, prior1, prior2, prior3, prior4, prior5
FROM comp_risks_pats crp
WHERE ctid in (select min(ctid) from comp_risks_pats group by subject_id, hadm_id) 
AND age >= 30 AND hosp_stay <= 50 AND hosp_stay > 5 AND dod IS NOT NULL
		