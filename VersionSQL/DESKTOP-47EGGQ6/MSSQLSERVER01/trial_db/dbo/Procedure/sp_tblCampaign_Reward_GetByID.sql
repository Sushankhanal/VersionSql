/****** Object:  Procedure [dbo].[sp_tblCampaign_Reward_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblCampaign_Reward_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select * from tblCampaign_Reward R (NOLOCK)
	where Reward_ID = @intID

END
