/****** Object:  Procedure [dbo].[api_GetPendingOrderKitchenPrintv2]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetFoodCategory(''
--exec api_GetPendingOrderKitchenPrint 'comp02'
CREATE PROCEDURE [dbo].[api_GetPendingOrderKitchenPrintv2] (
	@strCompanyCode	nvarchar(50)
) AS
BEGIN
	
	update tblPayment_Details_Print set PaymentD_PrintStatus = 1 where PaymentD_PrinterName = ''

	DECLARE @tblTemp_0 TABLE
	(ID int)

	insert into @tblTemp_0
	select PaymentD_ID
	from tblPayment_Details_Print d
	inner join tblProduct P on d.PaymentD_ItemCode = p.Product_ItemCode
	where PaymentD_PrintStatus = 0
	AND PaymentD_CompanyCode = @strCompanyCode
	--and PaymentD_ReceiptNo in (select Payment_ReceiptNo from tblPayment_Order where Payment_Status = 0 and Payment_CompanyCode = @strCompanyCode)
	order by PaymentD_ReceiptNo, PaymentD_Status,PaymentD_UOM, PaymentD_RunNo

	--Update tblPayment_Details_Print set PaymentD_PrintStatus = 1 
	--where PaymentD_ID in (select * from @tblTemp_0)


	--(
	--		( CASE PaymentD_UOM WHEN 'full' THEN (Select top 1 Product_FullDesc from tblProduct where Product_ItemCode = d.PaymentD_ItemCode) ELSE (Select top 1 Product_HalfDesc from tblProduct where Product_ItemCode = d.PaymentD_ItemCode) END) + ' ' + 
	--(CASE PaymentD_ItemNameChi WHEN '' THEN PaymentD_ItemName ELSE (PaymentD_ItemName + ' (' + PaymentD_ItemNameChi + ')') END)
	--) as Product_Desc, 

	select PaymentD_ID, PaymentD_ReceiptNo, PaymentD_ItemCode, 
	dbo.fnGetItemName_print(PaymentD_ItemCode,PaymentD_UOM,'') as Product_Desc,
	--(CASE PaymentD_ItemNameChi WHEN '' THEN PaymentD_ItemName ELSE (PaymentD_ItemName + ' (' + PaymentD_ItemNameChi + ')') END) as Product_Desc, 
	--(CASE Product_ChiDesc WHEN '' THEN Product_Desc ELSE (Product_ChiDesc + ' (' + Product_Desc + ')') END) as Product_FullDesc,
	PaymentD_UOM, PaymentD_Qty, PaymentD_TransDate, PaymentD_Status,
	ISNULL((select Payment_TableCode from tblPayment_Order where Payment_ReceiptNo = d.PaymentD_ReceiptNo),'') as TableCode,
	ISNULL((select T.Table_Name from tblPayment_Order O
	inner join tblTable T on O.Payment_TableCode = T.Table_Code   where O.Payment_ReceiptNo = d.PaymentD_ReceiptNo),'') as TableName,
	ISNULL((select Payment_CollectionCode from tblPayment_Order where Payment_ReceiptNo = d.PaymentD_ReceiptNo),'') as CollectionCode,
	PaymentD_PrinterName as Product_PrinterName
	 from tblPayment_Details_Print d
	--inner join tblProduct P on d.PaymentD_ItemCode = p.Product_ItemCode
	where PaymentD_ID in (select * from @tblTemp_0)
	order by d.PaymentD_PrinterName, d.PaymentD_ReceiptNo, d.PaymentD_Status, d.PaymentD_RunNo

	
END
