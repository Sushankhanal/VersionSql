/****** Object:  Procedure [dbo].[sp_tblPayment_Header_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblPayment_Header_Get] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50),
	@strDateFrom	datetime,
	@strDateTo		datetime,
	@strReceiptNo	nvarchar(50)

) AS
BEGIN
	
	set @strDateTo = DATEADD(day,1,@strDateTo)
	set @strDateTo = DATEADD(second,-1,@strDateTo)

	select Payment_ID, Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
	Payment_FinalAmt, Payment_PaymentType, Payment_PayAmt, 
	Payment_ReturnAmt, Payment_CardNumber, Payment_CardType, 
	Payment_UserCode, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
	Payment_TotalTaxAmt, PM.PaymentMode_Name, Payment_Remarks,
	(CASE Payment_IsRefund WHEN 1 THEN 'Voided' WHEN 2 THEN 'Void receipt' ELSE '' END) as RefundStatus,
	(CASE ISNULL(UM.mUser_FullName,'') WHEN '' THEN H.Payment_UserCode ELSE UM.mUser_FullName END) as ClientName,
	(select top 1 P.Product_WalletsTransType from tblPayment_Details D
	inner join tblProduct P on P.Product_ItemCode = D.PaymentD_ItemCode where PaymentD_ReceiptNo = H.Payment_ReceiptNo) as ProductIndicator
	from tblPayment_Header H
	inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
	left outer join tblUserMobile UM on H.Payment_UserCode = UM.mUser_Code
	where Payment_CounterCode = @CounterCode
	AND Payment_Date between @strDateFrom and @strDateTo
	AND Payment_ReceiptNo  LIKE '%' + @strReceiptNo + '%'
	Order by Payment_ReceiptNo desc

END
