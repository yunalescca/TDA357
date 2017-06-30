CREATE OR REPLACE VIEW AssetSummary AS 
WITH 
	hotel AS (
		SELECT (COUNT(ownercountry) * getval('hotelprice'))  AS hotelCost,
			   (COUNT(ownercountry) * getval('hotelrefund')) AS hotelRefund
		FROM hotels, persons
		WHERE hotels.ownercountry = persons.country AND hotels.ownerpersonnummer = persons.personnummer
	),

	road AS (
		SELECT (COUNT(ownercountry) * getval('roadprice')) AS roadCost
		FROM roads, persons
		WHERE roads.ownercountry = persons.country AND roads.ownerpersonnummer = persons.country
	),

	person AS (
		SELECT country, personnummer, budget, (hotelCost + roadCost) AS assets, hotelrefund AS reclaimable
		FROM persons, hotel, road
	)

SELECT * FROM person;