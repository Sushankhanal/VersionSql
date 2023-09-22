/****** Object:  Procedure [dbo].[Local_clsc_password_reset]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Local_clsc_password_reset] @card_sn         NVARCHAR(50), 
                                             @start           DATETIME, 
                                             @end             DATETIME, 
                                             @app_version     NVARCHAR(50), 
                                             @setting_version NVARCHAR(50), 
                                             @ip              NVARCHAR(50), 
                                             @imei            NVARCHAR(50), 
                                             @cardOwner_name  NVARCHAR(50), 
                                             @companyCode     NVARCHAR(50), 
                                             @password        NVARCHAR(MAX), 
                                             @password_new    NVARCHAR(MAX),
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            IF
            (
                SELECT COUNT(*)
                FROM tblCard
                WHERE Card_SerialNo = @card_sn
                      AND tblCard_pin = @password
            ) > 0
                BEGIN
                    UPDATE tblCard
                      SET 
                          tblCard_pin = @password_new
                    WHERE Card_SerialNo = @card_sn;
					set @CardId=@card_sn;
                    SELECT 1 AS RETURN_RESULT;
                END;
                ELSE
                BEGIN
                    SELECT-1 AS RETURN_RESULT, 
                          'Invalid Account Credential.' MSG;
                END;
            COMMIT TRANSACTION;
            SET NOCOUNT OFF;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            SELECT '-98' AS 'RETURN_RESULT';
            SELECT ERROR_MESSAGE();
            SELECT ERROR_LINE();
        END CATCH;
    END;
