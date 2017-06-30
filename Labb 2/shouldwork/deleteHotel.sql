-- SHOULD WORK

INSERT INTO Countries VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 3000);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

INSERT INTO Hotels VALUES ('Maxat', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337');


-- TEST The budget should update (get refund) when a person sells their hotel

DELETE FROM Hotels 
WHERE ownerpersonnummer = '19990807-1337' 
AND ownercountry = 'Sweden';

SELECT assert ((SELECT budget FROM Persons WHERE personnummer = '19990807-1337' AND country = 'Sweden'), 19605.4);