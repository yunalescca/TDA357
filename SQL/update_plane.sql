CREATE OR REPLACE FUNCTION update_plane() RETURNS TRIGGER AS $$
DECLARE
	size_difference INTEGER;

BEGIN
	size_difference := (SELECT capacity FROM Planes WHERE regnr = new.plane)
		- (SELECT capacity FROM Planes WHERE regnr = old.plane);

	IF(new.numberOfFreeSeats + size_difference < 0) THEN
		RAISE EXCEPTION 'Plane too small';

	ELSE new.numberoffreeseats := new.numberoffreeseats + size_difference;
	END IF; 

	RETURN NEW;
END
$$ LANGUAGE 'plpgsql';
