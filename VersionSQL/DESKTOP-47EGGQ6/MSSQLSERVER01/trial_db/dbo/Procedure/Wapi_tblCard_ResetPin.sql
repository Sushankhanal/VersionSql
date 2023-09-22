/****** Object:  Procedure [dbo].[Wapi_tblCard_ResetPin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCard_ResetPin]
	-- Add the parameters for the stored procedure here
	@intCardID		bigint,
	@intResetType	int, -- 0:Reset Default, 1: Manual Reset
	@strOldPassword	nvarchar(50),
	@strNewPassword	nvarchar(50)

AS
BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	DECLARE @return_value int,  
	@CardId             bigint
EXEC	@return_value=.[Local_Wapi_tblCard_ResetPin]
			@intCardID,
	@intResetType,
	@strOldPassword,
	@strNewPassword,
	@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCard_ResetPin]
		@intCardID,
	@intResetType,
	@strOldPassword,
	@strNewPassword

    end
END
