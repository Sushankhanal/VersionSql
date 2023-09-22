/****** Object:  Procedure [dbo].[sp_tblPayment_ItemRePrint]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblPayment_ItemRePrint] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50),
	@strReceiptNo	nvarchar(50),
	@intPaymentDID	bigint,
	@strItemCode	nvarchar(50)
) AS
BEGIN

	--Select PaymentD_ReceiptNo, PaymentD_ItemCode, P.Product_Desc, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_Qty, PaymentD_DiscountPercent, 
	--PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, 
	--PaymentD_RunNo as DetailID, 
	--ISNULL(dbo.fnCombineAllAddOn(PaymentD_ReceiptNo,PaymentD_RunNo),'') as AddOnValue  from tblPayment_Details PD
	--inner join tblProduct P on PD.PaymentD_ItemCode = P.Product_ItemCode
	--where PaymentD_ReceiptNo = @strReceiptNo
	--AND PaymentD_RunNo = @intRunNo
	--AND PaymentD_ItemCode = @strItemCode

	INSERT INTO tblPayment_Details_Print
	(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
	PaymentD_RunNo, PaymentD_Status, PaymentD_PrintStatus, PaymentD_Detail_ID, PaymentD_CompanyCode, PaymentD_ItemName, PaymentD_ItemNameChi,PaymentD_PrinterName )
	Select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, GETDATE(), 
	PaymentD_RunNo , 'Re-Print',0, PaymentD_ID, @CompanyCode, PaymentD_ItemName, PaymentD_ItemNameChi,PaymentD_PrinterName
	from tblPayment_Details 
	where PaymentD_ReceiptNo = @strReceiptNo
	AND PaymentD_ItemCode = @strItemCode
	AND PaymentD_RunNo = @intPaymentDID

	Select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, PaymentD_Qty, GETDATE(), 
	PaymentD_RunNo , 'Re-Print',0, PaymentD_ID, @CompanyCode, PaymentD_ItemName, PaymentD_ItemNameChi,PaymentD_PrinterName
	from tblPayment_Details 
	where PaymentD_ReceiptNo = @strReceiptNo
	AND PaymentD_ItemCode = @strItemCode
	AND PaymentD_RunNo = @intPaymentDID

	--select PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_TransDate, @intQty, GETDATE(), 
	--PaymentD_RunNo, 'new',0, @intDetailID, @strCompanyCode from tblPayment_Details where PaymentD_ID = @intDetailID

END
