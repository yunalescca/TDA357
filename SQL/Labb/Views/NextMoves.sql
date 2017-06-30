CREATE OR REPLACE VIEW nextmoves AS 
WITH R AS (
	SELECT * 
	FROM roads
	UNION
	SELECT toCountry AS fromCountry,  toArea AS fromArea,
		fromCountry AS toCountry, fromArea AS toArea, ownercountry,
		ownerpersonnummer, roadtax
	FROM roads),

	P AS (
	SELECT country AS personcountry, personnummer,
		locationcountry AS country, locationarea AS area, MIN(roadtax) AS cost,
		toCountry AS destcountry, toArea AS destarea
	FROM persons, R
	WHERE locationcountry = R.fromCountry AND locationarea = R.fromArea
	GROUP BY destcountry, destarea, personnummer, personcountry)

SELECT * FROM P;