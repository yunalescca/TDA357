CREATE TABLE areas (
   country text NOT NULL,
   name text NOT NULL,
   population integer NOT NULL CHECK (population >= 0),
   PRIMARY KEY (country, name),
   FOREIGN KEY (country) REFERENCES Countries(name)
);