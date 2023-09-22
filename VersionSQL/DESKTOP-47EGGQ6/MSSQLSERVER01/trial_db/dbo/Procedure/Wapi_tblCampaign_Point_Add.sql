/****** Object:  Procedure [dbo].[Wapi_tblCampaign_Point_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCampaign_Point_Add]
	-- Add the parameters for the stored procedure here
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

		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT([Campaign_ID]), 0) FROM tblCampaign_Point NOLOCK 
		WHERE (Campaign_Name = @strName )
		Declare @intID bigint = 0
		IF @intCount = 0 
		BEGIN
			INSERT INTO tblCampaign_Point
			(Campaign_Type, Campaign_Type_ID, Campaign_Name, Campaign_StartDate, Campaign_EndDate, Campaign_Rate, Campaign_Remarks, 
			Campaign_Status, Campaign_CreatedBy, Campaign_CreatedDate, Campaign_UpdatedBy, Campaign_UpdatedDate, 
			Campaign_MachineID, Campaign_MachineName,
			Campaign_MinBet, Campaign_MaxBet, Campaign_MinWin, Campaign_MaxWin,
			Campaign_Day,Campaign_CardType,Campaign_PlayerLevel, Campaign_StartTime, Campaign_EndTime )
			VALUES (
			@strTypeName,@intTypeID,@strName,@strStartDate,@strEndDate,@dblRate,@strRemarks,
			@intStatus,@strUsercode,GETDATE(),@strUsercode,GETDATE(), @intMachineID, @strMachineName,
			@dblMinBet, @dblMaxBet, @dblMinWin, @dblMaxWin,
			@strDay,@strCardType,@strPlayerLevel,@dtStartTime,@dtEndTime)
			SELECT @intID = SCOPE_IDENTITY()

			set @intResultCode = @intID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
		END
		ELSE
		BEGIN
			set @intID = 0
			set @intResultCode = -1
			set @strResultText = 'Campaign name already used, Please try another name.'
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
			RETURN (-1)
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
