-- SHOULD FAIL

INSERT INTO Countries ('Sweden');

INSERT INTO Areas ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas ('Sweden', 'Stockholm', 1000000);

INSERT INTO Cities ('Sweden', 'Gothenburg', 10000);
INSERT INTO Cities ('Sweden', 'Stockholm', 1);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);
INSERT INTO Persons VALUES ('Sweden', '19790102-9999', 'Chin Hellstorm', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Hotels VALUES ('Maxat', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337');

-- TEST UPDATE Should not be possible to update the location

UPDATE Hotels
SET ownerpersonnummer = '19790102-9999', ownercountry = 'Sweden', locationname = 'Stockholm'
WHERE ownerpersonnummer = '19990807-1337' AND ownercountry = 'Sweden';

-- Since one can not update the location of the hotel,
-- this assert should fail since the personnummer wont be updated
SELECT assert ((SELECT ownerpersonnummer FROM hotels WHERE name = 'Maxat'),'19790102-9999');