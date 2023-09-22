/****** Object:  Procedure [dbo].[Local_sp_tblPayment_Header_Card_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Card_Add 'user001','','COUNTER1','Hallaway01',10,0,0,0,10,'',xml,'','',2,'',6,'','','',0
create PROCEDURE [dbo].[Local_sp_tblPayment_Header_Card_Add]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strClientUserCode	nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@dblGrossAmt		money,
	@dblGlobalDiscountRate	money,
	@dblRoundUp			money,
	@dblTaxAmt			money,
	@dblNetAmount		money,
	@strRemarks			nvarchar(max),
	@PaymentDetailXml	XML,
	@strCardNumber		nvarchar(50),
	@intPaymentType		int,
	@strPaymentTypeRemarks	nvarchar(50),
	@strReceiptNo		nvarchar(50) OUT,
	@strClientFullName	nvarchar(50) OUT,
	@strClientBalance	money OUT,
	@PaymentDetailAddOnXml	XML,
	@RedeemPoint		decimal(38, 10),
	@RedeemAmt			money,
	@strClientPoint		decimal(38, 10) OUT,
	@intDiscountMode	smallint,
	@strCollectCode		nvarchar(50),
	@dblCollectedAmt	money,
	@dblGlobalDiscountAmt	money,
	@strTableCode			nvarchar(50),
	@strOrderNumber			nvarchar(50),
	@PaymentDetailModeXml	XML = '',
	@intPax					int = 0,
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @transDate AS DATETIME = GETDATE()
	DECLARE @intialAmount AS Money = 0.00
	DECLARE @finalAmount AS Money = 0.00




	
	Declare @dblCompanySST money = 0
	Declare @dblCompanySC money = 0
	Select @dblCompanySST = Company_SST, @dblCompanySC = Company_SC from tblCompany where Company_Code = @strCompanyCode
	if @dblCompanySST = 0 and @dblCompanySC = 0
	BEGIN
		Select @dblCompanySST = Counter_SST, @dblCompanySC = Counter_SC from tblCounter where Counter_Code = @strCounterCode
		AND Counter_CompanyCode = @strCompanyCode
	END

	set @dblCompanySST = (@dblCompanySST / 100)
	set @dblCompanySC = (@dblCompanySC / 100)

	if @strOrderNumber = '0' BEGIN set @strOrderNumber = '' END

	--Declare @dblTaxAmount_Order money = 0
	--if @strOrderNumber <> ''
	--	BEGIN
	--		select @dblTaxAmt = Payment_TotalTaxAmt, @dblNetAmount = Payment_NetAmt from tblPayment_Order where Payment_ReceiptNo = @strOrderNumber
	--		--Update tblPayment_Order set Payment_Status = 1 where Payment_ReceiptNo = @strOrderNumber
	--	END

	set @strReceiptNo = ''
	set @strClientFullName = ''
	set @strClientBalance = 0
	set @strClientPoint = 0
	DECLARE @intCount_Card int
	DECLARE @strMobileUser	nvarchar(50)
	select @intCount_Card = COUNT(Card_ID) from tblCard where Card_SerialNo = @strCardNumber
	AND Card_Status = 0

	set @strMobileUser = ''

	if @intCount_Card = 0
	BEGIN
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		RETURN (-20)
	END

	if @intCount_Card > 0
	BEGIN
		select @strMobileUser = Card_MobileUser from tblCard where Card_SerialNo = @strCardNumber
	END

	Declare @dblCardBalance money
	select @dblCardBalance = Card_Balance, @strClientBalance = Card_Balance  from tblCard where Card_SerialNo = @strCardNumber

	set @strClientFullName = @strCardNumber

	Declare @intWalletTransType int
	DECLARE @objXml XML, @intDoc INT
		SELECT @objXml = @PaymentDetailXml
		--print convert(nvarchar(max),@objXml)
		EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml
		--print @intDoc

		DECLARE @tblTemp TABLE
		(ID int, itemCode nvarchar(50), UOM nvarchar(50), UnitPrice money, Qty int, ItemDiscountAmt money, ItemDiscountPercentage float, 
		ItemTaxCode nvarchar(50), ItemTaxRate money, ItemTaxAmt money, NetAmount money, DiscountMode int, UnitCost money, ItemSign smallint, 
		WalletTransType int, ISPROCCESS int)
	
		INSERT INTO @tblTemp
		(ID, itemCode, UOM, UnitPrice, Qty, ItemDiscountAmt, ItemDiscountPercentage, 
		ItemTaxCode, ItemTaxRate, ItemTaxAmt, NetAmount,DiscountMode, UnitCost,ItemSign, WalletTransType, ISPROCCESS)
		SELECT DetailID, itemCode, UOM, UnitPrice, Qty, ItemDiscountAmt, ItemDiscountPercentage, 
		ItemTaxCode, ItemTaxRate, ItemTaxAmt, NetAmount,DiscountMode, 0, 0, 0, 0
		FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
		WITH (DetailID int, itemCode nvarchar(50), UOM nvarchar(50), UnitPrice money, Qty int, ItemDiscountAmt money, ItemDiscountPercentage float, 
		ItemTaxCode nvarchar(50), ItemTaxRate money, ItemTaxAmt money, NetAmount money, DiscountMode int)


		Update @tblTemp set ItemSign = WT.WTransType_Sign, WalletTransType = P.Product_WalletsTransType
		From @tblTemp t inner join tblProduct P on t.itemCode = P.Product_ItemCode
		inner join tblWalletTransType WT on P.Product_WalletsTransType = WT.WTransType_ID

		select @@ROWCOUNT from @tblTemp  where ItemSign <> 0  Group by ItemSign

		DECLARE @intCount_Mix int
		DECLARE @intItemSign int
		select @intCount_Mix = @@ROWCOUNT from @tblTemp  where ItemSign <> 0 Group by ItemSign
		--print @intCount_Mix
		if @intCount_Mix > 1
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END
		ELSE
		BEGIN
			select @intItemSign = ItemSign, @intWalletTransType = WalletTransType from @tblTemp where ItemSign <> 0
			Group by ItemSign, WalletTransType
		END

		if (select COUNT(ID) from @tblTemp) = 0
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END

		--- Added by Hong
		Declare @dblTotalNet_Detail money = 0
		select @dblTotalNet_Detail = SUM(NetAmount) from @tblTemp

		DECLARE @objXml_Addon2 XML, @intDoc_Addon2 INT
		SELECT @objXml_Addon2 = @PaymentDetailaddonXml
		EXEC sp_xml_preparedocument @intDoc_Addon2 OUTPUT, @objXml_Addon2
		DECLARE @tblExtraSUM TABLE
		(DetailID bigint, ExtraSum money)

		INSERT INTO @tblExtraSUM
		(DetailID, ExtraSum)
		select detailid, AddOnPrice
		FROM OPENXML (@intDoc_Addon2,  N'/NewDataSet/Table1', 2)
		WITH (DetailID int, AddOnPrice money)

		Declare @dblTotalNet_Extra money = 0
		select @dblTotalNet_Extra = SUM(ExtraSum) from @tblExtraSUM
		set @dblTotalNet_Detail = @dblTotalNet_Detail + @dblTotalNet_Extra
		if @dblTotalNet_Detail <> @dblGrossAmt
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-8)
		END

	


	DECLARE @PrefixType VARCHAR(50), @intRowCount INT
	set @PrefixType = 'Receipt'
	EXEC sp_tblPrefixNumber_GetNextRunNumber 'Payment', @PrefixType, 0, @strReceiptNo OUTPUT
	Declare @strCounterPrefix nvarchar(50) = ''
	select @strCounterPrefix = Counter_ID from tblCounter where Counter_Code = @strCounterCode
	set @strCounterPrefix = 'C' + @strCounterPrefix
	set @strReceiptNo = @strCounterPrefix + @strReceiptNo

	-- get point
	Declare @dblDefaultPointRate money
	select @dblDefaultPointRate = WTransType_DefaultPointRate  from tblWalletTransType 
	where WTransType_ID = @intWalletTransType

	Declare @dblTotalPointEarn decimal(38, 10) = 0
	set @dblTotalPointEarn = @dblNetAmount * @dblDefaultPointRate
	Declare @intRedeemType int
	declare @strClientPointRedeemRate money
	set @intRedeemType = 11
	set @strClientPointRedeemRate = 0
	select @strClientPointRedeemRate = WTransType_DefaultPointRate 
	from tblWalletTransType  where WTransType_Name ='Redeem'


	if @strMobileUser = '' -- Mean havent attach any mobile user yet
	BEGIN
		
		
		Declare @dblCardTransAmt money
		set @dblCardTransAmt = @dblNetAmount

		if @intItemSign = -1 -- Minus Case
		BEGIN
			
			if @dblCardBalance < @dblCardTransAmt
			BEGIN
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				RETURN (-1)
			END
		END

		if @intItemSign = 1 -- Top Up Case
		BEGIN
			select @dblCardTransAmt = SUM(NetAmount) from @tblTemp where ItemSign <> 0 
			--if @dblCardBalance < @dblCardTransAmt
			--BEGIN
			--	COMMIT TRANSACTION
			--	SET NOCOUNT OFF
			--	RETURN (-1)
			--END
		END

		--Declare @strCardTrans nvarchar(50)
		--set @strCardTrans = ''
		--set @PrefixType = 'CardTrans'
		--EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strCardTrans OUTPUT

		
		SELECT @intialAmount = Card_Balance, @finalAmount = Card_Balance + (@dblCardTransAmt * @intItemSign) FROM tblCard where Card_SerialNo = @strCardNumber

		INSERT INTO tblCard_Trans
		(CardTrans_Code, CardTrans_SerialNo, CardTrans_Date, CardTrans_Type, CardTrans_Value, CardTrans_MoneyValue, 
		CardTrans_RefCode, CardTrans_CreatedBy, CardTrans_CreatedDate, CardTrans_CampaignCode, 
		CardTrans_PaymentMode, CardTrans_InitialAmount, CardTrans_FinalAmount)
		VALUES (
		--@strCardTrans,
		@strReceiptNo,
		@strCardNumber,@transDate,@intWalletTransType,@dblCardTransAmt * @intItemSign,@dblCardTransAmt,
		@strReceiptNo,@strCardNumber,@transDate,'',@intPaymentType, @intialAmount, @finalAmount)

		-- Calc point
			
			if @dblDefaultPointRate <> 0
			BEGIN
				if @dblTotalPointEarn <> 0
				BEGIN
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, 
					CardPointTrans_PointValue, CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, 
					CardPointTrans_CreatedDate, CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, 
					CardPointTrans_WalletAmt, CardPointTrans_Ratio,
					 CardPointTrans_BranchID, CardPointTrans_MachineID)
					VALUES (
					@strReceiptNo+'-2',@strCardNumber,@intWalletTransType,@dblTotalPointEarn,@dblTotalPointEarn,
					@strReceiptNo,@strRemarks,@strPOSUserCode,@transDate,'',
					@strCardNumber,0,@dblDefaultPointRate,
					0, 0)

					if @dblTotalPointEarn > 0
					BEGIN
					
						Update tblCard set Card_Point = Card_Point + @dblTotalPointEarn,  Card_PointAccumulate = Card_PointAccumulate + @dblTotalPointEarn where Card_SerialNo = @strCardNumber 
					END
				END
				
			END

				--- Calc Point
		--Redeem Card Point
			if @RedeemPoint <> 0
			BEGIN
				Declare @dblCardPoint money = 0
				select @dblCardPoint = Card_Point from tblCard
				where Card_SerialNo = @strCardNumber
				
				if @RedeemPoint > @dblCardPoint
				BEGIN
					ROLLBACK TRANSACTION
					SET NOCOUNT OFF
					RETURN (-999)
				END
				ELSE
				BEGIN
					
					INSERT INTO tblCardPointTrans
					(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
					CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
					CardPointTrans_CampaignCode, 
					CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio)
					VALUES (
					@strReceiptNo+'-3',@strCardNumber,@intRedeemType,@RedeemPoint * -1,@RedeemPoint,
					@strReceiptNo,@strRemarks,@strPOSUserCode,@transDate,'',
					@strCardNumber,@RedeemAmt,@strClientPointRedeemRate)

					Update tblCard set Card_Point = Card_Point + (@RedeemPoint * -1) --check
					where Card_SerialNo = @strCardNumber
					set @CardId=@strCardNumber
				END

			END

		--------	-- Customize by ricky, 2020-04-16
		--------if (@intWalletTransType = 16 or @intWalletTransType = 18 or @intWalletTransType = 20 )
		--------BEGIN
		--------	Update tblCard set Card_Balance_Cashable_No = Card_Balance_Cashable_No + (@dblCardTransAmt * @intItemSign),
		--------	Card_Point = Card_Point + @dblTotalPointEarn
		--------	where Card_SerialNo = @strCardNumber
		--------END
		--------ELSE if (@intWalletTransType = 17 or @intWalletTransType = 19 or @intWalletTransType = 21 )
		--------BEGIN
		--------	Update tblCard set Card_Balance_Cashable = Card_Balance_Cashable + (@dblCardTransAmt * @intItemSign),
		--------	Card_Point = Card_Point + @dblTotalPointEarn
		--------	where Card_SerialNo = @strCardNumber
		--------END 
		--------ELSE
		--------BEGIN
		--------	Update tblCard set Card_Balance = Card_Balance + (@dblCardTransAmt * @intItemSign),
		--------	Card_Point = Card_Point + @dblTotalPointEarn
		--------	where Card_SerialNo = @strCardNumber
		--------END

		SELECT @intialAmount = Card_Balance, @finalAmount = Card_Balance + (@dblCardTransAmt * @intItemSign) FROM tblCard where Card_SerialNo = @strCardNumber


		Update tblCard set Card_Balance = Card_Balance + (@dblCardTransAmt * @intItemSign),
		Card_Point = Card_Point + @dblTotalPointEarn, Card_balance_Edit_DateTime = @transDate
		where Card_SerialNo = @strCardNumber
		
		select @strClientBalance = Card_Balance, @strClientPoint = Card_Point  from tblCard where Card_SerialNo = @strCardNumber

		set @strClientUserCode = @strCardNumber
		set @CardId=@strCardNumber
	END
	ELSE -- Attach mobile user already
	BEGIN
		
		set @strClientUserCode = ''
		set @strClientBalance = 0
		select @strClientUserCode = mUser_Code,
		@strClientFullName = mUser_FullName, @strClientBalance = mUser_TotalBalance
		from tblUserMobile where mUser_Code = @strMobileUser

		DECLARE @dblWalletBalance money
		DECLARE @strWalletCode nvarchar(50)
		select @dblWalletBalance = UWallet_Balance, @strWalletCode = UWallet_Code
		from tblUserWallet where UWallet_UserCode = @strClientUserCode

		set @strClientBalance = @dblWalletBalance

		if @intItemSign = -1 -- Minus Case
		BEGIN
			if @dblWalletBalance < @dblNetAmount
			BEGIN
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				RETURN (-1)
			END
		END

		INSERT INTO tblWalletTrans
			(WalletTrans_Code, WalletTrans_UserCode, WalletTrans_WalletCode, WalletTrans_Type, 
			WalletTrans_Value, WalletTrans_MoneyValue, WalletTrans_RefCode, WalletTrans_Remarks, 
			WalletTrans_CreatedBy, WalletTrans_CreatedDate, 
			WalletTrans_CampaignCode, WalletTrans_PaymentMode, WalletTrans_QRCodeText)
			VALUES (
			@strReceiptNo,@strClientUserCode,@strWalletCode,@intWalletTransType,
			@dblNetAmount * @intItemSign,@dblNetAmount,@strReceiptNo,@strRemarks,
			@strPOSUserCode,@transDate,'',@intPaymentType, @strCardNumber)

			Declare @dblFinalNetAmount money
			set @dblFinalNetAmount = @dblNetAmount * @intItemSign -- Make it negative if minus
			
			update tblUserWallet set UWallet_Balance = UWallet_Balance + @dblFinalNetAmount where UWallet_Code = @strWalletCode

			select @dblWalletBalance = UWallet_Balance from tblUserWallet where UWallet_UserCode = @strClientUserCode

			set @strClientBalance = @dblWalletBalance

			Update tblUserMobile set mUser_RandomCode = NULL, 
			mUser_TotalBalance = @strClientBalance where mUser_Code = @strClientUserCode

			
			if @dblDefaultPointRate <> 0
			BEGIN
				if @dblTotalPointEarn <> 0
				BEGIN
					INSERT INTO tblPointTrans
					(PointTrans_Code, PointTrans_UserCode, PointTrans_Type, PointTrans_Value, PointTrans_PointValue, 
					PointTrans_RefCode, PointTrans_Remarks, PointTrans_CreatedBy, PointTrans_CreatedDate, PointTrans_CampaignCode, 
					PointTrans_QRCodeText, PointTrans_WalletAmt, PointTrans_Ratio)
					VALUES (
					@strReceiptNo,@strClientUserCode,@intWalletTransType,@dblTotalPointEarn,@dblTotalPointEarn,
					@strReceiptNo,@strRemarks,@strPOSUserCode,@transDate,'',
					@strCardNumber,@dblNetAmount,@dblDefaultPointRate)

					
				END

				
			END


			--- Calc Point
		--Redeem Point
			if @RedeemPoint <> 0
			BEGIN
				Declare @dblCurrentPoint decimal(38, 10) = 0
				select @dblCurrentPoint = mUser_TotalPoint from tblUserMobile 
				where mUser_Code = @strClientUserCode
				
				if @RedeemPoint > @dblCurrentPoint
				BEGIN
					ROLLBACK TRANSACTION
					SET NOCOUNT OFF
					RETURN (-9)
				END
				ELSE
				BEGIN
					
					INSERT INTO tblPointTrans
					(PointTrans_Code, PointTrans_UserCode, PointTrans_Type, PointTrans_Value, PointTrans_PointValue, 
					PointTrans_RefCode, PointTrans_Remarks, PointTrans_CreatedBy, PointTrans_CreatedDate, PointTrans_CampaignCode, 
					PointTrans_QRCodeText, PointTrans_WalletAmt, PointTrans_Ratio)
					VALUES (
					@strReceiptNo,@strClientUserCode,@intRedeemType,@RedeemPoint * -1,@RedeemPoint,
					@strReceiptNo,@strRemarks,@strPOSUserCode,@transDate,'',
					@strCardNumber,@RedeemAmt,@strClientPointRedeemRate)

					Update tblUserMobile set mUser_TotalPoint = mUser_TotalPoint + (@RedeemPoint * -1)
					where mUser_Code = @strClientUserCode
				END

			END

			Update tblUserMobile set mUser_RandomCode = NULL, 
			mUser_TotalBalance = @strClientBalance, mUser_TotalPoint = mUser_TotalPoint + @dblTotalPointEarn 
			where mUser_Code = @strClientUserCode

			select @strClientFullName = mUser_FullName , @strClientBalance = mUser_TotalBalance, @strClientPoint = mUser_TotalPoint 
			from tblUserMobile where mUser_Code = @strClientUserCode
	END
	
	Declare @dblReturnAmt money = 0
	set @dblReturnAmt = @dblNetAmount - @dblCollectedAmt

	

	INSERT INTO tblPayment_Header
		(Payment_ReceiptNo, Payment_Date, Payment_GrossAmt, Payment_DiscountAmt, Payment_NetAmt, Payment_RoundUp, Payment_FinalAmt, 
		Payment_CounterCode, Payment_PaymentType, Payment_PayAmt, Payment_ReturnAmt, 
		Payment_Status, Payment_CreatedDate, Payment_CardNumber, Payment_CardType, Payment_RefundCode, 
		Payment_UserCode, Payment_GlobalDiscount, Payment_GlobalDiscountAmt, Payment_AdjustmentAmt, 
		Payment_IsSettlement, Payment_TotalTaxAmt, Payment_CreatedBy, Payment_Remarks, Payment_DiscountMode,
		Payment_RedeemPoint, Payment_RedeemAmt, Payment_CollectionCode, Payment_TableCode, Payment_OrderNumber, Payment_pax)
		VALUES (
		@strReceiptNo,@transDate,@dblGrossAmt,0,@dblNetAmount,@dblRoundUp,@dblNetAmount,
		@strCounterCode,@intPaymentType,@dblCollectedAmt,@dblReturnAmt,
		0,@transDate,@strPaymentTypeRemarks,0,'',
		@strClientUserCode,@dblGlobalDiscountRate,@dblGlobalDiscountAmt,0,0,@dblTaxAmt, @strPOSUserCode, @strRemarks, @intDiscountMode,
		@RedeemPoint, @RedeemAmt, @strCollectCode, @strTableCode,@strOrderNumber, @intPax)
	
		INSERT INTO tblPayment_Details
		(PaymentD_ReceiptNo, PaymentD_ItemCode, PaymentD_UOM, PaymentD_UnitPrice, PaymentD_DiscountPercent, 
		PaymentD_DiscountAmt, PaymentD_NetAmount, PaymentD_TransDate, PaymentD_Qty, PaymentD_CreatedDate, 
		PaymentD_UnitCost, PaymentD_TaxCode, PaymentD_TaxRate, PaymentD_TaxAmt, PaymentD_RunNo,PaymentD_DiscountMode)
		Select @strReceiptNo, itemCode, UOM, UnitPrice, ItemDiscountPercentage, ItemDiscountAmt, NetAmount, @transDate, Qty, @transDate,
		UnitCost, ItemTaxCode, ItemTaxRate, ItemTaxAmt, ID, DiscountMode from @tblTemp
		--select @@IDENTITY

		-- Added By Ricky -- 15/11/2019
		update tblPayment_Details 
		set 
		PaymentD_ItemName = (CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_Desc2 ELSE P.Product_Desc END), 
		PaymentD_ItemNameChi = (CASE d.PaymentD_UOM WHEN 'half' THEN P.Product_ChiDesc2 ELSE P.Product_ChiDesc END),
		PaymentD_PrinterName = P.Product_PrinterName
		from tblPayment_Details d
		inner join tblProduct P on d.PaymentD_ItemCode = P.Product_ItemCode
		 where PaymentD_ReceiptNo = @strReceiptNo

		--Insert Addon Data
		--- Add in Extra add on
		DECLARE @objXml_Addon XML, @intDoc_Addon INT
		SELECT @objXml_Addon = @PaymentDetailaddonXml
		EXEC sp_xml_preparedocument @intDoc_Addon OUTPUT, @objXml_Addon
	
		INSERT INTO tblPayment_Extra
		(PaymentEx_ReceiptNo, PaymentEx_RunNo, PaymentEx_ItemCode, PaymentEx_ItemDesc, PaymentEx_AddOnPrice, PaymentEx_CreatedBy, PaymentEx_CreatedDate)
		select @strReceiptNo, detailid, AddOnCode, AddOnDesc, AddOnPrice, @strPOSUserCode, @transDate
		FROM OPENXML (@intDoc_Addon,  N'/NewDataSet/Table1', 2)
		WITH (DetailID int, AddOnCode nvarchar(50), AddOnDesc nvarchar(50), AddOnPrice money)

		if @strOrderNumber <> ''
		BEGIN
			--Delete from tblPayment_Order where Payment_ReceiptNo = @strOrderNumber
			--Delete from tblPayment_Details where PaymentD_ReceiptNo = @strOrderNumber
			--Delete from tblPayment_Extra where PaymentEx_ReceiptNo = @strOrderNumber
			Update tblPayment_Order set Payment_Status = 1 where Payment_ReceiptNo = @strOrderNumber
		END


		 --- Cal Service charges
		-- select SUM((PaymentD_UnitPrice * PaymentD_Qty) - Payment_DiscountAmt) from tblPayment_Header h
		--inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo where Payment_ReceiptNo = 'C16-00121126'
		--AND PaymentD_TaxRate <> 0
		--Group by PaymentD_TaxRate

		Declare @dblItemTax as money = 0
		Declare @dblItemTotalAmt as money = 0
		--select @dblItemTax = PaymentD_TaxRate from tblPayment_Header h
		--inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo where Payment_ReceiptNo = @strReceiptNo
		--AND PaymentD_TaxRate <> 0
		--Group by PaymentD_TaxRate

		--select @dblItemTotalAmt = SUM((PaymentD_UnitPrice * PaymentD_Qty) - Payment_DiscountAmt), 
		--@dblItemTax = PaymentD_TaxRate 
		--from tblPayment_Header h
		--inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo where Payment_ReceiptNo = @strReceiptNo
		--AND PaymentD_TaxRate <> 0
		--Group by PaymentD_TaxRate
		--if @dblItemTax <> 0
		--BEGIN
		--	Declare @dblTotalTax as money = 0
		--	Declare @dblFinalSetAmt2 money = 0
		--	Declare @dblFinalRoundUpAmt2 money = 0

		--	set @dblItemTotalAmt = @dblItemTotalAmt - @dblGlobalDiscountAmt
		--	set @dblTotalTax =ROUND( @dblItemTotalAmt * (@dblItemTax/100),2)

		--	Update tblPayment_Header set 
		--	Payment_TotalTaxAmt = @dblTotalTax, Payment_FinalAmt = Payment_GrossAmt - @dblGlobalDiscountAmt + @dblTotalTax,
		--	Payment_NetAmt = Payment_GrossAmt -@dblGlobalDiscountAmt+ @dblTotalTax
		--	where Payment_ReceiptNo = @strReceiptNo

		--	select @dblFinalSetAmt2 = Payment_FinalAmt from  tblPayment_Header where Payment_ReceiptNo = @strReceiptNo
		--	select @dblFinalRoundUpAmt2 = dbo.fnGetRoundUp(@dblFinalSetAmt2)
		--	update tblPayment_Header set  Payment_RoundUp = @dblFinalRoundUpAmt2 where Payment_ReceiptNo = @strReceiptNo

		--END

		if @dblCompanySC <> 0 
		BEGIN
			Declare @dblFinalSetAmt money = 0 
			Declare @dblFinalRoundUpAmt money = 0 
			Declare @dblFinalSSTAmt money = 0 
			Declare @dblFinalSCAmt money = 0 
			select @dblFinalSetAmt = (Payment_GrossAmt- Payment_DiscountAmt-Payment_GlobalDiscountAmt), @dblFinalSSTAmt = Payment_TotalTaxAmt from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

			--set @dblFinalSSTAmt = ROUND(@dblFinalSetAmt * @dblCompanySST,2)
			set @dblFinalSCAmt = ROUND(@dblFinalSetAmt * @dblCompanySC,2)

			update tblPayment_Header set 
			--Payment_SST = @dblFinalSSTAmt, 
			Payment_SC = @dblFinalSCAmt
			--Payment_TotalTaxAmt = @dblFinalSSTAmt
			where Payment_ReceiptNo = @strReceiptNo

			set @dblFinalSetAmt = @dblFinalSetAmt + (@dblFinalSCAmt) + @dblFinalSSTAmt
			select @dblFinalRoundUpAmt = dbo.fnGetRoundUp(@dblFinalSetAmt)
			update tblPayment_Header set  Payment_RoundUp = @dblFinalRoundUpAmt where Payment_ReceiptNo = @strReceiptNo

			set @dblFinalSetAmt = @dblFinalSetAmt + @dblFinalRoundUpAmt

			update tblPayment_Header set 
			Payment_FinalAmt = @dblFinalSetAmt, Payment_CompanyCode = @strCompanyCode
			where Payment_ReceiptNo = @strReceiptNo
		END

		update tblPayment_Header set Payment_CompanyCode = @strCompanyCode where Payment_ReceiptNo = @strReceiptNo
		Update tblPayment_Header set Payment_SST = Payment_TotalTaxAmt where Payment_ReceiptNo = @strReceiptNo

		Update tblTable set Table_Status = 0, Table_isCalling = 0 where Table_Code = @strTableCode and Table_CompanyCode = @strCompanyCode

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)
	
	

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
