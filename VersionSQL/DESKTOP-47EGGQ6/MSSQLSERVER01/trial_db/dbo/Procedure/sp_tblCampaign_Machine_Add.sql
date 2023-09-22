/****** Object:  Procedure [dbo].[sp_tblCampaign_Machine_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[sp_tblCampaign_Machine_Add]
	-- Add the parameters for the stored procedure here
	@intMachineID		bigint ,
	@intCampaignID	bigint,
	@strMachineName	nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO tblCampaign_Machine
	(CampaignM_Campaign_ID, CampaignM_Machine_ID, CampaignM_MachineName)
	VALUES (@intCampaignID,@intMachineID,@strMachineName)
		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
