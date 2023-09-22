/****** Object:  Procedure [dbo].[Local_sp_tblPayment_Refund_Card]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Refund_Card '9090','9090','aaa','Hallaway01','C18RE00000800','1050211017','','',0

CREATE PROCEDURE [dbo].[Local_sp_tblPayment_Refund_Card]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strClientUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strReceiptNo		nvarchar(50),
	@strCardNumber		nvarchar(50),
	@strNewReceiptNo		nvarchar(50) OUT,
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT,
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	set @strNewReceiptNo = ''
	set @strClientFullName = ''
	set @strClientBalance = 0

	------- Make for Hallaway and skydome, Manager Access Code
	--if @strPOSUserCode = ''
	--BEGIN
	--	ROLLBACK TRANSACTION
	--	SET NOCOUNT OFF
	--	RETURN (-11)
	--END
	--ELSE
	--BEGIN
		
	--	if (select COUNT(POSUser_ID) from tblPOSUser where POSUser_Password = @strPOSUserCode 
	--	AND POSUser_CompanyCode = @strCompanyCode AND POSUser_UserType = 1) = 0 
	--	BEGIN
	--		ROLLBACK TRANSACTION
	--		SET NOCOUNT OFF
	--		RETURN (-12)
	--	END
	--END

	DECLARE @intCount_Card int
	DECLARE @strMobileUser	nvarchar(50)
	select @intCount_Card = COUNT(Card_ID) from tblCard where Card_SerialNo = @strCardNumber
	set @strMobileUser = ''

	if @intCount_Card = 0
	BEGIN
		COMMIT TRANSACTION
		SET NOCOUNT OFF
		RETURN (-20)
	END

	if @intCount_Card > 0
	BEGIN
		select @strMobileUser = Card_MobileUser from tblCard where Card_SerialNo = @strCardNumber
	END

	Declare @dblCardBalance money
	select @dblCardBalance = Card_Balance, @strClientBalance = Card_Balance  from tblCard where Card_SerialNo = @strCardNumber

	set @strClientFullName = @strCardNumber

	Declare @intCount int
	select @intCount = ISNULL(COUNT(Payment_ID), 0) from tblPayment_Header 
	where Payment_ReceiptNo = @strReceiptNo --AND Payment_UserCode = @strClientUserCode
	if @intCount = 0
	BEGIN
		COMMIT TRANSACTION
		SET NOCOUNT OFF
		--print -1
		RETURN (-1)
	END

	if @strMobileUser = ''
	BEGIN
		Declare @strReceiptMobile nvarchar(50)
		select @strReceiptMobile = Payment_UserCode from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

		if @strCardNumber <> @strReceiptMobile
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-9)
		END

		set @strClientUserCode = @strCardNumber
	END
	ELSE
	BEGIN
		
		Declare @strReceiptUserCode nvarchar(50)
		select @strReceiptUserCode = Payment_UserCode from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo
		set @strClientUserCode = @strMobileUser
		if @strClientUserCode <> @strReceiptUserCode
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END
	END


	Declare @intWalletTransType int
	set @intWalletTransType = 3
	Declare @dblTotalNetAmt	money
	set @dblTotalNetAmt = 0
	DECLARE @PrefixType VARCHAR(50), @intRowCount INT
	set @PrefixType = 'Receipt'
	EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strNewReceiptNo OUTPUT
	Declare @strCounterPrefix nvarchar(50) = ''
	select @strCounterPrefix = Counter_ID from tblCounter where Counter_Code = @strCounterCode
	set @strCounterPrefix = 'C' + @strCounterPrefix
	set @strNewReceiptNo = @strCounterPrefix + @strNewReceiptNo
	
	--select @dblTotalNetAmt = ISNULL(SUM(PaymentD_NetAmount),0) from tblPayment_Details D
	--inner join tblProduct P on D.PaymentD_ItemCode = P.Product_ItemCode
	--where PaymentD_ReceiptNo = @strReceiptNo
	--AND P.Product_WalletsTransType  <> 10
	select @dblTotalNetAmt = ISNULL(SUM(Payment_FinalAmt),0) from tblPayment_Header H
	--inner join tblProduct P on D.PaymentD_ItemCode = P.Product_ItemCode
	where Payment_ReceiptNo = @strReceiptNo
	--AND P.Product_WalletsTransType  <> 10


	Declare @dblGlobalDiscount money = 0
	Select @dblGlobalDiscount = Payment_GlobalDiscountAmt from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo
	set @dblTotalNetAmt = @dblTotalNetAmt - @dblGlobalDiscount

	Declare @intPaymentType int
			
	Declare @intIsRefund int
		select @intIsRefund = payment_isRefund from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo
		if @intIsRefund = 0
		BEGIN
			
			
			INSERT INTO tblPayment_Header
			(Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, Payment_FinalAmt, 
			Payment_CounterCode, Payment_PaymentType, Payment_PayAmt, Payment_ReturnAmt, 
			Payment_Status, Payment_CreatedDate, Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
			Payment_UserCode, Payment_GlobalDiscount, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
			Payment_IsSettlement, Payment_TotalTaxAmt, Payment_IsRefund, Payment_CreatedBy, Payment_Remarks,
			Payment_RedeemAmt, Payment_RedeemPoint, Payment_DiscountMode,
			Payment_CollectionCode, Payment_TableCode, Payment_Pax, Payment_CompanyCode,Payment_SST, Payment_SC)
			Select @strNewReceiptNo, GETDATE(), Payment_GrossAmt * -1, Payment_DiscountAmt * -1, Payment_NetAmt * -1, 
			Payment_RoundUp * -1, Payment_FinalAmt * -1, 
			Payment_CounterCode, Payment_PaymentType, Payment_PayAmt * -1, Payment_ReturnAmt * -1, 
			Payment_Status, GETDATE(), Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
			@strClientUserCode, Payment_GlobalDiscount * -1, Payment_GlobalDiscountAmt * -1, Payment_AdjustmentAmt * -1, 
			Payment_IsSettlement, Payment_TotalTaxAmt * -1, 2, @strPOSUserCode, Payment_Remarks,
			Payment_RedeemAmt * -1, Payment_RedeemPoint * -1, Payment_DiscountMode,
			Payment_CollectionCode, Payment_TableCode, Payment_Pax, Payment_CompanyCode,Payment_SST * -1, Payment_SC * -1
			from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

			INSERT INTO tblPayment_Details
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
			PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
			PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, PaymentD_RunNo, PaymentD_DiscountMode,
			PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName)
			Select @strNewReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent * -1, 
			PaymentD_DiscountAmt * -1, PaymentD_NetAmount * -1, GETDATE(), PaymentD_Qty * -1, GETDATE(), 
			PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt * -1 , PaymentD_RunNo, PaymentD_DiscountMode,
			PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName
			from tblPayment_Details where PaymentD_ReceiptNo = @strReceiptNo

			set @intWalletTransType = 3
			INSERT INTO tblWalletTrans
			(WalletTrans_Code, WalletTrans_UserCode, WalletTrans_WalletCode, WalletTrans_Type, 
			WalletTrans_Value, WalletTrans_MoneyValue, WalletTrans_RefCode, WalletTrans_Remarks, 
			WalletTrans_CreatedBy, WalletTrans_CreatedDate, 
			WalletTrans_CampaignCode, WalletTrans_PaymentMode, WalletTrans_QRCodeText)
			select @strNewReceiptNo, @strClientUserCode, WalletTrans_WalletCode, @intWalletTransType, 
			WalletTrans_Value * -1, WalletTrans_MoneyValue, @strReceiptNo, WalletTrans_Remarks, 
			@strPOSUserCode, GETDATE(), 
			WalletTrans_CampaignCode, WalletTrans_PaymentMode, @strCardNumber
			from tblWalletTrans where WalletTrans_Code = @strReceiptNo


			Update tblPayment_Header set Payment_IsRefund = 1 where Payment_ReceiptNo = @strReceiptNo

			--DECLARE @dblNetAmount money
			--set @dblNetAmount = 0
			--select @dblNetAmount = Payment_FinalAmt from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

			
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			--print -2
			RETURN (-2)
		END

	if @strMobileUser = '' -- Mean havent attach any mobile user yet
	BEGIN
		set @intPaymentType = 10

		INSERT INTO tblCard_Trans
		(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
		CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
		CardTrans_PaymentMode)
		VALUES (
		--@strCardTrans,
		@strNewReceiptNo,
		@strCardNumber,GETDATE(),@intWalletTransType,@dblTotalNetAmt,@dblTotalNetAmt,
		@strReceiptNo,@strCardNumber,GETDATE(),'',10)

		Update tblCard set Card_Balance = Card_Balance + @dblTotalNetAmt 
		where Card_SerialNo = @strCardNumber
		
		select @strClientBalance = Card_Balance  from tblCard where Card_SerialNo = @strCardNumber

	END
	ELSE
	BEGIN
		set @intPaymentType = 6
		set @strClientUserCode = ''
		set @strClientBalance = 0
		select @strClientUserCode = mUser_Code,
		@strClientFullName = mUser_FullName, @strClientBalance = mUser_TotalBalance
		from tblUserMobile where mUser_Code = @strMobileUser

		DECLARE @dblWalletBalance money
		DECLARE @strWalletCode nvarchar(50)
		select @dblWalletBalance = UWallet_Balance, @strWalletCode = UWallet_Code
		from tblUserWallet where UWallet_UserCode = @strClientUserCode
		set @strClientBalance = @dblWalletBalance

		update tblUserWallet set UWallet_Balance = UWallet_Balance + @dblTotalNetAmt where UWallet_Code = @strWalletCode
		select @dblWalletBalance = UWallet_Balance from tblUserWallet where UWallet_UserCode = @strClientUserCode

		set @strClientBalance = @dblWalletBalance

		Update tblUserMobile set mUser_RandomCode = NULL, 
		mUser_TotalBalance = @strClientBalance where mUser_Code = @strClientUserCode
	END

	Declare @intRedeemType int = 11
	IF (select COUNT(T.CardPointTrans_ID) from tblCardPointTrans T (NOLOCK) where T.CardPointTrans_Code = @strReceiptNo and T.CardPointTrans_Type = @intRedeemType) > 0
	BEGIN
		Declare @RedeemPoint decimal(38, 10) = 0
		select @RedeemPoint = T.CardPointTrans_PointValue from tblCardPointTrans T (NOLOCK) where T.CardPointTrans_Code = @strReceiptNo and T.CardPointTrans_Type = @intRedeemType
		Declare @strRemarks nvarchar(50) = 'Void from ' + @strReceiptNo

		INSERT INTO tblCardPointTrans
		(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
		CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
		CardPointTrans_CampaignCode, 
		CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio)
		VALUES (
		@strNewReceiptNo,@strCardNumber,@intRedeemType,@RedeemPoint,@RedeemPoint,
		@strReceiptNo,@strRemarks,@strPOSUserCode,GETDATE(),'',
		@strCardNumber,0,0)

		Update tblCard set Card_Point = Card_Point + @RedeemPoint where Card_SerialNo = @strCardNumber
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
