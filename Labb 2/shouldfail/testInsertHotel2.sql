-- SHOULD FAIL

INSERT INTO Countries VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 3000);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Hotels VALUES ('Maxat', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337');

--TEST Insert (tries to a hotel in a city where the owner already owns a hotel). 
-- The person's budget should not change.

INSERT INTO Hotels VALUES ('Hjolo', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337');

-- The person's budget should not change, hence the assert should fail
SELECT assert ((SELECT budget FROM Persons WHERE personnummer = '19990807-1337'), 19219.8);