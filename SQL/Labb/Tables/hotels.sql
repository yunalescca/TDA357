CREATE TABLE hotels (
   name text NOT NULL,
   locationcountry text NOT NULL,
   locationname text NOT NULL,
   ownercountry text NOT NULL,
   ownerpersonnummer text NOT NULL CHECK (ownerpersonnummer ~ similar_escape('[0-9]{6}-[0-9]{4}'::text, NULL::text) OR ownerpersonnummer ~ similar_escape(' '::text, NULL::text)),

   PRIMARY KEY(locationcountry, locationname, ownercountry, ownerpersonnummer),
   FOREIGN KEY(locationcountry, locationname) REFERENCES Cities(country,name),
   FOREIGN KEY(ownercountry, ownerpersonnummer) REFERENCES Persons(country, personnummer)
 );