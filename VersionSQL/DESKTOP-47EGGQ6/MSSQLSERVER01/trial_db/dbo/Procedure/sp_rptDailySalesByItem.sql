﻿/****** Object:  Procedure [dbo].[sp_rptDailySalesByItem]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_rptDailySalesByItem] 
@strStartDate datetime,
@strEndDate datetime,
@strCounterCode nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @strCounterName nvarchar(50) = ''

	Select @strCounterName = Counter_Name from tblCounter where Counter_Code = @strCounterCode

	SELECT PC.ProCategory_Name, P.Product_Desc, D.PaymentD_ItemCode, D.PaymentD_UnitPrice As Unit_Price, Sum(D.PaymentD_Qty) as Quantity_sold, 
	Sum(D.PaymentD_UnitPrice*D.PaymentD_Qty) as Gross_Sales, Sum(D.PaymentD_DiscountAmt) AS Item_Discount, Sum(D.PaymentD_NetAmount) As Net_Sales
	
	FROM tblPayment_Header H
	inner join tblPayment_Details D on H.Payment_ReceiptNo = D.PaymentD_ReceiptNo
	inner join tblProduct P on P.Product_ItemCode = D.PaymentD_ItemCode
	inner join tblProductCategory PC on P.Product_CategoryCode = PC.ProCategory_Code
	WHERE Payment_Date Between @strStartDate AND @strEndDate
	GROUP BY PC.ProCategory_Name, P.Product_Desc, D.PaymentD_ItemCode, D.PaymentD_Qty, D.PaymentD_UnitPrice
	ORDER BY PC.ProCategory_Name, sum(D.PaymentD_Qty) DESC

	SELECT 
	Sum(D.PaymentD_UnitPrice*D.PaymentD_Qty) as Gross_Sales, Sum(D.PaymentD_DiscountAmt) AS Item_Discount, Sum(D.PaymentD_NetAmount) As Net_Sales
	
	FROM tblPayment_Header H
	inner join tblPayment_Details D on H.Payment_ReceiptNo = D.PaymentD_ReceiptNo
	inner join tblProduct P on P.Product_ItemCode = D.PaymentD_ItemCode
	inner join tblProductCategory PC on P.Product_CategoryCode = PC.ProCategory_Code
	WHERE Payment_Date Between @strStartDate AND @strEndDate

	Select Sum(H.Payment_GrossAmt) as Gross_Sales, 
	--Sum(D.PaymentD_DiscountAmt) AS Item_Discount, 
	sum(H.Payment_GlobalDiscountAmt) as Total_Global_Discount, 
	sum(Payment_SC) as Total_Service_Charge, Sum(Payment_SST) as Total_SST, sum(Payment_RoundUp) as Total_Roundup, sum(Payment_FinalAmt) as Final_Sales
	FROM tblPayment_Header H
	--inner join tblPayment_Details D on H.Payment_ReceiptNo = D.PaymentD_ReceiptNo
	--inner join tblProduct P on P.Product_ItemCode = D.PaymentD_ItemCode
	--inner join tblProductCategory PC on P.Product_CategoryCode = PC.ProCategory_Code
	WHERE Payment_Date Between @strStartDate AND @strEndDate


END
