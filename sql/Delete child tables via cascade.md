Automatically delete child tables entries when the parent table entry is deleted.

If have tables `building` and `rooms` linked by a `building_no` foreign key then all rooms in building X are deleted from `rooms` when this building is deleted!

> https://www.mysqltutorial.org/mysql-on-delete-cascade/

#sql 
#til 
