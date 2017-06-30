/*Persons can sell their hotel, in which case the hotel is deleted from the Hotels
table. When that happens, the person gets refunded with a fraction
getval(hotelrefund) of the price of the hotel getval(hotelprice)*/

CREATE OR REPLACE FUNCTION delete_hotel() RETURNS TRIGGER AS $$
DECLARE 
BEGIN
	
	UPDATE Persons
	SET budget = budget + (getval('hotelrefund') * getval('hotelprice'))
	WHERE personnummer = old.ownerpersonnummer AND country = old.ownercountry;
	
	RETURN OLD;
END 
$$ LANGUAGE 'plpgsql';