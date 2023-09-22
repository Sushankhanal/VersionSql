/****** Object:  Procedure [dbo].[sp_Sync_PaymentLocal]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_PaymentLocal]
	@strCompanyCode nvarchar(50),
	@intID			bigint,
	@strReceiptNo	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		if @strReceiptNo = ''
		BEGIN
			Select Payment_ID, Payment_ReceiptNo from tblPayment_Header where Payment_Sync = 0
			AND Payment_Status = 0
		END
		ELSE
		BEGIN
			Select Payment_ID, Payment_ReceiptNo from tblPayment_Header where Payment_Sync = 0 AND Payment_ReceiptNo = @strReceiptNo
			AND Payment_Status = 0
		END
		
	END
	ELSE
	BEGIN
	--convert(nvarchar(50),Payment_Date)
		select  Payment_ID, Payment_ReceiptNo, 
		convert(nvarchar(50),Payment_Date) as Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, 
		Payment_RoundUp, Payment_FinalAmt, Payment_CounterCode, Payment_PaymentType, Payment_PayAmt, Payment_ReturnAmt, 
		Payment_Status, 
		convert(nvarchar(50),Payment_CreatedDate) as Payment_CreatedDate, Payment_CardNumber, Payment_CardType, Payment_RefundCode, Payment_UserCode, 
		Payment_GlobalDiscount, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, Payment_IsSettlement, Payment_TotalTaxAmt, 
		Payment_IsRefund, Payment_CreatedBy, Payment_Remarks, Payment_RedeemAmt, Payment_RedeemPoint, Payment_DiscountMode, 
		ISNULL(Payment_CollectionCode,'') as Payment_CollectionCode, Payment_SettleCode, Payment_TableCode, Payment_Pax,
		Payment_CompanyCode, Payment_SST, Payment_SC, Payment_OrderNumber
		from tblPayment_Header
		where Payment_Sync = 0
		AND Payment_Status = 0
		AND Payment_ID = @intID

		--Declare @strReceiptNo nvarchar(50) = ''
		if @strReceiptNo = ''
		BEGIN
			select @strReceiptNo = Payment_ReceiptNo from tblPayment_Header
			where Payment_Sync = 0 AND Payment_Status = 0
			AND Payment_ID = @intID
		END

		

		select PaymentD_ID, PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
		PaymentD_DiscountAmt, PaymentD_NetAmount, 
		convert(nvarchar(50),PaymentD_TransDate) as PaymentD_TransDate, PaymentD_Qty, 
		convert(nvarchar(50),PaymentD_CreatedDate) as PaymentD_CreatedDate, PaymentD_UnitCost, 
        PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, PaymentD_RunNo, PaymentD_DiscountMode,
		PaymentD_ItemName, PaymentD_ItemNameChi, PaymentD_PrinterName
		from tblPayment_Details where PaymentD_ReceiptNo = @strReceiptNo


		select PaymentEx_ID, PaymentEx_ReceiptNo, PaymentEx_RunNo, PaymentEx_ItemCode, PaymentEx_ItemDesc, 
		PaymentEx_AddOnPrice, PaymentEx_CreatedBy, 
		convert(nvarchar(50),PaymentEx_CreatedDate) as PaymentEx_CreatedDate
		from tblPayment_Extra where PaymentEx_ReceiptNo = @strReceiptNo

		SELECT CardTrans_ID, CardTrans_Code, CardTrans_SerialNo, 
		convert(nvarchar(50),CardTrans_Date) as CardTrans_Date, CardTrans_Type, CardTrans_Value, 
		CardTrans_MoneyValue, CardTrans_RefCode, CardTrans_CreatedBy, 
		convert(nvarchar(50),CardTrans_CreatedDate) as CardTrans_CreatedDate, CardTrans_CampaignCode, 
		CardTrans_PaymentMode
		FROM tblCard_Trans
		WHERE  CardTrans_Code = @strReceiptNo

	END
    
END
