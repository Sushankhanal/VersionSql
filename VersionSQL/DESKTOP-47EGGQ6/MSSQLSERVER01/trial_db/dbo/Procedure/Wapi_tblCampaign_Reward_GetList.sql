/****** Object:  Procedure [dbo].[Wapi_tblCampaign_Reward_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[Wapi_tblCampaign_Reward_GetList] (
	@intRewardCampaign	bigint = -1
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY Reward_Name)  AS RowNo,
				R.*, 
				(CASE Reward_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Reward_StatusText,
				ISNULL(C.CardType_Name,'') as CardType_Name,
				(CASE Reward_Type_ID WHEN 1 THEN 'WELCOME BONUS' ELSE 'Unknown' END) as Reward_Type_Text
				from tblCampaign_Reward R (NOLOCK)
				left outer join tblCardType C (NOLOCK) on C.CardType_ID = R.Reward_CardType
				where (CASE WHEN @intRewardCampaign = -1 THEN 1 ELSE CASE WHEN R.Reward_ID = @intRewardCampaign THEN 1 ELSE 0 END END) > 0
				--where Reward_Name  LIKE '%' + @strName + '%' AND
				--	Reward_StartDate >= @strDateFrom AND
				--	Reward_EndDate <= @strDateTo AND
				--	(CASE WHEN @intStatus = -1 THEN 1 ELSE CASE WHEN Reward_Status = @intStatus THEN 1 ELSE 0 END END) > 0 AND
				--	(CASE WHEN @intCardType = -1 THEN 1 ELSE CASE WHEN Reward_CardType = @intCardType THEN 1 ELSE 0 END END) > 0 

	select * from tblCampaign_Machine (NOLOCK) where CampaignM_Campaign_ID = @intRewardCampaign
END
