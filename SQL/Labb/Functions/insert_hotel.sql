CREATE OR REPLACE FUNCTION insert_hotel() RETURNS TRIGGER AS $$
DECLARE
BEGIN

	IF EXISTS(SELECT 1
			FROM Towns
			WHERE new.locationcountry = country
				AND new.locationname = name)
		THEN RAISE EXCEPTION 'Hotels only allowed in Cities!';

	IF EXISTS(SELECT 1
			FROM Hotels
			WHERE ownerpersonnummer = new.ownerpersonnummer 
				AND ownercountry = new.ownercountry
				AND locationname = new.locationname)
		THEN RAISE EXCEPTION 'This person already owns a hotel in this city';
	END IF;

	UPDATE Persons
	SET budget = budget - getval('hotelprice')
	WHERE new.ownerpersonnummer = personnummer 
		AND new.ownercountry = country;

	RETURN new;
END
$$ LANGUAGE 'plpgsql'