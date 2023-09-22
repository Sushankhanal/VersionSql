/****** Object:  Procedure [dbo].[sp_rptDailySales]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptDailySales '2019-02-01','2019-02-28',0
CREATE PROCEDURE [dbo].[sp_rptDailySales]
	-- Add the parameters for the stored procedure here
	@pStartDate		datetime,
	@pEndDate		datetime,
	@pUserID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @pEndDate = DATEADD(day,1,@pEndDate)
	set @pEndDate = DATEADD(second,-1,@pEndDate)

    -- Insert statements for procedure here
	if @pUserID = 0
	BEGIN
		select h.Payment_ID as PaymentID, h.Payment_ReceiptNo as ReceiptNo, PaymentMode_Name as PaymentTypeStr,
		CONVERT(datetime, Payment_Date) as PaymentDate, Payment_GrossAmt as GrossAmt, 
		(h.Payment_DiscountAmt + h.Payment_GlobalDiscountAmt) as DiscountAmt, 
		Payment_RoundUp as RoundUp,
		Payment_FinalAmt as FinalAmt, Payment_IsRefund as RefundID, Payment_CreatedBy as UserName, 
		Payment_CounterCode as CounterCode, Payment_TotalTaxAmt as TotalTaxAmt,
		C.Counter_Name
		from tblPayment_Header h
		inner join tblPaymentMode c1 on h.Payment_PaymentType = c1.PaymentMode_ID --and CodeType = 'PAYTYPE'
		inner join tblPOSUser u on u.POSUser_Code = h.Payment_CreatedBy
		inner join tblCounter C on C.Counter_Code = h.Payment_CounterCode
		Where Payment_Date between @pStartDate and @pEndDate
		Order by h.Payment_Date, h.Payment_ReceiptNo
		
	END


END
