-- SHOULD WORK

INSERT INTO COUNTRIES VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas VALUES ('Sweden', 'Kungsbacka', 20000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 500);
INSERT INTO Cities VALUES ('Sweden', 'Kungsbacka', 250);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Roads VALUES ('Sweden', 'Gothenburg', 'Sweden', 'Kungsbacka', 'Sweden', '19990807-1337', getval('roadtax'));

-- TEST UPDATE Persons
-- Move a person on a road they own, when the city has a visitbonus

UPDATE Persons
SET locationarea = 'Kungsbacka', locationcountry = 'Sweden' WHERE personnummer = '19990807-1337' AND country = 'Sweden';

-- The assert should work since the person should not pay any roadtax or city visit (since there are no hotels), but get the visistbonus from kungsbacka
-- and pay for the new road
SELECT assert ((SELECT budget FROM Persons 
	WHERE personnummer = '19990807-1337' AND country = 'Sweden'), 19793.1);