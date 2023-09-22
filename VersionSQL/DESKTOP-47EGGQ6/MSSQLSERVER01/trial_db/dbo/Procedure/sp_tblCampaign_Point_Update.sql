/****** Object:  Procedure [dbo].[sp_tblCampaign_Point_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCampaign_Point_Update]
	-- Add the parameters for the stored procedure here
	@intID		int ,
	@strTypeName	nvarchar(50),
	@intTypeID		int,
	@strName		nvarchar(50),
	@strStartDate	datetime,
	@strEndDate		datetime,
	@dblRate		money,
	@strRemarks		nvarchar(500),
	@intStatus		smallint,
	@strUsercode	nvarchar(50),
	@intMachineID	bigint,
	@strMachineName	nvarchar(50),
	@dblMinBet		money = 0,
	@dblMaxBet		money = 0,
	@dblMinWin		money = 0,
	@dblMaxWin		money = 0
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
		Update tblCampaign_Point Set
		Campaign_Type = @strTypeName, Campaign_Type_ID = @intTypeID, Campaign_Name = @strName, Campaign_StartDate = @strStartDate, Campaign_EndDate = @strEndDate,
		Campaign_Rate = @dblRate, Campaign_Remarks = @strRemarks, Campaign_Status = @intStatus,
		Campaign_UpdatedBy = @strUsercode, Campaign_UpdatedDate = GETDATE(), 
		Campaign_MachineID = 1, Campaign_MachineName = '',
		Campaign_MinBet = @dblMinBet, Campaign_MaxBet = @dblMaxBet, Campaign_MinWin = @dblMinWin, Campaign_MaxWin = @dblMaxWin
		Where Campaign_ID = @intID

		delete from tblCampaign_Machine where CampaignM_Campaign_ID = @intID
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
