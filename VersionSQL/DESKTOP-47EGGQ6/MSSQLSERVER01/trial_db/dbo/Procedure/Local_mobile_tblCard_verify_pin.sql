/****** Object:  Procedure [dbo].[Local_mobile_tblCard_verify_pin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_mobile_tblCard_verify_pin] @card_no        NVARCHAR(1024), 
                                                   @strOldPassword NVARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT COUNT(Card_ID) AS RETURN_RESULT
        FROM tblCard
        WHERE Card_SerialNo = @card_no
              AND tblCard_pin = @strOldPassword;
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        RETURN(@@ERROR);
    END;
