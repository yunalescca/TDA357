CREATE FUNCTION assert(x text, y text) RETURNS void AS $$ 
BEGIN
    IF NOT (SELECT x = y)
    THEN
        RAISE 'assert(%=%) failed!', x, y;
    END IF;
    RETURN;
END
$$ LANGUAGE plpgsql;