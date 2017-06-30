-- SHOULD WORK

INSERT INTO COUNTRIES VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas VALUES ('Sweden', 'Kungsbacka', 20000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 500);
INSERT INTO Cities VALUES ('Sweden', 'Kungsbacka', 0);

-- Road owner and traveler
INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 200000);
-- Hotel owner
INSERT INTO Persons VALUES ('Sweden', '19940404-0000', 'Cola Zero', 'Sweden', 'Kungsbacka', 200000);

INSERT INTO Roads VALUES ('Sweden', 'Gothenburg', 'Sweden', 'Kungsbacka', 'Sweden', '19990807-1337', getval('roadtax'));

INSERT INTO Hotels VALUES ('BestHotel', 'Sweden', 'Kungsbacka', 'Sweden', '19940404-0000');


-- TEST UPDATE Persons
-- Move a person on a road they own, to a city that has one hotel but no citybonus.

UPDATE Persons
SET locationarea = 'Kungsbacka', locationcountry = 'Sweden'
WHERE personnummer = '19990807-1337' AND country = 'Sweden';

-- The assert should work since the person should not pay any roadtax, but get the visitbonus from kungsbacka (200000-102030.3-456.9)
-- and also pays for the new road
SELECT assert ((SELECT budget FROM Persons 
	WHERE personnummer = '19990807-1337' AND country = 'Sweden'), 97512.8);


-- The assert should work, since there is only one hotelowner in the city, he/she should get all the visistbonus (200000+102030.3-789.2)
-- and also pay for the new hotel
SELECT assert ((SELECT budget FROM Persons
	WHERE personnummer = '19940404-0000' and country = 'Sweden'), 301241.1)

