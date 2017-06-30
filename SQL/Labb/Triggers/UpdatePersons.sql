CREATE TRIGGER UpdatePersons BEFORE UPDATE ON Persons 
FOR EACH ROW
/*WHEN (new.personnummer = old.personnummer AND new.country = old.country
	AND new.locationarea <> old.locationarea
	AND new.locationcountry <> old.locationcountry)*/
EXECUTE PROCEDURE update_persons();