CREATE TABLE countries (
   name   text   NOT NULL,   
   PRIMARY KEY (name)
);

CREATE TABLE areas (
	country text NOT NULL,
	name text NOT NULL,
	population INTEGER NOT NULL CHECK (population >= 0),
	PRIMARY KEY (country, name),
	FOREIGN KEY (country) REFERENCES Countries(name)
);

CREATE TABLE cities (
	country text NOT NULL,
	name text NOT NULL,
	visitbonus numeric NOT NULL CHECK (visitbonus >= 0::numeric),
   PRIMARY KEY (country, name), 
   FOREIGN KEY (country, name) REFERENCES Areas(country, name)
);

CREATE TABLE persons (
	country TEXT NOT NULL,
	personnummer TEXT NOT NULL CHECK (personnummer ~ '[0-9]{8}-[0-9]{4}' OR (personnummer = '' AND country = '')),	
	name TEXT NOT NULL,
	locationcountry TEXT NOT NULL,
	locationarea TEXT NOT NULL,
	budget NUMERIC NOT NULL CHECK (budget >= 0::numeric),
	PRIMARY KEY (country, personnummer),
	FOREIGN KEY (country) REFERENCES Countries(name),
	FOREIGN KEY (locationcountry, locationarea) REFERENCES Areas(country, name)
);


CREATE TABLE hotels (
   name text NOT NULL,
   locationcountry text NOT NULL,
   locationname text NOT NULL,
   ownercountry text NOT NULL,
   ownerpersonnummer text NOT NULL CHECK (ownerpersonnummer ~ '[0-9]{8}-[0-9]{4}' OR (ownerpersonnummer ~ '')),
   
   PRIMARY KEY (locationcountry, locationname, ownercountry, ownerpersonnummer),
   FOREIGN KEY (locationcountry, locationname) REFERENCES Cities(country, name),
   FOREIGN KEY (ownercountry, ownerpersonnummer) REFERENCES Persons(country, personnummer)
  
);

CREATE TABLE roads (
	fromcountry text NOT NULL,
	fromarea text NOT NULL,
	tocountry text NOT NULL,
	toarea text NOT NULL,
	ownercountry text NOT NULL,
	ownerpersonnummer text NOT NULL CHECK (ownerpersonnummer ~'[0-9]{8}-[0-9]{4}' OR (ownerpersonnummer ~ '')),
	roadtax numeric NOT NULL CHECK (roadtax >= 0::numeric),

   PRIMARY KEY (fromcountry, fromarea, tocountry, toarea, ownercountry, ownerpersonnummer),
   FOREIGN KEY (fromcountry, fromarea) REFERENCES Areas(country,name),
   FOREIGN KEY (tocountry, toarea) REFERENCES Areas(country,name),
   FOREIGN KEY (ownercountry, ownerpersonnummer) REFERENCES Persons(country, personnummer)
);

CREATE TABLE towns (
   country   text   NOT NULL,
   name   text    NOT NULL,
   PRIMARY KEY (country, name),
   FOREIGN KEY (country, name) REFERENCES Areas(country, name)
);


CREATE OR REPLACE VIEW assetsummary AS(
	--AssetSummary(country, personnummer, budget, assets, reclaimable)

  SELECT country, personnummer, budget,
  (
  	-- ASSETS
  	-- the assets from the roads
  	(SELECT (COUNT(roadtax)*getval('roadprice'))
    FROM Roads
    WHERE ownercountry = country AND ownerpersonnummer = personnummer)
    --added with the assets from the hotels
    +
    (SELECT (COUNT(name)*getval('hotelprice'))
    FROM Hotels
    WHERE ownercountry = country AND ownerpersonnummer = personnummer)
  ) AS assets,

  (
  	-- RECLAIMABLE
    SELECT (COUNT(name)*getval('hotelprice')*getval('hotelrefund'))
    FROM Hotels
    WHERE ownercountry = country AND ownerpersonnummer = personnummer
  ) AS reclaimable

  FROM Persons
  WHERE country <> '' AND personnummer <> ''
  GROUP BY country, personnummer, budget
);



CREATE OR REPLACE VIEW nextmoves AS(
SELECT country AS personcountry, 
        personnummer, 
        locationcountry AS country,
        locationarea AS area, 
        destcountry, 
        destarea, 
        min(cost) AS cost

FROM 
        (
        	-- if the person owns the road
        	(SELECT 
                 fromcountry AS destcountry, 
                 fromarea AS destarea, 
                 ownercountry, 
                 ownerpersonnummer,
                 0 AS cost,
                 country,
                 personnummer,
                 locationarea,
                 locationcountry
                 FROM roads, persons
                 WHERE locationarea = toArea
                 AND locationcountry = toCountry
                 AND (country<>'' AND personnummer<>'')
                 AND personnummer = ownerpersonnummer
                 AND budget >= roadtax)

          UNION
          		-- reversed road
                (SELECT 
                 tocountry AS destcountry, 
                 toarea AS destarea, 
                 ownercountry, 
                 ownerpersonnummer,
                 0 AS cost,
                 country,
                 personnummer,
                 locationarea,
                 locationcountry
                 FROM roads, persons
                 WHERE locationarea = fromArea
                 AND locationcountry = fromCountry
                 AND (country<>'' AND personnummer<>'')
                 AND personnummer = ownerpersonnummer
                 AND budget >= roadtax)

            UNION

        	-- if the person does not own the road
        	(SELECT 
                 fromcountry AS destcountry, 
                 fromarea AS destarea, 
                 ownercountry, 
                 ownerpersonnummer,
                 roadtax AS cost,
                 country,
                 personnummer,
                 locationarea,
                 locationcountry
                 FROM roads, persons
                 WHERE locationarea = toArea
                 AND locationcountry = toCountry
                 AND (country<>'' AND personnummer<>'')
                 AND budget >= roadtax)

          UNION
          		-- reversed road
                (SELECT 
                 tocountry AS destcountry, 
                 toarea AS destarea, 
                 ownercountry, 
                 ownerpersonnummer,
                 roadtax AS cost,
                 country,
                 personnummer,
                 locationarea,
                 locationcountry
                 FROM roads, persons
                 WHERE locationarea = fromArea
                 AND locationcountry = fromCountry
                 AND (country<>'' AND personnummer<>'')
                 AND budget >= roadtax)

                ) AS nextmovesview

      GROUP BY country, personnummer, locationcountry, locationarea, destcountry, destarea

     
    );





   /*When a road A->B is added, you must ensure that the reverse road B->A is n
not already present for the same owner. When a road is created by a Person, ensure that Person is located at either
the start or end point of that road, and deduct the price of the road
(getval('roadprice')) from the Persons budget*/

CREATE OR REPLACE FUNCTION insert_road() RETURNS TRIGGER AS $$
BEGIN

	IF EXISTS(SELECT 1
		FROM Roads
		WHERE fromCountry = new.toCountry 
		AND toCountry = new.fromCountry
		AND fromArea = new.toArea 
		AND toArea = new.fromArea
		AND ownerpersonnummer = new.ownerpersonnummer 
		AND ownercountry = new.ownerCountry)
		THEN RAISE EXCEPTION 'Reverse road is already present for this owner.';
	END IF;

	IF (new.toarea = new.fromarea AND new.tocountry = new.fromcountry )
 		THEN RAISE EXCEPTION'Road can not go to the same area as started from';
	END IF;

	IF EXISTS(SELECT 1
		FROM Roads
		WHERE fromCountry = new.fromCountry AND toCountry = new.toCountry
		AND fromArea = new.fromArea 
		AND toArea = new.toArea
		AND ownerpersonnummer = new.ownerpersonnummer 
		AND ownercountry = new.ownerCountry)
		THEN RAISE EXCEPTION 'This road is already present for this owner.';
	END IF;

	IF NOT EXISTS(SELECT *
		FROM Persons
		WHERE (locationCountry = new.fromCountry 
			AND locationArea = new.fromArea
			AND personnummer = new.ownerpersonnummer 
			AND country = new.ownercountry)

		OR (locationCountry = new.toCountry 
			AND locationArea = new.toArea
			AND personnummer = new.ownerpersonnummer 
			AND country = new.ownercountry)
		-- in case the person is the government
		OR (country = '' AND personnummer = '')
		
		)

		THEN RAISE EXCEPTION 'You must be located in the area to buy a road';
	END IF;


	IF((SELECT budget 
		FROM persons 
		WHERE country = new.ownercountry
		AND personnummer = new.ownerpersonnummer
		AND personnummer <>''
		AND country <> '') < getval('roadprice'))
		THEN RAISE EXCEPTION 'The player can not afford this';
	END IF;

	UPDATE Persons
	SET budget = budget - getval('roadprice')
	WHERE country = new.ownerCountry 
	AND country <> ''
	AND personnummer = new.ownerpersonnummer
	AND personnummer <> '';

	RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER insertRoad BEFORE INSERT ON Roads
FOR EACH ROW
EXECUTE PROCEDURE insert_road();

/*Finally, make sure that only the roadtax field in a road can be updated,
since the game does not allow a road to change the start-point,
end-point or owner*/

CREATE OR REPLACE FUNCTION update_road() RETURNS TRIGGER AS $$
BEGIN
	IF NOT(old.fromCountry = new.fromCountry 
		AND old.fromarea = new.fromarea 
		AND old.toCountry = new.toCountry
		AND old.toarea = new.toarea 
		AND old.ownerCountry = new.ownerCountry
		AND old.ownerpersonnummer = new.ownerpersonnummer)
		THEN RAISE EXCEPTION 'Only update of roadtax permitted';
	END IF;
	RETURN new;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER updateRoad BEFORE UPDATE ON Roads
FOR EACH ROW
EXECUTE PROCEDURE update_road();

/*Persons can sell their hotel, in which case the hotel is deleted
from the Hotels table. When that happens, the person get refunded with 
a fraction getval('hotelrefund') of the price of the hotel
getval('hotelprice')*/

CREATE OR REPLACE FUNCTION delete_hotel() RETURNS TRIGGER AS $$
DECLARE
BEGIN

	UPDATE Persons
	SET budget = budget + (getval('hotelrefund')*getval('hotelprice'))
	WHERE personnummer = old.ownerpersonnummer AND country = old.ownercountry
	AND personnummer <> '' AND country <> '';

	RETURN OLD; 

END
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER deleteHotel BEFORE DELETE ON Hotels
FOR EACH ROW
EXECUTE PROCEDURE delete_hotel();

/* Hotels can't be moved to a new city, but they can change owner.  */

CREATE OR REPLACE FUNCTION update_hotel() RETURNS TRIGGER AS $$
BEGIN

	IF NOT(old.name = new.name 
		AND old.locationcountry = new.locationcountry
		AND old.locationname = new.locationname
		)
		THEN RAISE EXCEPTION 'It is not possible to move a hotel to another city.';
	END IF;	

	IF EXISTS ( SELECT 1
				FROM Hotels
				WHERE ownerpersonnummer = new.ownerpersonnummer
				AND ownercountry = new.ownercountry
				AND locationname = new.locationname)
				THEN RAISE EXCEPTION 'This person already owns a hotel in this city';
	END IF;


	RETURN new;
END
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER updateHotel BEFORE UPDATE ON Hotels
FOR EACH ROW
EXECUTE PROCEDURE update_hotel();

/*When a hotel is created, the price of the hotel must deducted from that 
person's budget. Hotels can't be moved to a new city, but they can change
owner. Keep in mind that a person can only own one hotel per city.

Persons can sell their hotel, in which case the hotel is deleted
from the Hotels table. When that happens, the person get refunded with 
a fraction getval('hotelrefund') of the price of the hotel
getval('hotelprice')*/

CREATE OR REPLACE FUNCTION insert_hotel() RETURNS TRIGGER AS $$
BEGIN 

	IF EXISTS(SELECT 1
		FROM Towns
		WHERE new.locationcountry = country
		AND new.locationname = name)
		THEN RAISE EXCEPTION 'Hotels only allowed in cities.';
	END IF;
		
	IF EXISTS( SELECT 1
			FROM Hotels
			WHERE ownerpersonnummer = new.ownerpersonnummer
			AND ownercountry = new.ownercountry
			AND locationname = new.locationname)
		THEN RAISE EXCEPTION 'The person already owns a hotel in this city.';
	END IF;

	IF((SELECT budget 
		FROM persons 
		WHERE country = new.ownercountry
		AND personnummer = new.ownerpersonnummer
		AND personnummer <>''
		AND country <> '') < getval('hotelprice'))
	THEN RAISE EXCEPTION 'The player can not afford this';
	END IF;

	UPDATE Persons
	SET budget = budget - getval('hotelprice')
	WHERE new.ownerpersonnummer = personnummer 
		AND new.ownercountry = country;



	RETURN new;

END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER insertHotel BEFORE INSERT ON Hotels
FOR EACH ROW
EXECUTE PROCEDURE insert_hotel();




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
		WHERE (fromcountry = old.locationcountry 
			AND fromarea = old.locationarea 
			AND tocountry = new.locationcountry 
			AND toarea = new.locationarea)

			OR
			(fromcountry = new.locationcountry 
			AND fromarea = new.locationarea 
			AND tocountry = old.locationcountry 
			AND toarea = old.locationarea) 
			)
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
			OR (ownercountry = '' 
			AND ownerpersonnummer = '' 
			AND fromcountry = old.locationcountry 
			AND fromarea = old.locationarea 
			AND tocountry = new.locationcountry 
			AND toarea = new.locationarea)) 

	THEN
		raise info 'Person did not own road';

		IF(old.budget < (SELECT min(roadtax) 
				FROM roads 
				WHERE (toarea = new.locationarea 
					AND fromarea = old.locationarea 
					AND tocountry = new.locationcountry 
					AND fromcountry = old.locationcountry)
					OR(toarea = old.locationarea
						AND fromarea = new.locationarea
						AND tocountry = old.locationcountry
						AND fromcountry = new.locationcountry)
					))
		THEN RAISE EXCEPTION 'The person can not afford it.';
		END IF;

		new.budget := new.budget - 
			(SELECT min(roadtax) 
				FROM roads 
				WHERE (toarea = new.locationarea 
					AND fromarea = old.locationarea 
					AND tocountry = new.locationcountry 
					AND fromcountry = old.locationcountry)
					OR
					(toarea = old.locationarea 
					AND fromarea = new.locationarea 
					AND tocountry = old.locationcountry 
					AND fromcountry = new.locationcountry)
					);
		

		roadowner := (SELECT ownerpersonnummer 
			FROM roads 
			WHERE (toarea = new.locationarea 
				AND fromarea = old.locationarea 
				AND tocountry = new.locationcountry 
				AND fromcountry = old.locationcountry)
				OR
				(toarea = old.locationarea 
				AND fromarea = new.locationarea 
				AND tocountry = old.locationcountry 
				AND fromcountry = new.locationcountry) 
			ORDER BY roadtax ASC 
			LIMIT 1); 

		roadownercountry := (SELECT ownercountry 
			FROM roads 
			WHERE (toarea = new.locationarea 
				AND fromarea = old.locationarea 
				AND tocountry = new.locationcountry 
				AND fromcountry = old.locationcountry) 
				OR
				(toarea = old.locationarea 
				AND fromarea = new.locationarea 
				AND tocountry = old.locationcountry 
				AND fromcountry = new.locationcountry)
				ORDER BY roadtax ASC 
				LIMIT 1); 

		UPDATE persons 
		SET budget = budget + 
			(SELECT min(roadtax) 
				FROM roads 
				WHERE (toarea = new.locationarea 
					AND fromarea = old.locationarea 
					AND tocountry = new.locationcountry 
					AND fromcountry = old.locationcountry)
				OR
					(toarea = old.locationarea 
					AND fromarea = new.locationarea 
					AND tocountry = old.locationcountry 
					AND fromcountry = new.locationcountry)
				)
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

		new.budget := new.budget-getval('cityvisit');

		UPDATE persons 
		SET budget = budget + payment 
	--	FROM persons 
		WHERE (personnummer, country) IN ((SELECT hotels.ownerpersonnummer, hotels.ownercountry 
			FROM hotels WHERE hotels.locationname = new.locationarea
			AND hotels.locationcountry = new.locationcountry)
			EXCEPT (SELECT old.personnummer, old.country));


		IF EXISTS(SELECT 1 
			FROM hotels 
			WHERE (hotels.locationname = new.locationarea
				AND hotels.locationcountry = new.locationcountry 
				AND hotels.ownercountry = new.country
				AND hotels.ownerpersonnummer = new.personnummer)) 

		THEN
			new.budget := new.budget + payment;

		END IF;

	END IF; 

	UPDATE Cities 
	SET visitbonus = 0 
	WHERE name = new.locationarea 
		AND country = new.locationcountry; 

	RETURN NEW; 

END
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER updatePersons BEFORE UPDATE ON Persons
FOR EACH ROW
WHEN (new.locationarea <> old.locationarea
		OR new.locationcountry <> old.locationcountry
	)
EXECUTE PROCEDURE update_persons();
