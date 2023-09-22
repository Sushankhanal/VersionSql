/****** Object:  Procedure [dbo].[sp_tblCampaign_Point_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblCampaign_Point_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select * from tblCampaign_Point where Campaign_ID = @intID

	select *, CampaignM_Machine_ID as player_id,CampaignM_MachineName as player_name  from tblCampaign_Machine where CampaignM_Campaign_ID = @intID
END
