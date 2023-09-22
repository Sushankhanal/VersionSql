/****** Object:  Procedure [dbo].[get_db_version]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[get_db_version] 
AS
    BEGIN
        BEGIN TRY

            SELECT db_version
            FROM db_version; 

            SET NOCOUNT OFF;
        END TRY
        BEGIN CATCH
            SELECT 0 AS 'RETURN_RESULT';
            SELECT ERROR_MESSAGE() AS 'MSG';
            SELECT ERROR_LINE() AS 'LINE';
        END CATCH;
    END;
