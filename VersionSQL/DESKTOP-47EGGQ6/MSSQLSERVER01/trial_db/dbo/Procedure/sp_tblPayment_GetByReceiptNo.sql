/****** Object:  Procedure [dbo].[sp_tblPayment_GetByReceiptNo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblPayment_GetByReceiptNo] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50),
	@strReceiptNo	nvarchar(50)
) AS
BEGIN
	
	
select Payment_ID, Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
	Payment_FinalAmt, Payment_PaymentType, Payment_PayAmt, 
	Payment_ReturnAmt, Payment_CardNumber, Payment_CardType, 
	Payment_UserCode, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
	Payment_TotalTaxAmt, PM.PaymentMode_Name, Payment_Remarks,
	(CASE Payment_IsRefund WHEN 1 THEN 'Voided' WHEN 2 THEN 'Void receipt' ELSE '' END) as RefundStatus,
	(CASE ISNULL(UM.mUser_FullName,'') WHEN '' THEN H.Payment_UserCode ELSE UM.mUser_FullName END) as ClientName,
	Company_Name, Company_RegNo, Company_Address1, Company_Address2, PM.PaymentMode_Name,
	Payment_CollectionCode, Payment_TableCode,
	ISNULL((select top 1 Table_Name from tblTable where Table_Code = H.Payment_TableCode),'') as TableName,
	Payment_SST, Payment_SC
	from tblPayment_Header H
	inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
	left outer join tblUserMobile UM on H.Payment_UserCode = UM.mUser_Code
	inner join tblCounter CC on CC.Counter_Code = H.Payment_CounterCode
	inner join tblCompany C on C.Company_Code = CC.Counter_CompanyCode
	where Payment_CounterCode = @CounterCode
	AND Payment_ReceiptNo = @strReceiptNo
	Order by Payment_ReceiptNo

	Select PaymentD_ReceiptNo, PaymentD_ItemCode, 
	--P.Product_Desc, 
	(CASE PaymentD_ItemNameChi WHEN '' THEN PaymentD_ItemName ELSE (PaymentD_ItemName + ' (' + PaymentD_ItemNameChi + ')') END) as Product_Desc, 
	PaymentD_UOM, 
	PaymentD_UnitPrice, PaymentD_Qty, PaymentD_DiscountPercent, 
	PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, 
	PaymentD_RunNo as DetailID, 
	ISNULL(dbo.fnCombineAllAddOn(PaymentD_ReceiptNo,PaymentD_RunNo),'') as AddOnValue  from tblPayment_Details PD
	--inner join tblProduct P on PD.PaymentD_ItemCode = P.Product_ItemCode
	where PaymentD_ReceiptNo = @strReceiptNo

	
	SELECT PaymentEx_ID, PaymentEx_ReceiptNo, PaymentEx_RunNo as DetailID, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice, 
	PaymentEx_CreatedBy, PaymentEx_CreatedDate
	FROM     tblPayment_Extra where PaymentEx_ReceiptNo = @strReceiptNo
	Order by PaymentEx_RunNo

END
