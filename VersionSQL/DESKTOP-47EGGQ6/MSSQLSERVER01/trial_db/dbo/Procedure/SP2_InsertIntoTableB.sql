/****** Object:  Procedure [dbo].[SP2_InsertIntoTableB]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[SP2_InsertIntoTableB]
AS
BEGIN
    BEGIN TRANSACTION;

    -- Inserting data into TableB
    INSERT INTO TableB (ID, Age) VALUES (4, 35);

    -- Simulating a delay to allow SP1 to run
    WAITFOR DELAY '00:00:05';

    -- Trying to insert data into TableA, but needs to acquire a lock on TableA's rows
    INSERT INTO TableA (ID, Name) VALUES (4, 'David');

    COMMIT TRANSACTION;
END;
