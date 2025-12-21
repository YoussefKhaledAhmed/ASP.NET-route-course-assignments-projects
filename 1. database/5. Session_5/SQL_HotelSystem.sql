/*********************************************************
 * File name: SQL_HotelSystem                            *
 * Author: Youssef Khaled                                *
 * Date: 12/17/2025 | dd/mm/yyyy                         *
 * Description: Solving session_5 assignment             *
 *********************************************************/


/* Using HotelReservation DB */
USE HotelReservation;


/* Question_1: If a hotel is deleted from the Hotels table, what is the appropriate *
 *             behavior for the rooms belonging to that hotel? Explain which        *
 *             foreign key rule you would choose and why And Represent Rule.        */

ALTER TABLE HotelSchema.Rooms
DROP CONSTRAINT FK__Rooms__HotelId__52593CB8;

ALTER TABLE HotelSchema.Rooms
ADD CONSTRAINT FK__Rooms__HotelId__52593CB8
FOREIGN KEY(HotelId) REFERENCES HotelSchema.Hotels(HotelId)
ON DELETE CASCADE;

DELETE FROM HotelSchema.Hotels
WHERE HotelId = 1;

-- The Rule is: CASCADE 
-- Because the hotel has been deleted, all its associated rooms are also deleted.


/* Question_2: When a room is deleted from the Rooms table, what should          *
 *             happen to the related records in Amenities? Which rule makes the  *
 *             most sense for this relationship, and why? And Represent Rule     */

ALTER TABLE HotelSchema.Amenity
DROP CONSTRAINT FK__Amenities__RoomN__534D60F1;

ALTER TABLE HotelSchema.Amenity
ADD CONSTRAINT FK__Amenities__RoomN__534D60F1
FOREIGN KEY(RoomNumber) REFERENCES HotelSchema.Rooms(RoomNumber)
ON DELETE CASCADE;

DELETE FROM HotelSchema.Rooms
WHERE RoomNumber = 1;

-- The Rule is: CASCADE 
-- Because the room has been deleted, all its associated aminities are also deleted.


/* Question_3: If a staff member’s ID changes, what impact should this have on  *
 *             the Services they are linked to? Which update rule is most       *
 *             suitable? And Represent Rule                                     */
ALTER TABLE HotelSchema.Staff
ALTER COLUMN SupervisorId SET DEFAULT 1;

-- Add self-referencing foreign key with SET DEFAULT
ALTER TABLE HotelSchema.Staff
ADD CONSTRAINT FK_Staff_Supervisor
FOREIGN KEY (SupervisorId) REFERENCES HotelSchema.Staff(StaffId)
ON UPDATE SET DEFAULT;

-- The rule is: Default value
-- if the supervisor Id changed this staff member is set to be supervised by the 
-- general manager (i.e., default value of the foreign key)