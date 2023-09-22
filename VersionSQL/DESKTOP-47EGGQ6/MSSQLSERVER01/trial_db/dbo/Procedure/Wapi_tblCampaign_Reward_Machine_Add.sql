/****** Object:  Procedure [dbo].[Wapi_tblCampaign_Reward_Machine_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCampaign_Reward_Machine_Add]
		-- Add the parameters for the stored procedure here
	@strMachineID	nvarchar(max) ,
	@intRewardCampaign	bigint
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

	delete from tblCampaign_Machine where CampaignM_Campaign_ID = @intRewardCampaign

	INSERT INTO tblCampaign_Machine
	(CampaignM_Campaign_ID, CampaignM_Machine_ID, CampaignM_MachineName)
	select @intRewardCampaign, [Name], '' from  dbo.fnSplitstringToTable(@strMachineID) 

	set @intResultCode = 1
	set @strResultText = 'Success'
	select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
