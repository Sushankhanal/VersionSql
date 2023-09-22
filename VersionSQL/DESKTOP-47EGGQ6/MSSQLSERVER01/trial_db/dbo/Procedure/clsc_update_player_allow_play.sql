/****** Object:  Procedure [dbo].[clsc_update_player_allow_play]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec api_SaveOrderMaster 'comp02','Tablet01','Tablet01','R8',''
CREATE PROCEDURE [dbo].[clsc_update_player_allow_play] @cardSrn NVARCHAR(50)
AS
    BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer' -- Replace with your linked server name
	
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	
            	declare
	@return_value int,  
	@CardOwnerId        bigint,
	@CardId             bigint
EXEC	@return_value= [dbo].[Cloud_clsc_update_player_allow_play] @cardSrn,
@CardOwnerId output,
    @CardId output;

	EXEC[dbo].[Sync_CardOwnerInsertUpdate] @CardOwnerId = @CardOwnerId;
EXEC [dbo].[Sync_CardInsertUpdate] @CardId = @CardId;
	 
	END TRY
    BEGIN CATCH
	
    END CATCH
	end
	else
	begin

	 EXEC [dbo].[Local_clsc_update_player_allow_play] @cardSrn
	end
	
END
