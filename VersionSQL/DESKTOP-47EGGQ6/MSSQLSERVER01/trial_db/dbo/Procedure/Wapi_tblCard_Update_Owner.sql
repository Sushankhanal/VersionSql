/****** Object:  Procedure [dbo].[Wapi_tblCard_Update_Owner]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCard_Update_Owner]
	-- Add the parameters for the stored procedure here
	@intCardID		bigint ,
	@intPlayerID	bigint

AS
BEGIN
	   DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
declare
	@return_value int,  
	@CardOwnerId        bigint,
	@CardId             bigint
EXEC	@return_value=	[dbo].[Local_Wapi_tblCard_Update_Owner]
	@intCardID,
	@intPlayerID,
		@CardOwnerId output,
    @CardId output;

	EXEC[dbo].[Sync_CardOwnerInsertUpdate] @CardOwnerId = @CardOwnerId;
EXEC [dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_Wapi_tblCard_Update_Owner]
	@intCardID,
	@intPlayerID

    end
END
