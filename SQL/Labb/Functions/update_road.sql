/*Finally, make sure that only the roadtax field in a road can be updated, since the game
does not allow a road to change the start-point, end-point or owner*/

CREATE OR REPLACE FUNCTION update_road() RETURNS TRIGGER AS $$
BEGIN

	IF NOT(old.fromcountry = new.fromcountry AND old.fromarea = new.fromarea
			AND old.tocountry = new.tocountry AND old.toarea = new.toarea
			AND old.ownercountry = new.ownercountry 
			AND old.ownerpersonnummer = new.ownerpersonnummer)
		THEN RAISE EXCEPTION 'Only update of roadtax permitted';
	END IF;

	RETURN NEW;
END
$$ LANGUAGE 'plpgsql';