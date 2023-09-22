/****** Object:  Procedure [dbo].[Local_mobile_tblCard_ResetPin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_mobile_tblCard_ResetPin] @card_no        NVARCHAR(1024), 
                                                 @strOldPassword NVARCHAR(50), 
                                                 @strNewPassword NVARCHAR(50),
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
        IF
        (
            SELECT COUNT(Card_ID)
            FROM tblCard
            WHERE Card_SerialNo = @card_no
                  AND tblCard_pin = @strOldPassword
        ) = 0
            BEGIN
                SELECT-1 AS RETURN_RESULT;
            END;
            ELSE
            BEGIN
                UPDATE tblCard
                  SET 
                      tblCard_pin = @strNewPassword, 
                      Card_isPinReset = 0
                WHERE Card_SerialNo = @card_no;
				set @CardId=@card_no;
                SELECT 1 AS RETURN_RESULT;
            END;
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        RETURN(@@ERROR);
    END;
