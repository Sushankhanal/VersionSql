/****** Object:  Procedure [dbo].[mobile_tblCard_ResetPin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[mobile_tblCard_ResetPin] @card_no        NVARCHAR(1024), 
                                                 @strOldPassword NVARCHAR(50), 
                                                 @strNewPassword NVARCHAR(50)
AS
   BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer' -- Replace with your linked server name
	
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	
             
	DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value=  [dbo].[Local_mobile_tblCard_ResetPin] @card_no,@strOldPassword, @strNewPassword,
			@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
	 
	END TRY
    BEGIN CATCH
	
    END CATCH
	end
	else
	begin

	 EXEC [dbo].[Local_mobile_tblCard_ResetPin] @card_no,@strOldPassword, @strNewPassword
	end
	
END
