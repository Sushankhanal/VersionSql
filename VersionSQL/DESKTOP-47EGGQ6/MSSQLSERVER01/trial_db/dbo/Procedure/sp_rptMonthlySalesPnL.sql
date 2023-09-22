/****** Object:  Procedure [dbo].[sp_rptMonthlySalesPnL]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptMonthlySalesPnL 2,2019,0
CREATE PROCEDURE [dbo].[sp_rptMonthlySalesPnL]
	-- Add the parameters for the stored procedure here
	@intMonth	int,
	@intYear	int,
	@pUserID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Update round(UnitCost,2)
	Update tblPayment_Details set PaymentD_UnitCost = round(PaymentD_UnitCost,2) where month(PaymentD_CreatedDate) = @intMonth and
	year(PaymentD_CreatedDate) = @intYear

	Declare @strMonth nvarchar(50)
	Select @strMonth = DateName( month , DateAdd( month , @intMonth , -1 ) )

	DECLARE @tblSummary TABLE
    (ReportMonth nvarchar(50), ReportYear int, ItemCategory nvarchar(50), ItemCode nvarchar(50),ItemName nvarchar(200), QtySold  int, 
	UnitCost money, TotalCost money, UnitPrice money, TotalSellingPrice money, PnL money, PercentagePnL money, GlobalDiscountAmt money)

	insert into @tblSummary
	select @strMonth, @intYear, ISNULL(pc.ProCategory_Name,'Others') as ItemCategory, 
	d.PaymentD_ItemCode as ItemCode, p.Product_Desc as Description,
	SUM(PaymentD_Qty) as Qty,
	d.PaymentD_UnitCost as UnitCost, 
	SUM((d.PaymentD_UnitCost * PaymentD_Qty)) as TotalCost,
		d.PaymentD_UnitPrice as UnitPrice,
		SUM((d.PaymentD_UnitPrice * PaymentD_Qty)) as TotalSellingPrice, 0, 0, 0
		from tblPayment_Header h
	inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo
	inner join tblProduct p on p.Product_ItemCode = d.PaymentD_ItemCode
	left outer join tblProductCategory pc on p.Product_CategoryCode = pc.ProCategory_Code
	where month(h.Payment_Date) = @intMonth and
	year(h.Payment_Date) = @intYear
	Group by ISNULL(pc.ProCategory_Name,'Others'), d.PaymentD_ItemCode, p.Product_Desc, d.PaymentD_UnitCost, d.PaymentD_UnitPrice

	Declare @dblGlobalDiscountAmt money
	select @dblGlobalDiscountAmt = ISNULL(SUM(Payment_GlobalDiscountAmt),0)
	from tblPayment_Header h
	where month(h.Payment_Date) = @intMonth and
	year(h.Payment_Date) = @intYear

	update @tblSummary set PnL = TotalSellingPrice - TotalCost

	update @tblSummary set PercentagePnL = (PnL / TotalSellingPrice) * 100
	where TotalSellingPrice <> 0 

	update @tblSummary set GlobalDiscountAmt = @dblGlobalDiscountAmt

	select * from @tblSummary
END
