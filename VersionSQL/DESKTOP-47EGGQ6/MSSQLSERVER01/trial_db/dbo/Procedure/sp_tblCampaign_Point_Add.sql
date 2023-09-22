/****** Object:  Procedure [dbo].[sp_tblCampaign_Point_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCampaign_Point_Add]
	-- Add the parameters for the stored procedure here
	@ID				int OUT,
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

		
		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT([Campaign_ID]), 0) FROM tblCampaign_Point NOLOCK 
		WHERE (Campaign_Name = @strName )
		
		IF @intCount = 0 
		BEGIN
			INSERT INTO tblCampaign_Point
			(Campaign_Type, Campaign_Type_ID, Campaign_Name, Campaign_StartDate, Campaign_EndDate, Campaign_Rate, Campaign_Remarks, 
			Campaign_Status, Campaign_CreatedBy, Campaign_CreatedDate, Campaign_UpdatedBy, Campaign_UpdatedDate, 
			Campaign_MachineID, Campaign_MachineName,
			Campaign_MinBet, Campaign_MaxBet, Campaign_MinWin, Campaign_MaxWin )
			VALUES (
			@strTypeName,@intTypeID,@strName,@strStartDate,@strEndDate,@dblRate,@strRemarks,
			@intStatus,@strUsercode,GETDATE(),@strUsercode,GETDATE(), @intMachineID, @strMachineName,
			@dblMinBet, @dblMaxBet, @dblMinWin, @dblMaxWin)
			SELECT @ID = SCOPE_IDENTITY()

		END
		ELSE
		BEGIN
			set @ID = 0
			RAISERROR ('Error: Campaign name already used, Please try another name.',16,1);  
			Rollback TRANSACTION
			SET NOCOUNT OFF
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
