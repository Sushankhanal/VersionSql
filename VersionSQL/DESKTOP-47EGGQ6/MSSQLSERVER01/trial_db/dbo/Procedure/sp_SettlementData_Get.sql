/****** Object:  Procedure [dbo].[sp_SettlementData_Get]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_SettlementData_Get '','POS-03','comp02','C20-S2614'
CREATE PROCEDURE [dbo].[sp_SettlementData_Get]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strSettlementCode	nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select Settlement_InitialCash as InitialCash,
	Settlement_GrossAmt as TotalGrossAmt,
	Settlement_GlobalDiscountAmt as TotalGlobalDiscountAmt,
	Settlement_ItemDiscountAmt as TotalItemDiscountAmt,
	Settlement_TotalTaxAmt as TotalTaxAmt,
	Settlement_RoundUp as TotalRoundUp,
	Settlement_FinalAmt as TotalNetAmt,
	Settlement_RefundAmt as TotalRefundAmt,
	Settlement_Code, Settlement_Date, Settlement_CashierCash,
	U.POSUser_Name as Settlement_By,
	Settlement_ServiceCharges as TotalServiceChargeAmt
	From tblSettlement S
	inner join tblPOSUser U on S.Settlement_CashierCode = U.POSUser_Code
	where Settlement_Code = @strSettlementCode


	select M.PaymentMode_Name, 
	ISNULL((select ISNULL(SettlePayment_Amt,0) as NetAmount 
	from tblSettlement_Detail
	where SettlePayment_Code = @strSettlementCode AND SettlePayment_PayMode = M.PaymentMode_Name),0) as NetAmount 
	from tblPaymentMode M
	Order by M.PaymentMode_Order

	Select Settlement_TopUpAmt as TotalTopUp,
	 Settlement_TopUpReturnAmt as TotalTopUpReturn,
	 Settlement_DepositAmt as TotalDeposit,
	 Settlement_DepositReturnAmt as TotalDepositReturn
	 From tblSettlement S
	inner join tblPOSUser U on S.Settlement_CashierCode = U.POSUser_Code
	where Settlement_Code = @strSettlementCode

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
