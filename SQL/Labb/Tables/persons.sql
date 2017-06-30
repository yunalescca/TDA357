CREATE TABLE persons (
   country text NOT NULL,
   personnummer text NOT NULL CHECK (personnummer ~ similar_escape('[0-9]{6}-[0-9]{4}'::text, NULL::text) OR personnummer ~ similar_escape(' '::text, NULL::text)),
   name text NOT NULL,
   locationcountry text NOT NULL,
   locationarea text NOT NULL,
   budget numeric NOT NULL CHECK (budget >= 0::numeric),

   PRIMARY KEY(country, personnummer),
   FOREIGN KEY(country) REFERENCES countries(name),
   FOREIGN KEY(locationcountry, locationarea) REFERENCES Areas(country, name)
);