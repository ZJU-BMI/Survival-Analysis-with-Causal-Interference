SELECT * FROM d_labitems WHERE itemid IN (
			50907,-- Total cholesterol 
			51000,-- Triglycerides
			50905,-- Low-density lipoprotein cholesterol
			50904 -- High-density lipoprotein cholesterol
		) ;

SELECT 
	itemid, 
	valueuom, 
	"value", 
	valuenum, 
	ref_range_lower, 
	ref_range_upper 
	FROM labevents 
	WHERE 
		itemid IN (
			51498,-- Specific Gravity
			52045,-- pH, Urine
			51484,-- Ketone
			51516,-- WBC
			51487,-- Nitrite
			51102,-- Total Protein, Urine
			51478,-- Glucose
			51464,-- Bilirubin
			51514 -- Urobilinogen
		) ORDER BY itemid;

SELECT * FROM d_labitems WHERE LOWER(label) like '%apoa%'
