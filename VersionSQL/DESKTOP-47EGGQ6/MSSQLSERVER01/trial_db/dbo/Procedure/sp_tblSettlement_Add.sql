/****** Object:  Procedure [dbo].[sp_tblSettlement_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblSettlement_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@dblCashFromCashier		money,
	@strRemarks			nvarchar(500),
	@strReceiptNo		nvarchar(50) OUT
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


		Declare @strCode nvarchar(50)

		DECLARE @intCounterTransID bigint = 0
		
		select @intCounterTransID = CounterTrans_ID from tblCounterTrans
		where CounterTrans_CounterCode = @strCounterCode
		AND CounterTrans_IsSettlement = 0

		IF @intCounterTransID > 0 
		BEGIN
			DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			set @PrefixType = 'Settlement'
			EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strCode OUTPUT
			Declare @strCounterPrefix nvarchar(50) = ''
			select @strCounterPrefix = Counter_ID from tblCounter where Counter_Code = @strCounterCode
			set @strCounterPrefix = 'C' + @strCounterPrefix + '-'
			set @strCode = @strCounterPrefix + @strCode

			Declare @dblGrossAmt money = 0 --
			Declare @dblTotalGlobalDiscount money = 0 --
			Declare @dblNetAmt money = 0 --
			Declare @dblRoundUp money = 0 --
			Declare @dblFinalAmt money = 0 --

			Declare @dblCashCount int = 0
			Declare @dblCreditCount int = 0

			Declare @dblRefundAmt money = 0 --
			Declare @dblInitialCash money = 0 --
			Declare @dblCashAmt money = 0
			Declare @dblCreditCardAmt money = 0
			Declare @dblAdjustmentAmt money = 0
			Declare @dblTotalTaxAmt money = 0 -- 
			Declare @dblAlipayAmt money = 0
			Declare @dblWechatpayAmt money = 0
			Declare @dblUnionpayAmt money = 0
			Declare @dblWalletAmt money = 0
			Declare @dblWalletCount int = 0
			Declare @dblTotalItemDiscountAmt money = 0
			Declare @dblTotalServiceChargeAmt money = 0

			select @dblInitialCash = CounterTrans_OpenCash from tblCounterTrans
			where CounterTrans_CounterCode = @strCounterCode
			AND CounterTrans_IsSettlement = 0

			DECLARE @tblSummary TABLE (ReceiptNo nvarchar(50))
			insert into @tblSummary
			select Payment_ReceiptNo from tblPayment_Header
			where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
			AND Payment_IsRefund in (0,1,2)

			select @dblGrossAmt = ISNULL(SUM(Payment_GrossAmt),0), @dblTotalTaxAmt = ISNULL(SUM(Payment_TotalTaxAmt),0),
			@dblFinalAmt = ISNULL(SUM(Payment_FinalAmt),0), @dblRoundUp = ISNULL(SUM(Payment_RoundUp),0), 
			@dblTotalGlobalDiscount = ISNULL(SUM(Payment_GlobalDiscountAmt),0) ,
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

			select @dblRefundAmt = ISNULL(SUM(Payment_FinalAmt),0) from tblPayment_Header
			where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
			AND Payment_IsRefund in (2)

			select @dblTotalItemDiscountAmt = ISNULL(SUM(D.PaymentD_DiscountAmt),0) from tblPayment_Header H
			inner join tblPayment_Details D on H.Payment_ReceiptNo = D.PaymentD_ReceiptNo
			where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
			AND Payment_IsRefund in (0,1,2)


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

			INSERT INTO tblSettlement
			(Settlement_Date, Settlement_Code, Settlement_GrossAmt, Settlement_GlobalDiscountAmt, Settlement_NetAmt, 
			Settlement_RoundUp, Settlement_FinalAmt, Settlement_CashCount, Settlement_CreditCount, Settlement_RefundAmt, 
			Settlement_CreatedDate, Settlement_CashierCode, Settlement_CounterCode, Settlement_InitialCash, Settlement_CashAmt, 
			Settlement_CreditCardAmt, Settlement_CashierCash, Settlement_Remarks, Settlement_AdjustmentAmt, 
			Settlement_TotalTaxAmt, Settlement_AlipayAmt, Settlement_WechatpayAmt, Settlement_UnionpayAmt, 
			Settlement_WalletAmt, Settlement_WalletCount, Settlement_ItemDiscountAmt,
			Settlement_TopUpAmt, Settlement_TopUpReturnAmt, Settlement_DepositAmt, Settlement_DepositReturnAmt, Settlement_ServiceCharges)
			VALUES (GETDATE(),@strCode,@dblGrossAmt,@dblTotalGlobalDiscount,@dblNetAmt,
			@dblRoundUp,@dblFinalAmt,@dblCashCount,@dblCreditCount,@dblRefundAmt,
			GETDATE(),@strPOSUserCode,@strCounterCode,@dblInitialCash,@dblCashAmt,
			@dblCreditCardAmt,@dblCashFromCashier,@strRemarks,@dblAdjustmentAmt,
			@dblTotalTaxAmt,@dblAlipayAmt,@dblWechatpayAmt,@dblUnionpayAmt,
			@dblWalletAmt,@dblWalletCount, @dblTotalItemDiscountAmt, 
			@dblTotalTopUpAmt, @dblTotalReturnAmt, @dblTotalDepositAmt, @dblTotalReturnDeposit, @dblTotalServiceChargeAmt)
			SELECT @ID = SCOPE_IDENTITY()

			set @strReceiptNo = @strCode

			INSERT INTO tblSettlement_Detail
			(SettlePayment_Code, SettlePayment_PayMode, SettlePayment_Amt)
			select @strReceiptNo, M.PaymentMode_Name, ISNULL(SUM(H.Payment_NetAmt),0) from tblPayment_Header H
			inner join tblPaymentMode M on H.Payment_PaymentType = M.PaymentMode_ID
			where Payment_IsSettlement = 0 AND Payment_CounterCode = @strCounterCode
			AND Payment_IsRefund in (0,1,2)
			Group By M.PaymentMode_Name

			Update tblCounterTrans set
			CounterTrans_SettlementCash = @dblCashFromCashier,
			CounterTrans_ModifiedBy = @strPOSUserCode,
			CounterTrans_ModifiedDate = GETDATE(),
			CounterTrans_IsSettlement = @ID,
			CounterTrans_SettleBy = @strPOSUserCode,
			CounterTrans_SettleDate = GETDATE(),
			CounterTrans_SettleCode = @strCode
			WHERE CounterTrans_ID = @intCounterTransID

			Update tblPayment_Header set Payment_IsSettlement = @ID,
			Payment_SettleCode = @strCode
			where Payment_IsSettlement = 0  AND Payment_CounterCode = @strCounterCode
			AND Payment_IsRefund in (0,1,2)

		END
		ELSE
		BEGIN
			--RAISERROR ('Error',16,1);  
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
