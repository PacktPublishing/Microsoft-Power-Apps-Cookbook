create table ticket_status (
	id INT,
	description VARCHAR(50),
	active BIT
);
insert into ticket_status (id, description, active) values (1, 'New', 1);
insert into ticket_status (id, description, active) values (2, 'Open', 1);
insert into ticket_status (id, description, active) values (3, 'Closed', 1);
insert into ticket_status (id, description, active) values (4, 'Resolved', 1);