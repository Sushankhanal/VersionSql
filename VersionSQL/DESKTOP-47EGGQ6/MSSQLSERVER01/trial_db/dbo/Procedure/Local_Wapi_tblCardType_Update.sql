/****** Object:  Procedure [dbo].[Local_Wapi_tblCardType_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_tblCard_Update 0,'00112233445566',1,0,'','',0,''
create PROCEDURE [dbo].[Local_Wapi_tblCardType_Update]
	-- Add the parameters for the stored procedure here
	@intID		int ,
	@strName	nvarchar(50),
	@intStatus	smallint,
	@dblRate	money,
	@strUsercode	nvarchar(50),
	@intSort	int,
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

	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

		Update tblCardType Set
		CardType_Name = @strName, CardType_Rate = @dblRate, CardType_Status = @intStatus,
		CardType_UpdatedBy = @strUsercode, CardType_UpdatedDate = GETDATE(),
		CardType_Sort = @intSort, CardType_TierCleanPeriodMth = @intTierCleanPeriodMth, 
		CardType_TierCleanFromDate = @intTierCleanFromDate, CardType_TierMinMaintainLevel = @intTierMinMaintainLevel, 
		CardType_MaintainLevelPeriodMth = @intMaintainLevelPeriodMth
		Where CardType_ID = @intID
		if @intID = 0
		BEGIN
			set @intID = 1
		END
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
