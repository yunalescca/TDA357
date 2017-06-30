-- SHOULD NOT WORK


INSERT INTO Countries VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);
INSERT INTO Areas VALUES ('Sweden', 'Hjo', 10000);
INSERT INTO Areas VALUES ('Sweden', 'Stockholm', 1000000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 3000);
INSERT INTO Cities VALUES ('SWeden', 'Stockholm', 2);

INSERT INTO Towns VALUES ('Sweden', 'Hjo');

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Roads VALUES ('Sweden', 'Gothenburg', 'Sweden', 'Hjo', 'Sweden', '19990807-1337', getval('roadtax'));

-- Testing if it is possible to update the roadtax, and toarea

UPDATE Roads 
SET roadtax = 20, toarea = 'Stockholm'
WHERE ownerpersonnummer = '19990807-1337';


-- Since the toarea can not be changed, the table didnt update, hence the roadtax should still be
-- the original value 13.5, and therefore this assert will fail

SELECT assert ((SELECT roadtax FROM Roads WHERE ownerpersonnummer = '19990807-1337'), 20);
