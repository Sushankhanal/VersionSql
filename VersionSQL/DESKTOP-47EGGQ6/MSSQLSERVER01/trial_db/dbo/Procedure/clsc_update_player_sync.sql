/****** Object:  Procedure [dbo].[clsc_update_player_sync]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[clsc_update_player_sync] @checksum     BIGINT, 
                                                 @cardOwner_id BIGINT
AS
   BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer' 
	
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
    BEGIN TRY
	
            	declare
	@return_value int,  
	@CardOwnerId        bigint
EXEC	@return_value= [dbo].[Local_clsc_update_player_sync] @checksum,  @cardOwner_id ,
@CardOwnerId output

	EXEC[dbo].[Sync_CardOwnerInsertUpdate] @CardOwnerId = @CardOwnerId;
	 
	END TRY
    BEGIN CATCH
	
    END CATCH
	end
	else
	begin

	 EXEC [dbo].[Local_clsc_update_player_sync] @checksum,  @cardOwner_id 
	end
	
END
