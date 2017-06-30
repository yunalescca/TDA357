CREATE TRIGGER UpdatePlane BEFORE UPDATE ON test_AvailableFlights
FOR EACH ROW 
WHEN (new.plane <> old.plane)
EXECUTE PROCEDURE update_plane();

/*CREATE VIEW public.nextmoves AS
 WITH p AS (
         SELECT persons.country AS personcountry, persons.personnummer
           FROM persons
        ), a1 AS (
         SELECT area.country, area.name AS area
           FROM area
        ), a2 AS (
         SELECT area.country AS destcountry, area.name AS destarea
           FROM area
        ), r AS (
         SELECT min(roads.roadtax) AS cost
           FROM roads, a1, a2
          WHERE roads.fromcountry = a1.country AND roads.fromarea = a1.area AND roads.tocountry = a2.destcountry AND roads.toarea = a2.destarea
        )
 SELECT p.personcountry, p.personnummer, a1.country, a1.area, a2.destcountry, 
    a2.destarea, r.cost
   FROM p
NATURAL JOIN a1, a2, r;*/