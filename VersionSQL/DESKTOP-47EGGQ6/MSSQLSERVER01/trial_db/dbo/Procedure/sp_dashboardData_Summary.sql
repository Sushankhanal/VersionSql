/****** Object:  Procedure [dbo].[sp_dashboardData_Summary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_dashboardData_Summary '2019-02-01','2019-02-28',1
CREATE PROCEDURE [dbo].[sp_dashboardData_Summary]
	-- Add the parameters for the stored procedure here
	@DateFrom DATETIME,
	@DateTo DATETIME,
	@BranchID	bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	set @DateTo = DATEADD(day,1,@DateTo)
	set @DateTo = DATEADD(second,-1,@DateTo)

	Declare @strBranchCode nvarchar(50)
	Declare @strBranchName nvarchar(50)
	--if @BranchId = 0
	--BEGIN
	--	set @strBranchName = 'All'
	--END
	--ELSE
	--BEGIN
	--	select @strBranchName = BranchName from tblBranch where ID = @BranchId
	--END

	Declare @intTotalSales int
	Declare @intTotalRefund int
	Declare @dblTotalSales money
	Declare @dblTotalRefund money

    -- Insert statements for procedure here
	select @intTotalSales = ISNULL(Count(Payment_ID),0),
	@dblTotalSales = ISNULL(SUM(Payment_FinalAmt),0) from tblPayment_Header
	where Payment_IsRefund IN (0,1)
	and Payment_Date between @DateFrom and @DateTo

	select @intTotalRefund = ISNULL(Count(Payment_ID),0),
	@dblTotalRefund = ISNULL(SUM(Payment_FinalAmt),0) from tblPayment_Header
	where Payment_IsRefund = 2
	and Payment_Date between @DateFrom and @DateTo

	DECLARE @tblSummary TABLE
    (RowNo INT, TotalSalesCount int, TotalRefundCount int, TotalSales money, TotalRefund money,
	IsProcess INT)

	insert into @tblSummary
	select 1,@intTotalSales,@intTotalRefund,@dblTotalSales,@dblTotalRefund,0

	select * from @tblSummary

	select ISNULL(pc.ProCategory_Name,'Others') as ItemCategory,
	--SUM((CASE  WHEN h.Payment_IsRefund = 0 THEN d.Qty WHEN h.RefundID <> 0 THEN 0 - d.Qty END)) as Qty,
	SUM(PaymentD_Qty) as Qty,
	SUM(d.PaymentD_UnitCost * PaymentD_Qty) as TotalCost, 
	--SUM((d.PaymentD_UnitCost * 
	--	(CASE  WHEN h.Payment_IsRefund = 0 THEN d.Qty WHEN h.RefundID <> 0 THEN 0 - d.Qty END)
	--	)) as TotalCost,
		--SUM((d.UnitPrice * 
		--(CASE  WHEN h.RefundID = 0 THEN d.Qty WHEN h.RefundID <> 0 THEN 0 - d.Qty END)
		--)) as TotalSellingPrice, 
		SUM(d.PaymentD_UnitPrice * PaymentD_Qty) as TotalSellingPrice, 
		0, 0 
		from tblPayment_Header h
	inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo
	inner join tblProduct p on p.Product_ItemCode = d.PaymentD_ItemCode
	left outer join tblProductCategory pc on p.Product_CategoryCode = pc.ProCategory_Code
	where h.Payment_Date between @DateFrom and @DateTo
	Group by pc.ProCategory_Code, ISNULL(pc.ProCategory_Name,'Others')


END
