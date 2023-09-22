/****** Object:  Procedure [dbo].[sp_tblPaymentMode_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblPaymentMode_Get] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50)
) AS
BEGIN
	Select PaymentMode_ID, PaymentMode_Name, PaymentMode_Order, PaymentMode_ColorCode  from tblPaymentMode where PaymentMode_Wallet = 1
	Order by PaymentMode_Order
	
END
