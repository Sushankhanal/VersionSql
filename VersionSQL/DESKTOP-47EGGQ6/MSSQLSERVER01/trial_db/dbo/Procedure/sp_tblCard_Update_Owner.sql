/****** Object:  Procedure [dbo].[sp_tblCard_Update_Owner]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCard_Update_Owner]
	-- Add the parameters for the stored procedure here
	@intCardID		bigint ,
	@intPlayerID	bigint

AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
    

DECLARE @return_value int,  
	@CardId             bigint

EXEC @return_value= [dbo].[Local_sp_tblCard_Update_Owner]
		@intCardID	 ,
	@intPlayerID,
	@cardid output;

	EXEC	[dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
    
    END TRY
    BEGIN CATCH
    print 100
    END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_sp_tblCard_Update_Owner]
		@intCardID	 ,
	@intPlayerID
    end

END
