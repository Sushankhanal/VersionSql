/****** Object:  Procedure [dbo].[Wapi_tblCampaign_Point_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCampaign_Point_Update]
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
	@intMachineID	bigint = 0,
	@strMachineName	nvarchar(50) = '',
	@dblMinBet		money = 0,
	@dblMaxBet		money = 0,
	@dblMinWin		money = 0,
	@dblMaxWin		money = 0,
	@strDay			nvarchar(50) ='',
	@strCardType			nvarchar(500) ='',
	@strPlayerLevel			nvarchar(500) ='',
	@dtStartTime	nvarchar(50)='',
	@dtEndTime	nvarchar(50)=''
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

	
		Update tblCampaign_Point Set
		Campaign_Type = @strTypeName, Campaign_Type_ID = @intTypeID, Campaign_Name = @strName, Campaign_StartDate = @strStartDate, Campaign_EndDate = @strEndDate,
		Campaign_Rate = @dblRate, Campaign_Remarks = @strRemarks, Campaign_Status = @intStatus,
		Campaign_UpdatedBy = @strUsercode, Campaign_UpdatedDate = GETDATE(), 
		Campaign_MachineID = 1, Campaign_MachineName = '',
		Campaign_MinBet = @dblMinBet, Campaign_MaxBet = @dblMaxBet, Campaign_MinWin = @dblMinWin, Campaign_MaxWin = @dblMaxWin,
		Campaign_Day = @strDay,Campaign_CardType = @strCardType,Campaign_PlayerLevel = @strPlayerLevel,
		Campaign_StartTime = @dtStartTime, Campaign_EndTime = @dtEndTime
		Where Campaign_ID = @intID

		delete from tblCampaign_Machine where CampaignM_Campaign_ID = @intID

		set @intResultCode = @intID
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
