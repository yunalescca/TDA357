CREATE TRIGGER UpdateHotel BEFORE UPDATE ON Hotels
FOR EACH ROW
WHEN (old.ownerpersonnummer <> new.ownerpersonnummer
	AND old.ownercountry <> new.ownercountry)
EXECUTE PROCEDURE update_hotel();