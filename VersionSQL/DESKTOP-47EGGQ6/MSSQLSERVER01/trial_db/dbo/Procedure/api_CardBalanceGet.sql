/****** Object:  Procedure [dbo].[api_CardBalanceGet]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- exec api_CardBalanceGet '01234567890', 1
CREATE PROCEDURE [dbo].[api_CardBalanceGet]
	-- Add the parameters for the stored procedure here
	@strCardNo		nvarchar(50),
	@intMoneyType	int,
	@intMoneyType1	int
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON addedto prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @ID bigint = 0

	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	Declare @intCount int = 0
		
		if @strCardNo = ''
		BEGIN
			set @intErrorCode = -97
			set @strErrorText = 'Card Number can not be blank'
			select @intErrorCode as ResultCode, @strErrorText as ResultDesc, 0 as Card_ID, 
			'' as Card_SerialNo, 0  as Card_BalanceByType, '' as MoneyType 
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			return @intErrorCode
		END

		
		if @intMoneyType <> 1 And @intMoneyType <> 2 And @intMoneyType <> 3
		BEGIN
			set @intErrorCode = -96
			set @strErrorText = 'Invalid Money Type'
			select @intErrorCode as ResultCode, @strErrorText as ResultDesc, 0 as Card_ID, 
			'' as Card_SerialNo, 0  as Card_BalanceByType, '' as MoneyType 
			--from tblCard C (NOLOCK) where Card_SerialNo = @strCardNo
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			return @intErrorCode
		END

		Declare @strMoneyType nvarchar(50) = ''
		if @intMoneyType = 1
		BEGIN
			set @strMoneyType = 'Cash' 
		END
		ELSE if @intMoneyType = 2
		BEGIN
			set @strMoneyType = 'Cashable' 
		END
		ELSE if @intMoneyType = 3
		BEGIN
			set @strMoneyType = 'Non Cashable' 
		END

		select @intCount = COUNT(C.Card_ID) from tblCard C (NOLOCK) where C.Card_SerialNo = @strCardNo
		if @intCount = 0
		BEGIN
			set @intErrorCode = -2
			set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
			' - Card number not exist'
			select @intErrorCode as ResultCode, @strErrorText as ResultDesc, 0 as Card_ID, 
			'' as Card_SerialNo, 0  as Card_BalanceByType, @strMoneyType as MoneyType 
			--from tblCard C (NOLOCK) where Card_SerialNo = @strCardNo
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			return @intErrorCode
		END

		set @intErrorCode = 0
		set @strErrorText = ''

		if @intMoneyType = 1
		BEGIN
			select @intErrorCode as ResultCode, @strErrorText as ResultDesc, C.Card_ID, 
			C.Card_SerialNo, C.Card_Balance as Card_BalanceByType, 'Cash' as MoneyType from tblCard C (NOLOCK) where Card_SerialNo = @strCardNo
		END
		if @intMoneyType = 2
		BEGIN
			select @intErrorCode as ResultCode, @strErrorText as ResultDesc,C.Card_ID, 
			C.Card_SerialNo, C.Card_Balance_Cashable as Card_BalanceByType, 'Cashable' as MoneyType from tblCard C (NOLOCK) where Card_SerialNo = @strCardNo
		END
		if @intMoneyType = 3
		BEGIN
			select @intErrorCode as ResultCode, @strErrorText as ResultDesc, C.Card_ID,
			C.Card_SerialNo, C.Card_Balance_Cashable_No as Card_BalanceByType, 'Non Cashable' as MoneyType from tblCard C (NOLOCK) where Card_SerialNo = @strCardNo
		END


	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
