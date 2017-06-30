CREATE OR REPLACE FUNCTION update_persons() RETURNS TRIGGER AS $$          
DECLARE
	payment numeric; 
	roadowner text; 
	roadownercountry text; 
	numofhotels integer; 
BEGIN 

	IF NOT (old.budget = new.budget)
		THEN raise info 'Old budget is new budget';
		RETURN NEW;
	END IF;		

	IF (old.locationarea = new.locationarea
		AND old.locationcountry = new.locationcountry)
		THEN raise info 'Old location is new location';
		RETURN NEW;
	END IF;

	IF NOT EXISTS(SELECT 1 
		FROM roads 
		WHERE fromcountry = old.locationcountry 
			AND fromarea = old.locationarea 
			AND tocountry = new.locationcountry 
			AND toarea = new.locationarea) 
		THEN RAISE EXCEPTION 'There is no road between these two areas'; 
	END IF; 

	IF NOT EXISTS(SELECT 1 
		FROM roads 
		WHERE (ownerpersonnummer = new.personnummer 
			AND ownercountry = new.country 
			AND fromcountry = old.locationcountry
			AND fromarea = old.locationarea 
			AND tocountry = new.locationcountry 
			AND toarea = new.locationarea)
			OR (ownercountry = ' ' 
			AND ownerpersonnummer = ' ' 
			AND fromcountry = old.locationcountry 
			AND fromarea = old.locationarea 
			AND tocountry = new.locationcountry 
			AND toarea = new.locationarea)) 

	THEN
		raise info 'Person did not own road';
		new.budget := new.budget - 
			(SELECT min(roadtax) 
				FROM roads 
				WHERE toarea = new.locationarea 
					AND fromarea = old.locationarea 
					AND tocountry = new.locationcountry 
					AND fromcountry = old.locationcountry);

		roadowner := (SELECT ownerpersonnummer 
			FROM roads 
			WHERE toarea = new.locationarea 
				AND fromarea = old.locationarea 
				AND tocountry = new.locationcountry 
				AND fromcountry = old.locationcountry 
			ORDER BY roadtax ASC 
			LIMIT 1); 

		roadownercountry := (SELECT ownercountry 
			FROM roads 
			WHERE toarea = new.locationarea 
				AND fromarea = old.locationarea 
				AND tocountry = new.locationcountry 
				AND fromcountry = old.locationcountry 
				ORDER BY roadtax ASC 
				LIMIT 1); 

		UPDATE persons 
		SET budget = budget + 
			(SELECT min(roadtax) 
				FROM roads 
				WHERE toarea = new.locationarea 
					AND fromarea = old.locationarea 
					AND tocountry = new.locationcountry 
					AND fromcountry = old.locationcountry)
			WHERE personnummer = roadowner AND country = roadownercountry;

	END IF; 
	
	IF EXISTS(SELECT 1
				FROM Cities
				WHERE new.locationarea = name AND new.locationcountry = country)
	THEN
		raise info 'Person is moving to a city';
		new.budget := new.budget + 
		(SELECT visitbonus from cities
			WHERE name = new.locationarea 
				AND country = new.locationcountry); 

	numofhotels := (SELECT count(ownerpersonnummer) 
		FROM hotels 
		WHERE hotels.locationname = new.locationarea 
			AND hotels.locationcountry = new.locationcountry); 
	END IF;

	IF (numofhotels > 0) 
	THEN 
		raise info 'There is at least one hotel in this city';
		payment := getval('cityvisit') / numofhotels; 

		UPDATE persons 
		SET budget = budget + payment 
		FROM hotels 
		WHERE hotels.locationname = new.locationarea
			AND hotels.locationcountry = new.locationcountry
			AND hotels.ownerpersonnummer = personnummer 
			AND hotels.ownercountry = country;

		new.budget := new.budget - getval('cityvisit');

	END IF; 

	UPDATE Cities 
	SET visitbonus = 0 
	WHERE name = new.locationarea 
		AND country = new.locationcountry; 

	RETURN NEW; 

END
$$ LANGUAGE 'plpgsql';