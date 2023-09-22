/****** Object:  Procedure [dbo].[clsc_disconnect_request_add]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[clsc_disconnect_request_add] @force_disconnect_request_timing   INT            = 30, 
                                                     @CardOwner_clsc_allow_play_message NVARCHAR(2048), 
                                                     @Card_SerialNo                     NVARCHAR(50), 
                                                     @machine_id                        BIGINT, 
                                                     @force_disconnect_request_by       BIGINT,
													 @force_disconnect_request_game_session_id	BIGINT
AS
BEGIN
    -- Check the connectivity to the linked server
    DECLARE @LinkedServerName NVARCHAR(50) = 'CloudServer'
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
begin
   BEGIN TRY
    
	DECLARE @return_value int,  
	@CardOwnerId             bigint

EXEC @return_value= [dbo].[Local_clsc_disconnect_request_add]
		@force_disconnect_request_timing ,
@CardOwner_clsc_allow_play_message,
@Card_SerialNo,
@machine_id,
@force_disconnect_request_by,
@force_disconnect_request_game_session_id,
		@CardOwnerId output;

	EXEC	[dbo].[Sync_CardOwnerInsertUpdate] @CardOwnerId = @CardOwnerId;


    
   END TRY
   BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    PRINT @ErrorMessage
END CATCH
    end
    else
    begin
	 EXEC[dbo].[Local_clsc_disconnect_request_add]
	@force_disconnect_request_timing ,
@CardOwner_clsc_allow_play_message,
@Card_SerialNo,
@machine_id,
@force_disconnect_request_by,
@force_disconnect_request_game_session_id

    end

END
