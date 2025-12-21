/*********************************************************
 * File name: SQL_HotelReservation                       *
 * Author: Youssef Khaled                                *
 * Date: 12/9/2025 | dd/mm/yyyy                          *
 * Description: Creating HotelReservation DB with Hotel  *
 *              Schema containing the DB tables.         *
 *********************************************************/

-- 1. use surrogate keys  (done)
-- 2. if for example ISBN --> unique  (done)
-- 3. using schema (done)
-- 4. all the relationships outside the tables (done)

-- Creating HotelReservation database
CREATE DATABASE HotelReservation;


-- using the HotelReservation database instead of master
USE HotelReservation;


-- Creating Hotel schema
CREATE SCHEMA HotelSchema;

-- USE master
-- ALTER DATABASE HotelReservation SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- DROP DATABASE HotelReservation


/****************************************
 *           Creating tables            *
 ****************************************/
CREATE TABLE Hotels(
	HotelId INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	[Address] VARCHAR(60) NOT NULL,
	City VARCHAR(20) NOT NULL,
	StarRating VARCHAR(5),
	ContactNumber VARCHAR(11) UNIQUE NOT NULL,
	ManageId INT -- foriegn key
)

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY,
	RoomType TINYINT NOT NULL,
	Capacity TINYINT NOT NULL,
	DailyRate VARCHAR(5),
	[Availability] BIT NOT NULL,
	HotelId INT -- foriegn key
)

CREATE TABLE Amenities(
	Id INT IDENTITY PRIMARY KEY,
	Amenity VARCHAR(30),
	RoomNumber INT, --foreign key
)

CREATE TABLE Reservations_Rooms(
	Id INT IDENTITY PRIMARY KEY,
	RoomNumber INT, -- foreign key
	ReservationId INT, -- foreign key
)

CREATE TABLE Staff(
	StaffId INT PRIMARY KEY,
	FullName VARCHAR(30) NOT NULL,
	Position VARCHAR(20) NOT NULL,
	Salary INT,
	HotelId INT -- foriegn key
)

CREATE TABLE [Services](
	ServiceId INT PRIMARY KEY,
	ServiceName VARCHAR(30) NOT NULL,
	Charge INT NOT NULL,
	RequestDate DATE NOT NULL,
	StaffId INT -- foriegn key
)

CREATE TABLE ReservationService(
	Id INT IDENTITY PRIMARY KEY,
	ServiceId INT, -- foreign key
	ReservationId INT, -- foreign key
)

CREATE TABLE Reservations(
	ReservationId INT PRIMARY KEY,
	BookingDate DATE NOT NULL,
	CheckInDate DATE NOT NULL,
	CheckOutDate DATE NOT NULL,
	ReservationStatus TINYINT NOT NULL,
	TotalPrice INT NOT NULL,
	NumberOfAdults SMALLINT NOT NULL,
	NumberOfChildren SMALLINT 
)

CREATE TABLE Guests(
	GuestId INT PRIMARY KEY,
	FullName VARCHAR(30) NOT NULL,
	Nationality VARCHAR(10) NOT NULL,
	PassportNumber INT,
	DateOfBirth DATE
)

CREATE TABLE Reservation_Guest(
	Id INT IDENTITY PRIMARY KEY,
	ReservationId INT, -- foreign key
	GuestId INT -- foreign key
)

CREATE TABLE Guest_Contact_Details(
	Id INT IDENTITY PRIMARY KEY,
	GuestId INT, --foreign key
	Detail VARCHAR(30)
)

CREATE TABLE Payments(
	PaymentId INT PRIMARY KEY,
	Method TINYINT NOT NULL,
	[Date] DATE NOT NULL,
	Amount INT,
	ConfirmationNumber INT
)

CREATE TABLE Reservation_Payment(
	Id INT IDENTITY PRIMARY KEY,
	ReservationId INT, -- foreign key
	PaymentId INT -- foreign key
)

--------------------------------------------
--   Creating relations between tables    --
--------------------------------------------
ALTER TABLE Hotels
  ADD FOREIGN KEY (ManageId) REFERENCES Staff(StaffId);
ALTER TABLE Staff
  ADD FOREIGN KEY (HotelId) REFERENCES Hotels(HotelId);
ALTER TABLE [Services]
  ADD FOREIGN KEY (StaffId) REFERENCES Staff(StaffId);
ALTER TABLE Rooms
  ADD FOREIGN KEY (HotelId) REFERENCES Hotels(HotelId);
ALTER TABLE Amenities
  ADD FOREIGN KEY (RoomNumber) REFERENCES Rooms(RoomNumber);
ALTER TABLE Reservations_Rooms
  ADD FOREIGN KEY (RoomNumber) REFERENCES Rooms(RoomNumber);
ALTER TABLE Reservations_Rooms
  ADD FOREIGN KEY (ReservationId) REFERENCES Reservations(ReservationId);
ALTER TABLE Guest_Contact_Details
  ADD FOREIGN KEY (GuestId) REFERENCES Guests(GuestId);
ALTER TABLE Reservation_Guest
  ADD FOREIGN KEY (GuestId) REFERENCES Guests(GuestId);
ALTER TABLE Reservation_Guest
  ADD FOREIGN KEY (ReservationId) REFERENCES Reservations(ReservationId);
ALTER TABLE Reservation_Payment
  ADD FOREIGN KEY (ReservationId) REFERENCES Reservations(ReservationId);
ALTER TABLE ReservationService
  ADD FOREIGN KEY (ServiceId) REFERENCES [Services](ServiceId);
ALTER TABLE ReservationService
  ADD FOREIGN KEY (ReservationId) REFERENCES Reservations(ReservationId);

--------------------------------------------
-- moving the tables into the HotelSchema --
--------------------------------------------
ALTER SCHEMA HotelSchema TRANSFER Hotels;
ALTER SCHEMA HotelSchema TRANSFER Rooms;
ALTER SCHEMA HotelSchema TRANSFER Amenities;
ALTER SCHEMA HotelSchema TRANSFER Reservations_Rooms;
ALTER SCHEMA HotelSchema TRANSFER Staff;
ALTER SCHEMA HotelSchema TRANSFER [Services];
ALTER SCHEMA HotelSchema TRANSFER ReservationService;
ALTER SCHEMA HotelSchema TRANSFER Reservations;
ALTER SCHEMA HotelSchema TRANSFER Guests;
ALTER SCHEMA HotelSchema TRANSFER Reservation_Guest;
ALTER SCHEMA HotelSchema TRANSFER Guest_Contact_Details;
ALTER SCHEMA HotelSchema TRANSFER Payments;
ALTER SCHEMA HotelSchema TRANSFER Reservation_Payment;
