CREATE TRIGGER InsertItinerary INSTEAD OF INSERT ON test_Itineraries 
FOR EACH ROW EXECUTE PROCEDURE insert_itinerary();