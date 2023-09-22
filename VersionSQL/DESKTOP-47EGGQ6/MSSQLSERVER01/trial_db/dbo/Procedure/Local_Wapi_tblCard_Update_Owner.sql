/****** Object:  Procedure [dbo].[Local_Wapi_tblCard_Update_Owner]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_Wapi_tblCard_Update_Owner]
	-- Add the parameters for the stored procedure here
	@intCardID		bigint ,
	@intPlayerID	bigint,
	@CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

	Update tblCard Set Card_CardOwner_ID = @intPlayerID Where Card_ID = @intCardID
	set @CardId=@intCardID
	
	--- Added BY ricky 2021-11-10
	Declare @intCardType as int = 0
	select @intCardType = c.Card_Type  from tblCard c (NOLOCK) where Card_ID = @intCardID
	if (select COUNT(Reward_ID) from tblCampaign_Reward a (NOLOCK) where GETDATE() >= a.Reward_StartDate AND GETDATE() <= a.Reward_EndDate  
	AND a.Reward_Status = 0 AND a.Reward_Type_ID = 1 AND a.Reward_CardType = @intCardType) <> 0
	BEGIN
		if (select COUNT(c.Card_ID) from tblCard c (NOLOCK) where c.Card_CardOwner_ID = @intPlayerID) = 1
		BEGIN
			Declare @dblRPoint money = 0
			Declare @dblRCredit money = 0
			Declare @dblRCreditCashable money = 0
			Declare @dblRCreditCashableNon money = 0

			select @dblRPoint = a.Reward_Points,
			@dblRCredit = a.Reward_Credit,
			@dblRCreditCashable = a.Reward_CreditCashable,
			@dblRCreditCashableNon = a.Reward_CreditNonCashable 
			from tblCampaign_Reward a (NOLOCK) where GETDATE() >= a.Reward_StartDate AND GETDATE() <= a.Reward_EndDate  
			AND a.Reward_Status = 0 AND a.Reward_Type_ID = 1 AND a.Reward_CardType = @intCardType

			Update tblCard Set Card_Point = Card_Point + @dblRPoint,
			Card_Balance = Card_Balance + @dblRCredit,
			Card_Balance_Cashable = Card_Balance_Cashable + @dblRCreditCashable,
			Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblRCreditCashableNon
			Where Card_ID = @intCardID
			set @CardId=@intCardID
		END
	END
	

	set @intResultCode = @intCardID
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
