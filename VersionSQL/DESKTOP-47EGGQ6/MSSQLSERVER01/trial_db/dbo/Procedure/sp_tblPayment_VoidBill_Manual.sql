/****** Object:  Procedure [dbo].[sp_tblPayment_VoidBill_Manual]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPayment_VoidBill_Manual]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strClientUserCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strReceiptNo		nvarchar(50),
	@intUserID			int,
	@strNewReceiptNo	nvarchar(50) OUT,
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @strClientRandomCode nvarchar(1024)
	set @strClientUserCode = ''
	set @strClientRandomCode = ''
	select @strClientUserCode = mUser_Code,
	@strClientFullName = mUser_FullName from tblUserMobile where mUser_ID = @intUserID

	set @strClientBalance = 0

	if @strClientUserCode = ''
	BEGIN
		set @strClientFullName = ''
		set @strClientBalance = 0
		COMMIT TRANSACTION
		SET NOCOUNT OFF
		RETURN (-6)
	END
	
	--Declare @intCount_CorrectUserCode int
	--select @intCount_CorrectUserCode = payment_isRefund from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

	DECLARE @dblWalletBalance money
	DECLARE @strWalletCode nvarchar(50)
	select @dblWalletBalance = UWallet_Balance, @strWalletCode = UWallet_Code
	from tblUserWallet where UWallet_UserCode = @strClientUserCode
	set @strClientBalance = @dblWalletBalance

	Declare @intCount int
	select @intCount = ISNULL(COUNT(Payment_ID), 0) from tblPayment_Header 
	where Payment_ReceiptNo = @strReceiptNo AND Payment_UserCode = @strClientUserCode
	if @intCount = 0
	BEGIN
		COMMIT TRANSACTION
		SET NOCOUNT OFF
		--print -1
		RETURN (-1)
	END
	ELSE
	BEGIN
		Declare @intIsRefund int
		Declare @strReceiptUserCode nvarchar(50)
		select @intIsRefund = payment_isRefund, @strReceiptUserCode = Payment_UserCode from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

		if @strClientUserCode <> @strReceiptUserCode
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END

		if @intIsRefund = 0
		BEGIN
			DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			--Declare @strNewReceiptNo nvarchar(50)
			set @PrefixType = 'Receipt'
			EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strNewReceiptNo OUTPUT
	
			Declare @intPaymentType int
			set @intPaymentType = 6
			INSERT INTO tblPayment_Header
			(Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, Payment_FinalAmt, 
			Payment_CounterCode, Payment_PaymentType, Payment_PayAmt, Payment_ReturnAmt, 
			Payment_Status, Payment_CreatedDate, Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
			Payment_UserCode, Payment_GlobalDiscount, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
			Payment_IsSettlement, Payment_TotalTaxAmt, Payment_IsRefund, Payment_CreatedBy)
			Select @strNewReceiptNo, GETDATE(), Payment_GrossAmt * -1, Payment_DiscountAmt * -1, Payment_NetAmt * -1, 
			Payment_RoundUp * -1, Payment_FinalAmt * -1, 
			Payment_CounterCode, Payment_PaymentType, Payment_PayAmt * -1, Payment_ReturnAmt * -1, 
			Payment_Status, GETDATE(), Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
			@strClientUserCode, Payment_GlobalDiscount * -1, Payment_GlobalDiscountAmt * -1, Payment_AdjustmentAmt * -1, 
			Payment_IsSettlement, Payment_TotalTaxAmt * -1, 2, @strPOSUserCode
			from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

			INSERT INTO tblPayment_Details
			(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
			PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
			PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt)
			Select @strNewReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent * -1, 
			PaymentD_DiscountAmt * -1, PaymentD_NetAmount * -1, GETDATE(), PaymentD_Qty * -1, GETDATE(), 
			PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt * -1 
			from tblPayment_Details where PaymentD_ReceiptNo = @strReceiptNo

			Declare @intWalletTransType int
			set @intWalletTransType = 3
			INSERT INTO tblWalletTrans
			(WalletTrans_Code, WalletTrans_UserCode, WalletTrans_WalletCode, WalletTrans_Type, 
			WalletTrans_Value, WalletTrans_MoneyValue, WalletTrans_RefCode, WalletTrans_Remarks, 
			WalletTrans_CreatedBy, WalletTrans_CreatedDate, 
			WalletTrans_CampaignCode, WalletTrans_PaymentMode, WalletTrans_QRCodeText)
			select @strNewReceiptNo, @strClientUserCode, WalletTrans_WalletCode, @intWalletTransType, 
			WalletTrans_Value * -1, WalletTrans_MoneyValue, @strReceiptNo, WalletTrans_Remarks, 
			@strPOSUserCode, GETDATE(), 
			WalletTrans_CampaignCode, WalletTrans_PaymentMode, ''
			from tblWalletTrans where WalletTrans_Code = @strReceiptNo


			Update tblPayment_Header set Payment_IsRefund = 1 where Payment_ReceiptNo = @strReceiptNo

			DECLARE @dblNetAmount money
			set @dblNetAmount = 0
			select @dblNetAmount = Payment_FinalAmt from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

			update tblUserWallet set UWallet_Balance = UWallet_Balance + @dblNetAmount where UWallet_Code = @strWalletCode
			select @dblWalletBalance = UWallet_Balance from tblUserWallet where UWallet_UserCode = @strClientUserCode

			set @strClientBalance = @dblWalletBalance

			Update tblUserMobile set mUser_RandomCode = NULL, 
			mUser_TotalBalance = @strClientBalance where mUser_Code = @strClientUserCode

			Declare @intPointTransType int = 3
				Declare @strPointRemarks nvarchar(50) =''
				set @strPointRemarks = 'Void from ' + @strReceiptNo
				INSERT INTO tblPointTrans
				(PointTrans_Code, PointTrans_UserCode, PointTrans_Type, PointTrans_Value, PointTrans_PointValue, 
				PointTrans_RefCode, PointTrans_Remarks, PointTrans_CreatedBy, PointTrans_CreatedDate, PointTrans_CampaignCode, 
				PointTrans_QRCodeText, PointTrans_WalletAmt, PointTrans_Ratio)
				select @strNewReceiptNo, PointTrans_UserCode, @intPointTransType, PointTrans_Value * -1, 
				PointTrans_PointValue, @strReceiptNo, @strPointRemarks, @strPOSUserCode, GETDATE(), 
                '', '', PointTrans_WalletAmt, PointTrans_Ratio * -1
				from tblPointTrans where PointTrans_Code = @strReceiptNo

				Declare @dblTotalAddMinusPoint money =0
				select @dblTotalAddMinusPoint = ISNULL(SUM(PointTrans_Value),0) from tblPointTrans where PointTrans_Code = @strNewReceiptNo

				Update tblUserMobile set mUser_TotalPoint = mUser_TotalPoint + @dblTotalAddMinusPoint
				where mUser_Code = @strClientUserCode

			
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			--print -2
			RETURN (-2)
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
