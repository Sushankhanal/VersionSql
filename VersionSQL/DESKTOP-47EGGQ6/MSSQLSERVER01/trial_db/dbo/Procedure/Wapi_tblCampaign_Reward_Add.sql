/****** Object:  Procedure [dbo].[Wapi_tblCampaign_Reward_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Wapi_tblCampaign_Reward_Add]
	-- Add the parameters for the stored procedure here
	@intTypeID		int,
	@strName		nvarchar(50),
	@strStartDate	datetime,
	@strEndDate		datetime,
	@dblCreditCashable		money,
	@dblCreditCashableNo		money,
	@intMaxQty		int,
	@intExpiryDay	int,	
	@strRemarks		nvarchar(500),
	@intStatus		smallint,
	@intCardType	int,
	@strUsercode	nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Declare @ID	bigint = 0
		Declare @strResultText nvarchar(255) = ''
		Declare @intResultCode int = 0

		DECLARE @intCount INT = 0
		SELECT @intCount = ISNULL(COUNT(Reward_ID), 0) FROM tblCampaign_Reward NOLOCK WHERE (Reward_Name = @strName )
		
		IF @intCount = 0 
		BEGIN
			INSERT INTO tblCampaign_Reward
			(Reward_Type_ID, Reward_Name, Reward_StartDate, Reward_EndDate, 
			Reward_CreditCashable, Reward_CreditNonCashable,Reward_MaxQty,
			Reward_ExpiryDay, Reward_Status, Reward_Remarks, 
			Reward_CardType, Reward_CreatedBy, Reward_CreatedDate, Reward_UpdatedBy, Reward_UpdatedDate)
			VALUES (
			@intTypeID,@strName,@strStartDate,@strEndDate,
			@dblCreditCashable,@dblCreditCashableNo , @intMaxQty, 
			@intExpiryDay, @intStatus, @strRemarks,
			@intCardType,@strUsercode,GETDATE(),@strUsercode,GETDATE())
			SELECT @ID = SCOPE_IDENTITY()

			set @intResultCode = @ID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

		END
		ELSE
		BEGIN
			set @ID = -1
			set @strResultText = 'Campaign name already used, Please try another name.'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
