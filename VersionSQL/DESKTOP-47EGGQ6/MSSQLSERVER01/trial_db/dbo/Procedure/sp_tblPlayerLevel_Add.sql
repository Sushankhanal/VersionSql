/****** Object:  Procedure [dbo].[sp_tblPlayerLevel_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPlayerLevel_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
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

		DECLARE @intCount INT
		--DECLARE @ID INT
		--SELECT @intCount = ISNULL(COUNT(mUser_ID), 0) FROM tblUserMobile NOLOCK 
		--WHERE (mUser_LoginID = @strLoginID )

		
		set @intCount = 0
		IF @intCount = 0 
		BEGIN
			
			INSERT INTO tblPlayerLevel
			(PlayerLevel_Name, PlayerLevel_Sort, PlayerLevel_Rate, PlayerLevel_Status, PlayerLevel_CreatedBy, PlayerLevel_CreatedDate,
			PlayerLevel_TierCleanPeriodMth,PlayerLevel_TierCleanFromDate,PlayerLevel_TierMinMaintainLevel,PlayerLevel_MaintainLevelPeriodMth)
			VALUES (
			@strName,@intSort,@dblRate, @intStatus,@strUsercode,GETDATE(),
			@intTierCleanPeriodMth, @intTierCleanFromDate, @intTierMinMaintainLevel, @intMaintainLevelPeriodMth)
			SELECT @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			RAISERROR ('Error',16,1);  
			COMMIT TRANSACTION
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
