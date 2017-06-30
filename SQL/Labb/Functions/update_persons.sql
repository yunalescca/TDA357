/*A person is always located in an Area. When a person moves, you must ensure that
there is a road between the old and the new area that Person is in. If there are multiple
roads, use a free one if possible (a public road, or a road owned by that person),
otherwise find the cheapest road and deduct the roadtax from the Person's budget before
updating the Person's location to the new area.

When a person moves to a city, and there are hotels in that city, deduct getval('cityvisit')
for visiting a city from the Person's budget and transfer that money equally to all hotel-
owners that have a hotel in that city.

Finally, if a city has a visiting bonus, transfer it to the visiting person.*/

CREATE OR REPLACE FUNCTION update_persons() RETURNS TRIGGER AS $$
DECLARE
	payment INTEGER;
	roadowner TEXT;
	roadownercountry TEXT;
	numberOfHotels INTEGER;
BEGIN	

	-- if no road exists between these two areas
	IF NOT EXISTS(SELECT 1 
			FROM Roads
			WHERE fromcountry = old.locationcountry, fromarea = old.locationarea,
			tocountry = new.locationcountry, toarea = new.locationarea)
		THEN RAISE EXCEPTION 'There is no road between these two areas';
	END IF;

	-- if neither person nor the government owns the road
	IF NOT EXISTS(SELECT 1
			FROM Roads
			WHERE ownerpersonnummer = ' ' AND ownercountry = ' ' 
			OR ownerpersonnummer = new.personnummer AND ownercountry = new.country)

		--Then find the lowest roadtax and subtract that from budget
		THEN
			UPDATE Persons
			SET budget = budget - (SELECT min(roadtax) 
										FROM Roads
										WHERE fromcountry = old.locationcountry, 
										fromarea = old.locationarea,
										tocountry = new.locationcountry, 
										toarea = new.locationarea)
			WHERE personnummer = new.personnummer AND country = new.country;

		-- Add money to the person who owned the road we traveled on
			roadowner := (SELECT ownerpersonnummer
							FROM Roads
							ORDER BY roadtax ASC
							LIMIT 1);

			roadownercountry := (SELECT ownercountry
									FROM Roads
									ORDER BY roadtax ASC
									LIMIT 1);

			UPDATE Persons
			SET budget = budget + (SELECT min(roadtax) 
										FROM Roads
										WHERE fromcountry = old.locationcountry, 
										fromarea = old.locationarea,
										tocountry = new.locationcountry, 
										toarea = new.locationarea)
			WHERE personnummer = roadowner AND country = roadownercountry;

	END IF;

	-- Update Persons budget = budget + visitbonus - cityvisit
	UPDATE Persons
	SET budget = budget + (
			SELECT visitbonus
			FROM Cities
			WHERE name = new.locationarea AND country = new.locationcountry) 
			- getval('cityvisit')
	WHERE personnummer = new.personnummer AND country = new.country;

	numberOfHotels := (SELECT COUNT(ownerpersonnummer) 
										FROM hotels
										WHERE hotels.locationcountry = new.locationcountry
										AND hotels.locationname = new.locationarea);


	IF(numberOfHotels > 0)
		-- fetch the payment for each hotel owner
		THEN payment := getval('cityvisit') / numberOfHotels;
				-- Update the hotel owners' budget
				
			UPDATE Persons
			SET budget = budget + payment
			FROM hotels
			WHERE hotels.locationcountry = new.locationcountry
				AND hotels.locationname = new.locationarea;
	END IF;

	-- Set this city visit bonus to 0
	UPDATE Cities
	SET visitbonus = 0
	WHERE name = new.locationarea AND country = new.locationcountry;


END
$$ LANGUAGE 'plpgsql';