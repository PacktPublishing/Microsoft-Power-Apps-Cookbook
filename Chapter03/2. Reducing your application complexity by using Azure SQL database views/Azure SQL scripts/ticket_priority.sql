create table ticket_priority (
	id INT,
	description VARCHAR(50),
	active BIT
);
insert into ticket_priority (id, description, active) values (1, 'Low', 1);
insert into ticket_priority (id, description, active) values (2, 'Medium', 1);
insert into ticket_priority (id, description, active) values (3, 'High', 1);