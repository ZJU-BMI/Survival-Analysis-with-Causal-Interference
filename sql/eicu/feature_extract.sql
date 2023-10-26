		SELECT patientunitstayid as "id",
					 acute_resp_failure as arespf,
					 acute_renal_failure as arenalf,
					 pneu,
					 gender, age, icu_stay, hosp_mort as "label", weight, height,
				CASE WHEN hosp_mort = 1 AND prior1 < prior2 AND prior1 < prior3 THEN 1 
						 WHEN hosp_mort = 1 AND prior2 < prior1 AND prior2 < prior3 THEN 2
						 WHEN hosp_mort = 1 AND prior3 < prior1 AND prior3 < prior2 THEN 3 
						 ELSE 0 END AS death_reason 
		FROM comp_risks_pats r
		WHERE ctid in (SELECT MIN(ctid) FROM comp_risks_pats GROUP BY patientunitstayid)
		AND age < 90 AND icu_stay >= 10 AND icu_stay <= 200