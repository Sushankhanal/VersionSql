/****** Object:  Procedure [dbo].[sp_tblPayment_Order_GetALL]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_tblPayment_Order_Get '','',''
CREATE PROCEDURE [dbo].[sp_tblPayment_Order_GetALL] (
	@strPOSUserCode nvarchar(50),
	@strCounterCode	nvarchar(50),
	@strCompanyCode	nvarchar(50)

) AS
BEGIN
	
	if @strCounterCode = ''
	BEGIN
		select Payment_ID, Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
		Payment_FinalAmt, 
		Payment_UserCode, 
		Payment_TotalTaxAmt, Payment_Remarks,
		(CASE ISNULL(UM.mUser_FullName,'') WHEN '' THEN H.Payment_UserCode ELSE UM.mUser_FullName END) as ClientName
		from tblPayment_Order H
		--inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
		left outer join tblUserMobile UM on H.Payment_UserCode = UM.mUser_Code
		where Payment_CompanyCode = @strCompanyCode
		Order by Payment_ReceiptNo
	END
	ELSE
	BEGIN
		select Payment_ID, Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, 
		Payment_FinalAmt, 
		Payment_UserCode, 
		Payment_TotalTaxAmt, Payment_Remarks,
		(CASE ISNULL(UM.mUser_FullName,'') WHEN '' THEN H.Payment_UserCode ELSE UM.mUser_FullName END) as ClientName
		from tblPayment_Order H
		--inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
		left outer join tblUserMobile UM on H.Payment_UserCode = UM.mUser_Code
		where Payment_CounterCode = @strCounterCode
		AND Payment_CompanyCode = @strCompanyCode
		Order by Payment_ReceiptNo
	END

	

END
