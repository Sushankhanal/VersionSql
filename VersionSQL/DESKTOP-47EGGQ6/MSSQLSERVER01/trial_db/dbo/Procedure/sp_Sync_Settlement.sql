/****** Object:  Procedure [dbo].[sp_Sync_Settlement]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Settlement]
	@strCompanyCode nvarchar(50),
	@intID			bigint,
	@strReceiptNo	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		if @strReceiptNo = ''
		BEGIN
			select Settlement_ID, Settlement_Code from tblSettlement where Settlement_Sync = 0
		END
		ELSE
		BEGIN
			select Settlement_ID, Settlement_Code from tblSettlement where Settlement_Sync = 0 AND Settlement_Code = @strReceiptNo
		END
		
	END
	ELSE
	BEGIN
		SELECT Settlement_ID, 
		convert(nvarchar(50),Settlement_Date) as Settlement_Date, Settlement_Code, Settlement_GrossAmt, Settlement_GlobalDiscountAmt, 
		Settlement_NetAmt, Settlement_RoundUp, Settlement_FinalAmt, Settlement_CashCount, Settlement_CreditCount, 
		Settlement_RefundAmt, 
		convert(nvarchar(50),Settlement_CreatedDate) as Settlement_CreatedDate, Settlement_CashierCode, Settlement_CounterCode, Settlement_InitialCash, 
		Settlement_CashAmt, Settlement_CreditCardAmt, Settlement_CashierCash, Settlement_Remarks, 
		Settlement_AdjustmentAmt, Settlement_TotalTaxAmt, Settlement_AlipayAmt, Settlement_WechatpayAmt, 
		Settlement_UnionpayAmt, Settlement_WalletAmt, Settlement_WalletCount, Settlement_ItemDiscountAmt,
		Settlement_TopUpAmt, Settlement_TopUpReturnAmt, Settlement_DepositAmt, Settlement_DepositReturnAmt,
		Settlement_ServiceCharges
		FROM tblSettlement
		WHERE  (Settlement_Sync = 0)
		AND Settlement_ID = @intID

		
		--Declare @strReceiptNo nvarchar(50) = ''
		if @strReceiptNo = ''
		BEGIN
			select @strReceiptNo = Settlement_Code from tblSettlement
			where Settlement_Sync = 0
			AND Settlement_ID = @intID
		END

		select * from tblSettlement_Detail where SettlePayment_Code = @strReceiptNo

		select Payment_ReceiptNo from tblPayment_Header where Payment_SettleCode = @strReceiptNo


	END
    
END
