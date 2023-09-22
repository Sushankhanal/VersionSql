/****** Object:  Procedure [dbo].[SP1_InsertIntoTableA]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[SP1_InsertIntoTableA]
AS
BEGIN
    BEGIN TRANSACTION;
    
    -- Inserting data into TableA
    INSERT INTO TableA (ID, Name) VALUES (3, 'Charlie');

    -- Simulating a delay to allow SP2 to run
    WAITFOR DELAY '00:00:05';

    -- Trying to insert data into TableB, but needs to acquire a lock on TableB's rows
    INSERT INTO TableB (ID, Age) VALUES (3, 28);

    COMMIT TRANSACTION;
END;
