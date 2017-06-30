-- SHOULD FAIL

INSERT INTO Countries VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 3000);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

--TEST Insert (tries to insert a hotel in a town, not a city). 
-- The person's budget should not change.

INSERT INTO Hotels VALUES ('Maxat', 'Sweden', 'Hjo', 'Sweden', '19990807-1337');

-- The person's budget should not change, hence the assert should fail
SELECT assert ((SELECT budget FROM Persons WHERE personnummer = '19990807-1337'), 19219.8);