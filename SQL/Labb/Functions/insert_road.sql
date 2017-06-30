/*When a road A->B is added, you must ensure that the reverse road B->A is ont already 
present for the same owner. When a road is created by a Person, ensure that the Person
is located at either the start-point or end-point of that road, and deduct the price
of the road (getval('roadprice')) from that Person's budget*/

CREATE OR REPLACE FUNCTION insert_road() RETURNS TRIGGER AS $$
BEGIN
	/*elsif?*/
	IF EXISTS(SELECT 1
		FROM Roads
		WHERE fromCountry = new.tocountry AND fromArea = new.toarea
			AND toCountry = new.fromcountry AND toArea = new.fromarea
			AND ownerCountry = new.ownercountry 
			AND ownerPersonnummer = new.ownerpersonnummer)
		THEN RAISE EXCEPTION 'Reverse already present for this owner';
	END IF;

	IF EXISTS(SELECT 1
		FROM Roads
		WHERE fromCountry = new.fromcountry AND fromArea = new.fromarea
			AND toCountry = new.tocountry AND toArea = new.toarea
			AND ownerCountry = new.ownercountry 
			AND ownerPersonnummer = new.ownerpersonnummer)
		THEN RAISE EXCEPTION 'This owner already owns a road like this';
	END IF;

	IF NOT EXISTS(SELECT 1
		FROM Persons
		WHERE locationcountry = new.fromCountry AND locationarea = new.fromArea
			AND personnummer = new.ownerpersonnummer AND country = new.ownercountry
			OR locationcountry = new.toCountry AND locationarea = new.toArea)
			AND personnummer = new.ownerpersonnummer AND country = new.ownercountry
		THEN RAISE EXCEPTION 'You must be located in the area to buy a road';
	END IF;

	UPDATE Persons
	SET budget = budget - getval('roadprice')
	WHERE country = new.ownercountry AND personnummer = new.ownerpersonnummer;

	RETURN NEW;
END
$$ LANGUAGE 'plpgsql';