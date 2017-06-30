CREATE TABLE cities (
   country text NOT NULL,
   name text NOT NULL,
   visitbonus numeric NOT NULL CHECK (visitbonus >= 0::numeric),
   PRIMARY KEY(country, name),
   FOREIGN KEY(country, name) REFERENCES Areas(country, name)
);