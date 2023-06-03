DROP DATABASE COVID;
CREATE DATABASE covid;
USE covid;
CREATE TABLE admin (
	admin_id VARCHAR(20) PRIMARY KEY,
    pass VARCHAR(50),
    name VARCHAR(70)
);

INSERT INTO admin VALUES("admin","admin","ADMIN");

CREATE TABLE user (
	user_id VARCHAR(20) PRIMARY KEY,
    pass VARCHAR(20),
    fname VARCHAR(20),
    lname VARCHAR(20),
    age INT,
    phone_no VARCHAR(20),
    gender VARCHAR(10),
    dosage_taken INT DEFAULT 0,
    city VARCHAR(20),
    state VARCHAR(20)    
);

INSERT INTO user (user_id, pass, fname, lname, age, phone_no, gender, city, state)
VALUES
    ('U1', 'password1', 'raj', 'kumar', 25, '1234567890', 'Male', 'City A', 'State A'),
    ('U2', 'password2', 'lakshmi', 'S', 30, '9876543210', 'Female', 'City B', 'State B'),
    ('U3', 'password3', 'john', 'wick', 40, '4567890123', 'Male', 'City C', 'State C'),
    ('U4', 'password4', 'arya', 'stark', 35, '0123456789', 'Female', 'City D', 'State D'),
    ('U5', 'password5', 'tyrian', 'lannister', 28, '6789012345', 'Male', 'City E', 'State E');

CREATE TABLE center (
	center_id VARCHAR(20) PRIMARY KEY,
    open_time TIME,
    closing_time TIME,
    available_slots INT,
    contact_no VARCHAR(10),
    city VARCHAR(20),
    state VARCHAR(20)
);

INSERT INTO center (center_id, open_time, closing_time, available_slots,  contact_no, city, state)
VALUES
    ('C1', '08:00:00', '18:00:00', 10, '1234567890', 'City A', 'State A'),
    ('C2', '09:00:00', '17:00:00', 5, '9876543210', 'City B', 'State B'),
    ('C3', '07:30:00', '16:30:00', 8, '4567890123', 'City C', 'State C'),
    ('C4', '08:30:00', '17:30:00', 12, '0123456789', 'City D', 'State D'),
    ('C5', '10:00:00', '19:00:00', 15, '6789012345', 'City E', 'State E'),
    ('C6', '09:30:00', '18:30:00', 7, '3456789012', 'City F', 'State F'),
    ('C7', '07:00:00', '16:00:00', 3, '8901234567', 'City G', 'State G'),
    ('C8', '08:00:00', '17:00:00', 6, '5678901234', 'City H', 'State H'),
    ('C9', '09:00:00', '18:00:00', 9, '2345678901', 'City I', 'State I'),
    ('C10', '07:30:00', '16:30:00', 11, '9012345678', 'City J', 'State J');

CREATE TABLE VACCINE (
	vaccine_id INT PRIMARY KEY,
    name VARCHAR(20),
    manufacturer VARCHAR(50),
    dosage INT
); 

INSERT INTO vaccine VALUES(1,"COWIN","Bharat Biotech",20000);
INSERT INTO vaccine VALUES(2,"COVI-SHIELD","Serum Institute of India Pvt Ltd",1000);

CREATE TABLE vaccine_record (
	record_id INT PRIMARY KEY auto_increment,
    user_id VARCHAR(20),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    center_id VARCHAR(20),
    FOREIGN KEY(center_id) REFERENCES center(center_id),
    vaccine_id INT,
    FOREIGN KEY(vaccine_id) REFERENCES vaccine(vaccine_id),
    dose_no INT,
    dose_date DATE
);

CREATE TABLE appointment_record (
	appointment_id INT PRIMARY KEY auto_increment,
    user_id VARCHAR(20),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    center_id VARCHAR(20),
    FOREIGN KEY(center_id) REFERENCES center(center_id),
    vaccine_id INT,
    FOREIGN KEY(vaccine_id) REFERENCES vaccine(vaccine_id),
    dose_no INT,
    appointment_date DATE,
    appointment_time TIME,
    status VARCHAR(10)
);

ALTER TABLE appointment_record AUTO_INCREMENT=100;

INSERT INTO appointment_record (user_id,center_id,vaccine_id,dose_no,appointment_date,appointment_time,status) VALUES("U1","C1",1,2,"2003-06-18","12:00","BOOKED");
INSERT INTO appointment_record (user_id,center_id,vaccine_id,dose_no,appointment_date,appointment_time,status) VALUES("U2","C10",2,1,"2003-06-19","12:00","BOOKED");

DELIMITER $$
CREATE TRIGGER bookSlot
AFTER INSERT ON appointment_record
FOR EACH ROW
BEGIN
    UPDATE center
    SET available_slots = available_slots - 1
    WHERE center_id = NEW.center_id;
END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER insert_record
AFTER UPDATE ON appointment_record
FOR EACH ROW
BEGIN
    IF NEW.status = 'COMPLETED' THEN
        INSERT INTO vaccine_record (user_id, center_id, vaccine_id, dose_no, dose_date)
        VALUES (NEW.user_id, NEW.center_id, NEW.vaccine_id,NEW.dose_no,NEW.appointment_date);
        
        UPDATE user
        SET dosage_taken = dosage_taken + 1
        WHERE user_id = NEW.user_id;
    END IF;
END$$
DELIMITER ;

UPDATE appointment_record
SET status="COMPLETED"
WHERE appointment_id = 101;
SELECT * FROM appointment_record;