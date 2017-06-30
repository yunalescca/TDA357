-- SHOULD FAIL

INSERT INTO COUNTRIES ('Sweden');

INSERT INTO Areas ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas ('Sweden', 'Kungsbacka', 20000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 500);
INSERT INTO Cities VALUES ('Sweden', 'Kungsbacka', 0);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 
	'Sweden', 'Gothenburg', 20000);

INSERT INTO Persons VALUES ('Sweden', '19930202-0000', 'Fanta Lemon', 
	'Sweden', 'Gothenburg', 0);

INSERT INTO Roads VALUES ('Sweden', 'Gothenburg', 'Sweden', 
	'Kungsbacka', 'Sweden', '19990807-1337', 10000);

-- TEST UPDATE Persons
-- Try to move a person on a road when they dont have enough money to travel on that road.
-- Should fail, violates check constraint

UPDATE Persons
SET locationarea = 'Kungsbacka', locationcountry = 'Sweden'
WHERE personnummer = '19930202-0000' AND country = 'Sweden';


-- Assert should fail since the budget can not me less than 0
SELECT assert ((SELECT budget FROm Persons 
	WHERE personnummer = '19930202-0000' AND country = 'Sweden'), -13.5);