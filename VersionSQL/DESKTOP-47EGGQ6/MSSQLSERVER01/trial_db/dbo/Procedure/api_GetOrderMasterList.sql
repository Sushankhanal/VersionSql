/****** Object:  Procedure [dbo].[api_GetOrderMasterList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetFoodCategory(''

CREATE PROCEDURE [dbo].[api_GetOrderMasterList] (
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strOrderNo		nvarchar(50)
) AS
BEGIN

	select ROW_NUMBER() OVER(ORDER BY Payment_ID)  AS RowNo,
	Payment_Date as Order_Date, Payment_FinalAmt as Order_TotalAmt, 
	Payment_Pax as Order_Pax, Payment_TableCode as Order_TableCode
	from tblPayment_Order M
	where Payment_ReceiptNo = @strOrderNo
	AND Payment_CompanyCode = @strCompanyCode


END
