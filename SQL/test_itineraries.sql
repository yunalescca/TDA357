CREATE OR REPLACE VIEW test_Itineraries AS 
SELECT reference, passenger, flight, date, departure.city AS departure, destination.city AS destination
FROM test_Bookings
JOIN test_flights  ON test_Bookings.flight = test_flights.code
JOIN test_Airports AS departure ON departure.code = test_flights.origin
JOIN test_Airports AS destination ON destination.code = test_flights.destination;