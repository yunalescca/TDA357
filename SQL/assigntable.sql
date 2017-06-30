CREATE TRIGGER AssignTable BEFORE INSERT ON test_tablebookings
FOR EACH ROW
WHEN (NEW.tablenum IS NULL)
EXECUTE PROCEDURE Assign_Table();

/*

select pr1.name, pr1.author, pr1.texts 
from test_pagerevisions as pr1, test_pagerevisions as pr2 
where pr1.name = pr2.name
group by pr1.name, pr1.date 
having pr1.date = max(pr2.date)

<==>

select name, pr1.author, pr1.texts
from test_pagerevisions as pr1
join test_pagerevisions as pr2 using (name)
group by name, pr1.date
having pr1.date = max(pr2.date)

<==>

select pr1.name, pr1.author, pr1.texts
from test_pagerevisions as pr1
join test_pagerevisions as pr2 on pr1.name = pr2.name
group by name, pr1.date
having pr1.date = max(pr2.date)
*/

