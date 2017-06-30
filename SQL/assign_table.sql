	CREATE OR REPLACE FUNCTION assign_Table() RETURNS TRIGGER AS $$
	BEGIN
		NEW.tablenum := (
			WITH possibleTables AS(
				SELECT number, seats
				FROM test_tables
				WHERE (tablenum, NEW.time) NOT IN (SELECT * FROM BlockedTable)
					AND seats >= NEW.nbPeople -- is new what we get from the whole row when we insert?
					/* does not work.. in the table I state that table is never null, but
					the trigger will only be triggered when table is null?*/
				)
				SELECT MIN(tablenum)
				FROM possibleTables
				WHERE seats = (SELECT MIN(seats) FROM possibleTables));

			IF (NEW.tablenum IS NULL)
				THEN RAISE EXCEPTION 'No table available';
			END IF ;

		RETURN NEW;
	END
	$$ LANGUAGE 'plpgsql';