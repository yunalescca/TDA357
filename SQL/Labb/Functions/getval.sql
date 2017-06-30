CREATE FUNCTION getval(qname text) RETURNS numeric AS $$ 
DECLARE
    xxx NUMERIC;
BEGIN
    xxx := (SELECT value FROM Constants WHERE name = qname);
    RETURN xxx;
END
$$ LANGUAGE plpgsql;