/****** Object:  Procedure [dbo].[sp_rptStockSales]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_rptStockSales]
	-- Add the parameters for the stored procedure here
	@pStartDate		datetime,
	@pEndDate		datetime,
	@pUserID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if @pUserID = 0
	BEGIN
		select PaymentD_ID as DetailsID, h.Payment_ReceiptNo as ReceiptNo, h.Payment_Date as PaymentDate, 
		c1.PaymentMode_Name as PaymentTypeStr,
		d.PaymentD_UnitPrice as UnitPrice, 
		d.PaymentD_Qty as Qty,
		(d.PaymentD_UnitPrice * d.PaymentD_Qty) as Amount,
		d.PaymentD_DiscountAmt as DiscountAmt, d.PaymentD_NetAmount as NetAmount, h.Payment_IsRefund as RefundID, 
		p.Product_ItemCode as ItemCode, p.Product_Desc as Description, h.Payment_CounterCode as CounterCode, 
		d.PaymentD_TaxAmt as TaxAmt, 
		(d.PaymentD_UnitCost * d.PaymentD_Qty) as TotalCostAmount
		from tblPayment_Details d 
		inner join tblPayment_Header h on d.PaymentD_ReceiptNo = h.Payment_ReceiptNo
		inner join tblPaymentMode c1 on h.Payment_PaymentType = c1.PaymentMode_ID --and CodeType = 'PAYTYPE'
		inner join tblProduct p on d.PaymentD_ItemCode = p.Product_ItemCode
		Where Payment_Date between @pStartDate and @pEndDate
		Order by p.Product_CategoryCode, p.Product_ItemCode, h.Payment_Date
	END

	--if @pUserID <> 0
	--BEGIN
	--	select DetailsID, h.ReceiptNo, h.PaymentDate, c1.CodeDesc as PaymentTypeStr,
	--	d.UnitPrice,
	--	(CASE  WHEN h.RefundID = 0 THEN d.Qty WHEN h.RefundID <> 0 THEN 0 - d.Qty END) as Qty, 
	--	(d.UnitPrice * 
	--	(CASE  WHEN h.RefundID = 0 THEN d.Qty WHEN h.RefundID <> 0 THEN 0 - d.Qty END)
	--	) as Amount,
	--	d.DiscountAmt, d.NetAmount, h.RefundID, 
	--	p.ItemCode, p.Description, h.CounterCode, d.TaxAmt, 
	--	(d.UnitCost * 
	--	(CASE  WHEN h.RefundID = 0 THEN d.Qty WHEN h.RefundID <> 0 THEN 0 - d.Qty END)
	--	) as TotalCostAmount
	--	from tPayment_Details d 
	--	inner join tPayment_Header h on d.ReceiptNo = h.ReceiptNo
	--	inner join pCode c1 on h.PaymentType = c1.CodeId and CodeType = 'PAYTYPE'
	--	inner join mProduct p on d.ItemCode = p.ItemCode
	--	Where PaymentDate between @pStartDate and @pEndDate
	--	AND h.UserID = @pUserID
	--	Order by p.CategoryID, p.ItemCode, h.PaymentDate
	--END
END
