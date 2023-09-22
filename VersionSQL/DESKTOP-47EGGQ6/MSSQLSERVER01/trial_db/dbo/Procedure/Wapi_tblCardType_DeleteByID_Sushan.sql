/****** Object:  Procedure [dbo].[Wapi_tblCardType_DeleteByID_Sushan]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Wapi_tblCardType_DeleteByID_Sushan]
    -- Add the parameters for the stored procedure here
    @intID          bigint,
    @strUsercode    nvarchar(50)

AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        -- Check if the Card_Type is in use
        DECLARE @intCount INT
        SELECT @intCount = COUNT(Card_ID) FROM tblCard WITH (NOLOCK) WHERE Card_Type = @intID

        IF @intCount = 0
        BEGIN
            -- Delete from the cloud server (POSv3)
            DELETE FROM [dbo].[tblcardtype] WHERE CardType_ID = @intID

            -- Delete from the local server (POSv2)
           -- DELETE FROM  [dbo].[tblCardType] WHERE CardType_ID = @intID

            -- Insert into cloudsync table
            INSERT INTO  [POSv3].[dbo].[CloudSync] ( entityname, entityid, operation, Syncstatus)
            VALUES ( 'tblCardType',1, 'Delete', 1)

            COMMIT TRANSACTION
            SET NOCOUNT OFF
            RETURN (0)
        END
        ELSE
        BEGIN
            -- Card Type in use with another record(s)
            SET NOCOUNT OFF
            SELECT -1 AS RETURN_RESULT, 'Card Type in use with another record(s)' AS RETURN_RESULT_TEXT
            RETURN (-1)
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN (ERROR_NUMBER())
    END CATCH
END
