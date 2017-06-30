CREATE OR REPLA
´
CE FUNCTION insert_itinerary() RETURNS TRIGGER AS $$
DECLARE
	ticket_price INTEGER;
	new_reference INTEGER;
BEGIN
	-- First check that there are at least one seat left on the flight
	IF NOT 0 < (SELECT numberOfFreeSeats FROM test_AvailableFlights WHERE flight = NEW.flight)
		THEN RAISE EXCEPTION 'Flight fully booked';
	END IF;

	--ticket_price := new.price; -- does not work because when I insert into Itineraries, it does not have a column named "price"
	ticket_price := (SELECT price FROM test_AvailableFlights WHERE flight = NEW.flight);
	new_reference := ( 
		SELECT COALESCE (MAX (reference), 0) + 1 -- coalesce: if no reference already exists (is null), then choose 0 as starting reference 
		FROM test_Bookings
		WHERE flight = NEW.flight);

	INSERT INTO test_Bookings (reference, flight, date, passengers, price)
		VALUES (new_reference, NEW.flight, NEW.date, NEW.passengers, ticket_price);

	UPDATE test_AvailableFlights
	SET price = price + 50, numberOfFreeSeats = numberOfFreeSeats-1 -- all sets on same row
	WHERE flight = NEW.flight;

	RETURN NEW;
END
$$ LANGUAGE 'plpgsql';
