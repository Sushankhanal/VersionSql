/****** Object:  Procedure [dbo].[sp_Sync_Payment_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Payment_insert]
	@ID		int OUT,
	@Xml XML,
	@strCode	nvarchar(50),
	@strCompanyCode	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	set @ID = 0

	DECLARE @objXml XML, @intDoc INT
	
	SELECT @objXml = @Xml
	EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml

	DECLARE @intCount INT
	select @intCount = ISNULL(COUNT(Payment_ID), 0) from tblPayment_Header where Payment_ReceiptNo = @strCode

	IF @intCount = 0 
	BEGIN
		INSERT INTO tblPayment_Header
		(Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
		Payment_FinalAmt, Payment_CounterCode, Payment_PaymentType, Payment_PayAmt, 
		Payment_ReturnAmt, Payment_Status, Payment_CreatedDate, Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
		Payment_UserCode, Payment_GlobalDiscount, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
		Payment_IsSettlement, Payment_TotalTaxAmt, Payment_IsRefund, Payment_CreatedBy, Payment_Remarks, Payment_RedeemAmt, 
		Payment_RedeemPoint, Payment_DiscountMode, Payment_CollectionCode, Payment_Sync, 
		Payment_SyncDate)
		Select Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
		Payment_FinalAmt, Payment_CounterCode, Payment_PaymentType, Payment_PayAmt, 
		Payment_ReturnAmt, Payment_Status, Payment_CreatedDate, Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
		Payment_UserCode, Payment_GlobalDiscount, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
		Payment_IsSettlement, Payment_TotalTaxAmt, Payment_IsRefund, Payment_CreatedBy, Payment_Remarks, Payment_RedeemAmt, 
		Payment_RedeemPoint, Payment_DiscountMode, Payment_CollectionCode, 1, GETDATE()
		FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
		WITH (Payment_ReceiptNo nvarchar(50), Payment_Date datetime, Payment_GrossAmt money, Payment_DiscountAmt money, 
		Payment_NetAmt money, Payment_RoundUp money, 
		Payment_FinalAmt money, Payment_CounterCode nvarchar(50), Payment_PaymentType int, Payment_PayAmt money, 
		Payment_ReturnAmt money, Payment_Status int, Payment_CreatedDate datetime, Payment_CardNumber nvarchar(50), 
		Payment_CardType nvarchar(50), Payment_RefundCode nvarchar(50), 
		Payment_UserCode nvarchar(50), Payment_GlobalDiscount money, Payment_GlobalDiscountAmt money, Payment_AdjustmentAmt money, 
		Payment_IsSettlement smallint, Payment_TotalTaxAmt money, Payment_IsRefund smallint, Payment_CreatedBy nvarchar(50), 
		Payment_Remarks nvarchar(50), Payment_RedeemAmt money, 
		Payment_RedeemPoint money, Payment_DiscountMode money, Payment_CollectionCode nvarchar(50))
		SELECT @ID = SCOPE_IDENTITY()
	
		INSERT INTO tblPayment_Details
		(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
		PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, 
		PaymentD_CreatedDate, PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, PaymentD_RunNo, PaymentD_DiscountMode)
		Select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
		PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, 
		PaymentD_CreatedDate, PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, PaymentD_RunNo, PaymentD_DiscountMode
		FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
		WITH (PaymentD_ReceiptNo nvarchar(50), PaymentD_ItemCode nvarchar(50), PaymentD_UOM nvarchar(50), PaymentD_UnitPrice money, 
		PaymentD_DiscountPercent money, 
		PaymentD_DiscountAmt money, PaymentD_NetAmount money, PaymentD_TransDate datetime, PaymentD_Qty int, 
		PaymentD_CreatedDate datetime, PaymentD_UnitCost money, PaymentD_TaxCode nvarchar(50), PaymentD_TaxRate money, PaymentD_TaxAmt money,
		PaymentD_RunNo int, PaymentD_DiscountMode smallint)
	
		INSERT INTO tblPayment_Extra
		(PaymentEx_ReceiptNo, PaymentEx_RunNo, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice, PaymentEx_CreatedBy, PaymentEx_CreatedDate)
		Select PaymentEx_ReceiptNo, PaymentEx_RunNo, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice, PaymentEx_CreatedBy, PaymentEx_CreatedDate
		FROM OPENXML (@intDoc,  N'/NewDataSet/Table2', 2)
		WITH (PaymentEx_ReceiptNo nvarchar(50), PaymentEx_RunNo int, PaymentEx_ItemCode nvarchar(50), PaymentEx_ItemDesc nvarchar(50), 
		PaymentEx_AddOnPrice money, PaymentEx_CreatedBy nvarchar(50), PaymentEx_CreatedDate datetime)

	END

	
	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
