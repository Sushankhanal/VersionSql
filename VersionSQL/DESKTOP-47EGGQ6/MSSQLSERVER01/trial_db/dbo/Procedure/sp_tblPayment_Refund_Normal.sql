/****** Object:  Procedure [dbo].[sp_tblPayment_Refund_Normal]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPayment_Refund_Normal]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strReceiptNo		nvarchar(50),
	@strNewReceiptNo		nvarchar(50) OUT,
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @strPOSUserCode = ''
	BEGIN
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		RETURN (-11)
	END
	ELSE
	BEGIN
		
		if (select COUNT(POSUser_ID) from tblPOSUser where POSUser_Password = @strPOSUserCode 
		AND POSUser_CompanyCode = @strCompanyCode AND POSUser_UserType = 1) = 0 
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-12)
		END
	END

	set @strNewReceiptNo = ''
	set @strClientFullName = ''
	set @strClientBalance = 0
	
	Declare @intCount int
	select @intCount = ISNULL(COUNT(Payment_ID), 0) from tblPayment_Header 
	where Payment_ReceiptNo = @strReceiptNo 
	if @intCount = 0
	BEGIN
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		--print -1
		RETURN (-1)
	END
	ELSE
	BEGIN
		Declare @intIsRefund int= 0
		select @intIsRefund = payment_isRefund from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo
		if @intIsRefund = 0
		BEGIN
			DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			--Declare @strNewReceiptNo nvarchar(50)
			set @PrefixType = 'Receipt'
			EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strNewReceiptNo OUTPUT
			Declare @strCounterPrefix nvarchar(50) = ''
			select @strCounterPrefix = Counter_ID from tblCounter where Counter_Code = @strCounterCode
			set @strCounterPrefix = 'C' + @strCounterPrefix
			set @strNewReceiptNo = @strCounterPrefix + @strNewReceiptNo

			Declare @intPaymentType int
			set @intPaymentType = 6
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
			Payment_UserCode, Payment_GlobalDiscount * -1, Payment_GlobalDiscountAmt * -1, Payment_AdjustmentAmt * -1, 
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


			Update tblPayment_Header set Payment_IsRefund = 1 where Payment_ReceiptNo = @strReceiptNo

			
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
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
