CREATE TABLE roads (
   fromcountry text NOT NULL,
   fromarea text NOT NULL,
   tocountry text NOT NULL,
   toarea text NOT NULL,
   ownercountry text NOT NULL,
   ownerpersonnummer text NOT NULL CHECK (ownerpersonnummer ~ similar_escape('[0-9]{6}-[0-9]{4}'::text, NULL::text) OR ownerpersonnummer ~ similar_escape(' '::text, NULL::text)),
   roadtax numeric NOT NULL CHECK (roadtax >= 0::numeric),

   PRIMARY KEY(fromcountry, fromarea, tocountry, toarea, ownercountry, ownerpersonnummer),
   FOREIGN KEY(fromcountry, fromarea) REFERENCES Areas(country, name),
   FOREIGN KEY(tocountry, toarea) REFERENCES Areas(country, name),
   FOREIGN KEY(ownercountry, ownerpersonnummer) REFERENCES Persons(country, personnummer)
);