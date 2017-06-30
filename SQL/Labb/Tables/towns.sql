CREATE TABLE towns (
   country text NOT NULL,
   name text NOT NULL,
   PRIMARY KEY(country, name),
   FOREIGN KEY(country, name) REFERENCES Areas(country, name)
);