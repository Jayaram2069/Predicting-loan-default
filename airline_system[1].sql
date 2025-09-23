-- Airline Reservation System SQL Schema

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    route_id INT,
    departure TIMESTAMP,
    arrival TIMESTAMP,
    total_seats INT,
    booked_seats INT DEFAULT 0
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    flight_id INT,
    passenger_id INT,
    seat_number VARCHAR(10),
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50)
);

CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    origin VARCHAR(50),
    destination VARCHAR(50)
);

-- Trigger for waitlist handling
CREATE TABLE waitlist (
    waitlist_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT,
    passenger_id INT,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER check_seat_allocation
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    DECLARE seat_count INT;
    SELECT booked_seats INTO seat_count FROM flights WHERE flight_id = NEW.flight_id;

    IF seat_count >= (SELECT total_seats FROM flights WHERE flight_id = NEW.flight_id) THEN
        INSERT INTO waitlist(flight_id, passenger_id) VALUES (NEW.flight_id, NEW.passenger_id);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No seats available. Passenger added to waitlist.';
    ELSE
        UPDATE flights SET booked_seats = booked_seats + 1 WHERE flight_id = NEW.flight_id;
    END IF;
END;
//
DELIMITER ;

-- Query: Highest occupancy flight each month
SELECT f.flight_id, MONTH(t.booking_date) AS month,
       (f.booked_seats / f.total_seats) * 100 AS occupancy_rate
FROM flights f
JOIN tickets t ON f.flight_id = t.flight_id
GROUP BY f.flight_id, month
ORDER BY occupancy_rate DESC;
