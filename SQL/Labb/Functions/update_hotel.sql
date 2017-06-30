/*Change the owner of a hotel
This function checks if the new owner does not already own a hotel in this city*/

CREATE OR REPLACE FUNCTION update_hotel() RETURNS TRIGGER AS $$
DECLARE 
BEGIN
	
	IF NOT(old.name = new.name AND old.locationcountry = new.locationcountry
			AND old.locationname = new.locationname)
		THEN RAISE EXCEPTION 'It is not possible to move a hotel to another city';
	END IF;
	
	IF EXISTS(SELECT 1
				FROM Hotels
				WHERE ownerpersonnummer = new.ownerpersonnummer 
					AND ownercountry = new.ownercountry
					AND locationname = new.locationname)
		THEN RAISE EXCEPTION 'This person already owns a hotel in this city';
	END IF;

	RETURN NEW;
END 
$$ LANGUAGE 'plpgsql';