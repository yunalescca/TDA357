-- SHOULD FAIL

INSERT INTO COUNTRIES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas VALUES ('Sweden', 'Kungsbacka', 20000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 500);
INSERT INTO Cities VALUES ('Sweden', 'Kungsbacka', 250);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 
	'Sweden', 'Gothenburg', 20000);


-- TEST UPDATE PERSONS
-- Try to move a person between two areas where there is no road

UPDATE Persons 
SET locationarea = 'Kungsbacka', 
locationcountry = 'Sweden'
WHERE personnummer = '19990807-1337' 
AND country = 'Sweden';


-- Assert should fail, since we should not be able to update the locationarea to Kungsbacka
SELECT assert ((SELECT locationarea FROM Persons WHERE personnummer = '19990807-1337'
AND country = 'Sweden'), 'Kungsbacka')