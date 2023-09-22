/****** Object:  Procedure [dbo].[sp_GetSettlementData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_GetSettlementData] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50)
) AS
BEGIN

	SELECT 
	
	(select SUM(CounterTrans_OpenCash) from tblCounterTrans where CounterTrans_IsSettlement = 0
	AND CounterTrans_CounterCode = @CounterCode) as InitialCash,
	SUM(Payment_GrossAmt) as TotalGrossAmt, SUM(Payment_DiscountAmt) as TotalDiscountAmt, 
	SUM(Payment_NetAmt) as TotalNetAmt, SUM(Payment_RoundUp) as TotalRoundUp, SUM(Payment_FinalAmt) as TotalFinalAmt, 
	SUM(Payment_GlobalDiscountAmt) AS TotalGlobalDiscountAmt, SUM(Payment_AdjustmentAmt) as TotalAdjustmentAmt, 
	SUM(Payment_TotalTaxAmt) as TotalTaxAmt,
	(SELECT ISNULL(SUM(Payment_FinalAmt),0)
	FROM     tblPayment_Header
	WHERE  (Payment_IsSettlement = 0) AND (Payment_CounterCode = @CounterCode)
	AND Payment_IsRefund IN (0,1)) as Totalb4Refund,
	(SELECT ISNULL(SUM(Payment_FinalAmt),0)
	FROM     tblPayment_Header
	WHERE  (Payment_IsSettlement = 0) AND (Payment_CounterCode = @CounterCode)
	AND Payment_IsRefund = 2) as TotalRefund
	FROM     tblPayment_Header
	WHERE  (Payment_IsSettlement = 0) AND (Payment_CounterCode = @CounterCode)



	select PM.PaymentMode_Name as PaymentMode, SUM(Payment_FinalAmt) as TotalPaymentAmount, COUNT(H.Payment_ID) as TotalPaymentBill from tblPayment_Header H
	inner join tblPaymentMode PM on H.Payment_PaymentType = PM.PaymentMode_ID
	WHERE  (Payment_IsSettlement = 0) AND (Payment_CounterCode = @CounterCode)
	Group by PM.PaymentMode_Name

END
