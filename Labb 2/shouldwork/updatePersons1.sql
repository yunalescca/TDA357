-- SHOULD WORK

INSERT INTO COUNTRIES VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas VALUES ('Sweden', 'Kungsbacka', 20000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 500);
INSERT INTO Cities VALUES ('Sweden', 'Kungsbacka', 0);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Roads VALUES ('Sweden', 'Gothenburg', 'Sweden', 
	'Kungsbacka', 'Sweden', '19990807-1337', getval('roadtax'));

-- TEST UPDATE Persons
-- Move a person on a road the own, so they travel for free. But since they bought the road,
-- the budget should be updated and decreased by the roadprice (20 000- 456.9) = 
UPDATE Persons
SET locationarea = 'Kungsbacka', locationcountry = 'Sweden' WHERE personnummer = '19990807-1337' AND country = 'Sweden';

SELECT assert ((SELECT budget FROm Persons 	WHERE personnummer = '19990807-1337' AND country = 'Sweden'), 19543.1);