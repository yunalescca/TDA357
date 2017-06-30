-- SHOULD FAIL

-- Inserting a road that is possible to insert.
-- Assuming that this person is at start- or en point

INSERT INTO Countries VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas VALUES ('Sweden', 'Stockholm', 1000000);
INSERT INTO Areas VALUES ('Sweden', 'Hjo', 10000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 3000);
INSERT INTO Cities VALUES ('Sweden', 'Stockholm', 200);

INSERT INTO Towns VALUES ('Sweden', 'Hjo');

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Roads VALUES ('Sweden', 'Gothenburg', 'Sweden', 'Hjo', 'Sweden', '19990807-1337', getval('roadtax'));


-- TEST Insert reversed road, will fail.
INSERT INTO Roads VALUES ('Sweden', 'Hjo', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337', getval('roadtax'));

-- The person's budget should not change, hence the assert should fail
SELECT assert ((SELECT budget FROM Persons WHERE personnummer = '19990807-1337'), 19543.1)

