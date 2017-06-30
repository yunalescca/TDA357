CREATE FUNCTION assert(x numeric, y numeric) RETURNS void AS $$ 
BEGIN
    IF NOT (SELECT trunc(x, 2) = trunc(y, 2))
    THEN
        RAISE 'assert(%=%) failed (up to 2 decimal places, checked with trunc())!', x, y;
    END IF;
    RETURN;
END
$$ LANGUAGE plpgsql;