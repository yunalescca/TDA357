-- SHOULD WORK

INSERT INTO Countries VALUES('Sweden');

INSERT INTO Areas VALUES('Sweden', 'Gothenburg', 500000);
INSERT INTO Cities VALUES('Sweden', 'Gothenburg', 10000);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);
INSERT INTO Persons VALUES ('Sweden', '19790102-9999', 'Chin Hellstorm', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Hotels VALUES ('Maxat', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337');

-- TEST Update the owner of the hotel 'Maxat'

UPDATE Hotels
SET ownerpersonnummer = '19790102-9999', ownercountry = 'Sweden'
WHERE ownerpersonnummer = '19990807-1337' AND ownercountry = 'Sweden';

SELECT assert ((SELECT ownerpersonnummer FROM hotels WHERE name = 'Maxat'),'19790102-9999');