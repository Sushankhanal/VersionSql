/****** Object:  Procedure [dbo].[Wapi_tblCampaign_Reward_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCampaign_Reward_Update]
	-- Add the parameters for the stored procedure here
	@intID		int ,
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
	
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

		Update tblCampaign_Reward Set
		Reward_Type_ID = @intTypeID, Reward_Name = @strName, Reward_StartDate = @strStartDate, Reward_EndDate = @strEndDate,
		Reward_CreditCashable = @dblCreditCashable, Reward_CreditNonCashable = @dblCreditCashableNo, 
		Reward_MaxQty = @intMaxQty, Reward_ExpiryDay = @intExpiryDay, Reward_CardType =  @intCardType,
		Reward_Remarks = @strRemarks, Reward_Status = @intStatus,
		Reward_UpdatedBy = @strUsercode, Reward_UpdatedDate = GETDATE()
		Where Reward_ID = @intID

		--delete from tblCampaign_Machine where CampaignM_Campaign_ID = @intID

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
