-- SHOULD WORK

-- Inserting a road that is possible to insert.
-- Assuming that this person is at the end point

INSERT INTO Countries VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas VALUES ('Sweden', 'Hjo', 10000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 3000);

INSERT INTO Towns VALUES ('Sweden', 'Hjo');

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

-- Testing insert trigger (updating budget)

INSERT INTO Roads VALUES ('Sweden', 'Hjo', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337', getval('roadtax'));

SELECT assert ((SELECT budget FROM persons WHERE personnummer = '19990807-1337'), 19543.1);