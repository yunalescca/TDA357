-- SHOULD FAIL

INSERT INTO Countries ('Sweden');
INSERT INTO Countries ('England');

INSERT INTO Areas ('Sweden', 'Gothenburg', 500000);
INSERT INTO Cities ('Sweden', 'Gothenburg', 10000);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);
INSERT INTO Persons VALUES ('Sweden', '19790102-9999', 'Chin Hellstorm', 'England', 'Gothenburg', 20000);

INSERT INTO Hotels VALUES ('Maxat', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337');
INSERT INTO Hotels VALUES ('Opa', 'Sweden', 'Gothenburg', 'England', '19790102-9999');


-- TEST UPDATE Should not be possible to change owner, 
-- when the new owner already owns a hotel in the same city

UPDATE Hotels
SET ownerpersonnummer = '19790102-9999', ownercountry = 'England'
WHERE ownerpersonnummer = '19990807-1337' AND ownercountry = 'Sweden';

-- Since one can not update the location of the hotel,
-- this assert should fail since the personnummer wont be updated
SELECT assert ((SELECT ownerpersonnummer FROM hotels WHERE name = 'Maxat'),'19790102-9999');