CREATE VIEW vw_TicketData
AS
SELECT dbo.tickets.customer_id,
       tickets.date,
       tickets.location,
       technicians.full_name AS Technician,
       ticket_status.description AS Status,
       ticket_priority.description AS Priority
FROM production.dbo.tickets
    INNER JOIN dbo.customers
        ON customers.id = tickets.customer_id
    INNER JOIN dbo.ticket_status
        ON ticket_status.id = tickets.status_id
    INNER JOIN dbo.ticket_priority
        ON ticket_priority.id = tickets.priority_id
    INNER JOIN dbo.technicians
        ON technicians.id = tickets.technician_id;

