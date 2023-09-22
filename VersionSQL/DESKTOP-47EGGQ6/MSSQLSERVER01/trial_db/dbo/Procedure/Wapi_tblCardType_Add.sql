/****** Object:  Procedure [dbo].[Wapi_tblCardType_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCardType_Add]
	-- Add the parameters for the stored procedure here
	@strName	nvarchar(50),
	@intStatus		smallint,
	@dblRate		money,
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
		Declare @intID bigint = 0
		Declare @strCompanyCode nvarchar(50) = ''
		select top 1 @strCompanyCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID

		if @strName = 'Normal' -- Normal
		BEGIN
			Update tblCardType Set
			CardType_Rate = @dblRate, CardType_Status = @intStatus,
			CardType_UpdatedBy = @strUsercode, CardType_UpdatedDate = GETDATE(),
			CardType_Sort = @intSort, CardType_TierCleanPeriodMth = @intTierCleanPeriodMth, 
			CardType_TierCleanFromDate = @intTierCleanFromDate, CardType_TierMinMaintainLevel = @intTierMinMaintainLevel, 
			CardType_MaintainLevelPeriodMth = @intMaintainLevelPeriodMth
			Where CardType_Name = @strName

			select @intID = CardType_ID from tblCardType (NOLOCK) Where CardType_Name = @strName 
			set @intResultCode = 1 --@intID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
		
		END
		ELSE
		BEGIN
			DECLARE @intCount INT = 0
			SELECT @intCount = ISNULL(COUNT([CardType_ID]), 0) FROM tblCardType NOLOCK  WHERE (CardType_Name = @strName )
		
			--set @intCount = 0
			IF @intCount = 0 
			BEGIN
			
				INSERT INTO tblCardType
			(CardType_Name, CardType_Rate, CardType_Status, CardType_CreatedBy, CardType_CreatedDate,
			CardType_Sort, CardType_TierCleanPeriodMth, CardType_TierCleanFromDate, CardType_TierMinMaintainLevel, CardType_MaintainLevelPeriodMth)
			VALUES (
			@strName,@dblRate,@intStatus,@strUsercode,GETDATE(),@intSort,@intTierCleanPeriodMth,@intTierCleanFromDate,@intTierMinMaintainLevel,
			@intMaintainLevelPeriodMth)

				SELECT @intID = SCOPE_IDENTITY()
				set @intResultCode = @intID
				set @strResultText = 'Success'
				select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
			END
			ELSE
			BEGIN
				set @intResultCode = -1
				set @strResultText = 'Card type name already registred, Please try another name.'
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
				RETURN (-1)
			END
		END
		

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
