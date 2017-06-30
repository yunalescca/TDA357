-- SHOULD WORK

INSERT INTO Countries VALUES ('Sweden');

INSERT INTO Areas VALUES ('Sweden', 'Gothenburg', 500000);

INSERT INTO Cities VALUES ('Sweden', 'Gothenburg', 3000);

INSERT INTO Persons VALUES ('Sweden', '19990807-1337', 'Pepsi Max', 'Sweden', 'Gothenburg', 20000);

--TEST Insert (buy a hotel in a city will lower the person's budget)

INSERT INTO Hotels VALUES ('Maxat', 'Sweden', 'Gothenburg', 'Sweden', '19990807-1337');

SELECT assert ((SELECT budget FROM Persons WHERE personnummer = '19990807-1337'), 19210.8);