/*********************************************************
 * File name: SQL_EntringDataHotelSystem                 *
 * Author: Youssef Khaled                                *
 * Date: 12/13/2025 | dd/mm/yyyy                         *
 * Description: Adding data to HotelReservation DB       *
 *********************************************************/

-- using the HotelReservation database instead of master
USE HotelReservation;

/* 1. INSERT OPERATIONS: */

-- Inserts into Guests table
INSERT INTO HotelSchema.Guests
VALUES
	(1, 'Ahmed Hassan',   'Egyptian', 12345678, '1995-04-12'),
    (2, 'Sara Ali',       'Egyptian', 23456789, '1998-09-25'),
    (3, 'John Smith',     'American', 34567890, '1990-01-15'),
    (4, 'Emily Johnson',  'British',  45678901, '1987-06-30'),
    (5, 'Mohamed Salah',  'Egyptian', 56789012, '1992-11-10'),
    (6, 'Anna Müller',    'German',   67890123, '1989-03-05');


/* 2. UPDATE OPERATIONS: */
-- Increase DailyRate by 15% for all suites
UPDATE HotelSchema.Rooms
SET DailyRate = DailyRate * 1.15

-- Update ReservationStatus: 
-- If CheckoutDate < GETDATE() → 'Completed' 
-- If CheckinDate > GETDATE() → 'Upcoming' 
-- Else → 'Active'
UPDATE HotelSchema.Reservations
SET ReservationStatus =
	CASE 
		WHEN CheckOutDate < GETDATE() THEN 2 -- Completed
		WHEN CheckInDate > GETDATE() THEN 1 -- Upcoming
		ELSE 0 -- Active
	END;


/* 3. DELETE OPERATION: */
DELETE FROM HotelSchema.Reservation_Guest
WHERE ReservationId = 1;


/* 4. MERGE OPERATIONS: */
-- Creating StaffUpdates
CREATE TABLE #StaffUpdates(
	StaffId INT PRIMARY KEY,
	FullName VARCHAR(30),
	Position VARCHAR(60),
	Salary INT
);

-- Merge operation
MERGE INTO HotelSchema.Staff as target
USING #StaffUpdates as source
ON target.StaffId = source.StaffId

-- Match → Update Position + Salary
WHEN MATCHED THEN
	UPDATE SET 
		target.Position = Source.Position,
		target.Salary = Source.Salary

-- Not matched in Hotel DB → Insert
WHEN NOT MATCHED BY target THEN
	INSERT (StaffId , FullName , Position , Salary)
    VALUES (source.StaffId, source.FullName, source.Position, source.Salary)

-- Not matched in Update table → Delete 
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;