/****** Object:  Procedure [dbo].[Wapi_force_disconnect_request_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetBeverageCategory '','comp02'

CREATE PROCEDURE [dbo].[Wapi_force_disconnect_request_GetByID] (
	@intSessionID	bigint
) AS
BEGIN
	select F.*, force_disconnect_request_machine_id as player_id from force_disconnect_request F (NOLOCK)
	where force_disconnect_request_game_session_id = @intSessionID
END
