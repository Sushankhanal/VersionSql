/****** Object:  Procedure [dbo].[sp_tblPlayerLevel_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPlayerLevel_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@strName	nvarchar(50),
	@intStatus	smallint,
	@intSort	int,
	@dblRate	money,
	@strUsercode		nvarchar(50),
	@intTierCleanPeriodMth	int, 
	@intTierCleanFromDate	datetime,
	@intTierMinMaintainLevel	int,
	 @intMaintainLevelPeriodMth int

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Update tblPlayerLevel Set
		PlayerLevel_Name = @strName, PlayerLevel_Sort = @intSort, PlayerLevel_Rate = @dblRate, PlayerLevel_Status = @intStatus,
		PlayerLevel_UpdatedBy = @strUsercode, PlayerLevel_UpdatedDate = GETDATE(),
		PlayerLevel_TierCleanPeriodMth =@intTierCleanPeriodMth,PlayerLevel_TierCleanFromDate =@intTierCleanFromDate,
		PlayerLevel_TierMinMaintainLevel =@intTierMinMaintainLevel,PlayerLevel_MaintainLevelPeriodMth=@intMaintainLevelPeriodMth

		Where PlayerLevel_ID = @ID

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
