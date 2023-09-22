/****** Object:  Procedure [dbo].[sp_SettlementData_Prepare_Get]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_SettlementData_Prepare_Get 'cash1','COUNTER-04','Hallaway01'
CREATE PROCEDURE [dbo].[sp_SettlementData_Prepare_Get]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Added by Ricky 2020 Jan 19
		delete from tblPayment_Header 
		where  Payment_ReceiptNo not in (
		select PaymentD_ReceiptNo from tblPayment_Details (NOLOCK)
		) 
		AND Payment_CounterCode = @strCounterCode
		AND Payment_IsSettlement = 0

	DECLARE @tblSummary TABLE
    (ReceiptNo nvarchar(50))

	Declare @dblInitialCash money = 0
	select @dblInitialCash = CounterTrans_OpenCash from tblCounterTrans
	where CounterTrans_CounterCode = @strCounterCode
	AND CounterTrans_IsSettlement = 0

	Declare @dblTotalGrossAmt money = 0
	Declare @dblTotalTaxAmt money = 0
	Declare @dblTotalNetAmt money = 0
	Declare @dblTotalRoundUp money = 0
	Declare @dblTotalGlobalDiscount money = 0
	Declare @dblTotalRefund money = 0
	Declare @dblTotalItemDiscountAmt money = 0
	Declare @dblTotalServiceChargeAmt money = 0

	--select @dblTotalGrossAmt = ISNULL(SUM(Payment_GrossAmt),0), @dblTotalTaxAmt = ISNULL(SUM(Payment_TotalTaxAmt),0),
	--@dblTotalNetAmt = ISNULL(SUM(Payment_FinalAmt),0), @dblTotalRoundUp = ISNULL(SUM(Payment_RoundUp),0), 
	--@dblTotalGlobalDiscount = ISNULL(SUM(Payment_GlobalDiscountAmt),0)   from tblPayment_Header
	--where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	--AND Payment_IsRefund in (0,1,2)

	insert into @tblSummary
	select Payment_ReceiptNo from tblPayment_Header
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2)

	select @dblTotalGrossAmt = ISNULL(SUM(Payment_GrossAmt),0), 
	@dblTotalTaxAmt = ISNULL(SUM(Payment_TotalTaxAmt),0),
	@dblTotalNetAmt =  ISNULL(SUM(Payment_FinalAmt),0), 
	@dblTotalRoundUp =   ISNULL(SUM(Payment_RoundUp),0), 
	@dblTotalGlobalDiscount = ISNULL(SUM(Payment_GlobalDiscountAmt),0)  ,
	@dblTotalServiceChargeAmt = ISNULL(SUM(Payment_SC),0)
	from tblPayment_Header h 
	--inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo
	--inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2)

	AND Payment_ReceiptNo in (
	select PaymentD_ReceiptNo from tblPayment_Details d 
	inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
	where P.Product_WalletsTransType = 2
	AND PaymentD_ReceiptNo in (select ReceiptNo from @tblSummary)
	)
	--AND P.Product_WalletsTransType = 2

	select @dblTotalRefund = ISNULL(SUM(Payment_FinalAmt),0) from tblPayment_Header
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (2)

	select @dblTotalItemDiscountAmt = ISNULL(SUM(D.PaymentD_DiscountAmt),0) from tblPayment_Header H
	inner join tblPayment_Details D on H.Payment_ReceiptNo = D.PaymentD_ReceiptNo
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2)

	select @dblInitialCash as InitialCash,
	@dblTotalGrossAmt as TotalGrossAmt,
	@dblTotalGlobalDiscount as TotalGlobalDiscountAmt,
	@dblTotalItemDiscountAmt as TotalItemDiscountAmt,
	@dblTotalTaxAmt as TotalTaxAmt,
	@dblTotalRoundUp as TotalRoundUp,
	@dblTotalNetAmt as TotalNetAmt,
	@dblTotalRefund as TotalRefundAmt,
	@dblTotalServiceChargeAmt as TotalServiceChargeAmt
	--select M.PaymentMode_Name, ISNULL(SUM(H.Payment_NetAmt),0) as NetAmount from tblPayment_Header H
	--inner join tblPaymentMode M on H.Payment_PaymentType = M.PaymentMode_ID
	--where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	--AND Payment_IsRefund in (0,1,2)
	--Group By M.PaymentMode_Name

	
	select M.PaymentMode_Name, 
	ISNULL((select ISNULL(SUM(H.Payment_NetAmt),0) as NetAmount 
	from tblPayment_Header H
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2) AND H.Payment_PaymentType = M.PaymentMode_ID),0) as NetAmount 
	from tblPaymentMode M
	Order by M.PaymentMode_Order


	--- Top Up and Depsoit Detail
	Declare @dblTotalTopUpAmt money = 0
	Declare @dblTotalReturnAmt money = 0
	Declare @dblTotalDepositAmt money = 0
	Declare @dblTotalReturnDeposit money = 0

	select @dblTotalTopUpAmt = ISNULL(SUM(d.PaymentD_NetAmount),0) 
	from tblPayment_Header h inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo
	inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2)
	AND P.Product_WalletsTransType = 1
	AND d.PaymentD_NetAmount > 0

	select @dblTotalReturnAmt = ISNULL(SUM(d.PaymentD_NetAmount),0) 
	from tblPayment_Header h inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo
	inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2)
	AND P.Product_WalletsTransType = 1
	AND d.PaymentD_NetAmount < 0

	select @dblTotalDepositAmt = ISNULL(SUM(d.PaymentD_NetAmount),0) from tblPayment_Header h 
	inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo
	inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2)
	AND P.Product_WalletsTransType = 10
	AND d.PaymentD_NetAmount > 0
	
	select @dblTotalReturnDeposit = ISNULL(SUM(d.PaymentD_NetAmount),0) from tblPayment_Header h 
	inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo
	inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
	where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
	AND Payment_IsRefund in (0,1,2)
	AND P.Product_WalletsTransType = 10
	AND d.PaymentD_NetAmount < 0

	Select @dblTotalTopUpAmt as TotalTopUp,
	 @dblTotalReturnAmt as TotalTopUpReturn,
	 @dblTotalDepositAmt as TotalDeposit,
	 @dblTotalReturnDeposit as TotalDepositReturn
	--- End of Top Up and Deposit Detail

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
