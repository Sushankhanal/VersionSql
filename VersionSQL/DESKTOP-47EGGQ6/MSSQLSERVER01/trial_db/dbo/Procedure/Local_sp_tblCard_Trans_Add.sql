/****** Object:  Procedure [dbo].[Local_sp_tblCard_Trans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCard_Trans_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strCardNumber	nvarchar(50),
	@intTransType	int,
	@dblValue		money,
	@strRemarks		nvarchar(50),
	@strUserID		nvarchar(50),
	@strBranchCode	nvarchar(50),
	@strManagerLogin	nvarchar(50) = '',
	@strManagerPassword	nvarchar(50) = '',
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON addedto prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	DECLARE @PrefixType VARCHAR(50), @intRowCount INT
	Declare @strReceiptNo nvarchar(50) = ''
	if @intTransType = 22 or @intTransType = 23 or @intTransType = 24
	BEGIN
		Declare @intCount int = 0
		select @intCount = COUNT(P.POSUser_ID) from tblPOSUser P (NOLOCK) where P.POSUser_UserType = 1 and
		POSUser_LoginID = @strManagerLogin and 
		POSUser_Password = @strManagerPassword

		if @intCount = 0
		BEGIN
			set @intErrorCode = -1
			set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
			' - Invalid manager login and password.'
			RAISERROR (@strErrorText,16,1);  
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			Return @intErrorCode
		END
	END


	set @PrefixType = 'Receipt'
	EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT

	DECLARE @strCompanyCode nvarchar(50)
	select @strCompanyCode = Branch_CompanyCode from tblBranch where Branch_Code = @strBranchCode

	Declare @intPaymentType int = 1
	Declare @intItemSign int = 0
	select @intItemSign = WTransType_Sign  from tblWalletTransType where WTransType_ID = @intTransType

	INSERT INTO tblCard_Trans
		(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
		CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
		CardTrans_PaymentMode)
		VALUES (
		--@strCardTrans,
		@strReceiptNo,
		@strCardNumber,GETDATE(),@intTransType,@dblValue * @intItemSign,@dblValue,
		@strReceiptNo,@strUserID,GETDATE(),'',@intPaymentType)
		SELECT @ID = SCOPE_IDENTITY()

		if @intTransType = 22
		BEGIN
			Update tblCard set Card_Balance = Card_Balance + @dblValue where Card_SerialNo = @strCardNumber
			set @CardId=@strCardNumber
		END
		if @intTransType = 23
		BEGIN
			Update tblCard set Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblValue where Card_SerialNo = @strCardNumber
			set @CardId=@strCardNumber
		END
		if @intTransType = 24
		BEGIN
			Update tblCard set Card_Balance_Cashable = Card_Balance_Cashable + @dblValue where Card_SerialNo = @strCardNumber
			set @CardId=@strCardNumber
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
